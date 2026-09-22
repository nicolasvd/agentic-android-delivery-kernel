#!/usr/bin/env node
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const issueArg = process.argv[2];
if (!issueArg || isNaN(Number(issueArg))) {
  console.log('Usage: sync-issue-progress.mjs <issue_id>');
  process.exit(0);
}

const issueNum = parseInt(issueArg, 10);
let owner = '', repo = '', pNum = 1, projectEnabled = false;

try {
  const configPath = path.resolve(process.cwd(), 'kernel.config.json');
  if (fs.existsSync(configPath)) {
    const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    owner = cfg?.git?.owner || '';
    repo = cfg?.git?.repo || '';
    pNum = cfg?.githubProject?.projectNumber || 1;
    projectEnabled = cfg?.githubProject?.enabled ?? false;
  }
} catch {}

if (!owner || !repo) {
  try {
    const remoteUrl = execSync('git remote get-url origin', { encoding: 'utf8' }).trim();
    const match = remoteUrl.match(/[:/]([^/]+)\/([^/]+?)(?:\.git)?$/);
    if (match) { owner = match[1]; repo = match[2]; }
  } catch {}
}

if (!projectEnabled) {
  console.log(`ℹ️ [SyncIssueProgress] GitHub Projects disabled. Skipping #${issueNum}.`);
  process.exit(0);
}

function runGh(args) {
  return execSync(`gh ${args}`, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
}

function gql(q, vars = {}) {
  const v = Object.entries(vars).map(([k, val]) => `-F ${k}=${typeof val === 'number' ? val : `"${val}"`}`).join(' ');
  return JSON.parse(runGh(`api graphql -f query='${q}' ${v}`)).data;
}

function setField(p, i, f, key, val) {
  gql(`mutation($p:ID!,$i:ID!,$f:ID!,$v:String!){updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:{${key}:$v}}){projectV2Item{id}}}`, { p, i, f, v: val });
}

try {
  console.log(`🔄 [SyncIssueProgress] Syncing #${issueNum}...`);
  const q = `query($o:String!,$r:String!,$i:Int!,$p:Int!){repository(owner:$o,name:$r){issue(number:$i){id milestone{title}projectItems(first:5){nodes{id project{id}}}}milestones(first:3,states:[OPEN],orderBy:{field:DUE_DATE,direction:ASC}){nodes{number title}}}user(login:$o){projectV2(number:$p){id fields(first:20){nodes{...on ProjectV2SingleSelectField{id name options{id name}}...on ProjectV2IterationField{id name configuration{iterations{id title startDate duration}}}}}}}}`;

  const data = gql(q, { o: owner, r: repo, i: issueNum, p: pNum });
  const issue = data?.repository?.issue;
  if (!issue) {
    console.log(`⚠️  Issue #${issueNum} not found.`);
    process.exit(0);
  }

  if (!issue.milestone) {
    const ms = (data?.repository?.milestones?.nodes || [])[0];
    if (ms) {
      console.log(`📍 Assigning milestone '${ms.title}' (#${ms.number})...`);
      runGh(`api repos/${owner}/${repo}/issues/${issueNum} -X PATCH -F milestone=${ms.number}`);
    }
  }

  const project = data?.user?.projectV2;
  const fields = project?.fields?.nodes || [];
  const statusField = fields.find(f => f.name === 'Status' && f.options);
  const cycleField = fields.find(f => f.name === 'Cycle' && f.configuration?.iterations);

  let pItem = (issue.projectItems?.nodes || []).find(pi => pi.project?.id === project?.id);
  let itemId = pItem?.id;

  if (project && !itemId) {
    const res = gql(`mutation($p:ID!,$c:ID!){addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}}`, { p: project.id, c: issue.id });
    itemId = res?.addProjectV2ItemById?.item?.id;
  }

  if (itemId && statusField) {
    const inProgressOpt = statusField.options.find(o => o.name.toLowerCase() === 'in progress');
    if (inProgressOpt) {
      console.log(`🎯 Setting Status -> In Progress...`);
      setField(project.id, itemId, statusField.id, 'singleSelectOptionId', inProgressOpt.id);
    }
  }

  if (itemId && cycleField) {
    const now = new Date();
    const currentIter = cycleField.configuration?.iterations?.find(it => {
      const s = new Date(it.startDate);
      const e = new Date(s.getTime() + it.duration * 86400000);
      return now >= s && now < e;
    });

    if (currentIter) {
      console.log(`🔄 Setting Cycle -> ${currentIter.title}...`);
      setField(project.id, itemId, cycleField.id, 'iterationId', currentIter.id);
    }
  }

  console.log(`✅ #${issueNum} synced successfully.`);
} catch (e) {
  console.error(`❌ [SyncIssueProgress] Failed:`, e.message);
}
