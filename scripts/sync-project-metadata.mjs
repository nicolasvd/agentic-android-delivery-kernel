#!/usr/bin/env node
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

function printUsage() {
  console.log(`Usage: sync-project-metadata.mjs <issue_id> [options]
Options:
  --priority <P0|P1|P2>    Set Priority field
  --size <XS|S|M|L|XL>     Set Size field
  --estimate <number>      Set Estimate field
  --status <StatusName>    Set Status (Backlog, Ready, In progress, In review, Done)
  --dry-run                Simulate without mutations
  --json                   Output results as JSON
  -h, --help               Display help`);
}

const args = process.argv.slice(2);
if (args.length === 0 || args.includes('-h') || args.includes('--help')) {
  printUsage();
  process.exit(0);
}

const issueArg = args[0];
if (!issueArg || isNaN(Number(issueArg))) {
  console.error(`❌ Error: First argument must be numeric Issue ID. Received: '${issueArg}'`);
  process.exit(1);
}

const issueNumber = parseInt(issueArg, 10);
let priorityVal = null, sizeVal = null, estimateVal = null, statusVal = null;
let dryRun = false, jsonOutput = false;

for (let i = 1; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--priority' && i + 1 < args.length) priorityVal = args[++i];
  else if (arg === '--size' && i + 1 < args.length) sizeVal = args[++i];
  else if (arg === '--estimate' && i + 1 < args.length) estimateVal = parseFloat(args[++i]);
  else if (arg === '--status' && i + 1 < args.length) statusVal = args[++i];
  else if (arg === '--dry-run') dryRun = true;
  else if (arg === '--json') jsonOutput = true;
}

let owner = '', repo = '', projectNumber = 2, projectEnabled = true;

try {
  const cfgPath = path.resolve(process.cwd(), 'kernel.config.json');
  if (fs.existsSync(cfgPath)) {
    const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
    owner = cfg?.git?.owner || '';
    repo = cfg?.git?.repo || '';
    projectNumber = cfg?.githubProject?.projectNumber ?? 2;
    projectEnabled = cfg?.githubProject?.enabled ?? true;
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
  if (!jsonOutput) console.log(`ℹ️ [SyncMetadata] Projects disabled. Skipping #${issueNumber}.`);
  process.exit(0);
}

function runGh(ghArgs) {
  return execSync(`gh ${ghArgs}`, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
}

function gql(query, variables = {}) {
  const varArgs = Object.entries(variables)
    .map(([k, v]) => `-F ${k}=${typeof v === 'number' ? v : `"${v}"`}`).join(' ');
  return JSON.parse(runGh(`api graphql -f query='${query.replace(/\n/g, ' ')}' ${varArgs}`)).data;
}

const results = { issueNumber, projectNumber, updated: [], dryRun };

try {
  const query = `query($login:String!,$pNum:Int!,$repo:String!,$issue:Int!){
    user(login:$login){projectV2(number:$pNum){id fields(first:30){nodes{
      ...on ProjectV2Field{id name dataType}
      ...on ProjectV2SingleSelectField{id name dataType options{id name}}
    }}}}
    repository(owner:$login,name:$repo){issue(number:$issue){id projectItems(first:10){nodes{id project{id}}}}}
  }`;

  let data = gql(query, { login: owner, pNum: projectNumber, repo, issue: issueNumber });
  let project = data?.user?.projectV2;
  const issue = data?.repository?.issue;

  if (!project) {
    const orgQuery = query.replace('user(login:$login)', 'organization(login:$login)');
    data = gql(orgQuery, { login: owner, pNum: projectNumber, repo, issue: issueNumber });
    project = data?.organization?.projectV2;
  }

  if (!project) throw new Error(`Project #${projectNumber} not found.`);
  if (!issue) throw new Error(`Issue #${issueNumber} not found in '${owner}/${repo}'.`);

  const fields = project.fields?.nodes || [];
  let projectItem = (issue.projectItems?.nodes || []).find(n => n.project?.id === project.id);
  let itemId = projectItem?.id;

  if (!itemId) {
    if (dryRun) {
      results.itemAdded = true;
      itemId = 'SIMULATED_ID';
    } else {
      const addRes = gql(
        `mutation($p:ID!,$c:ID!){addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}}`,
        { p: project.id, c: issue.id }
      );
      itemId = addRes?.addProjectV2ItemById?.item?.id;
      results.itemAdded = true;
    }
  }

  function updateSelect(fieldName, targetValue) {
    if (!targetValue) return;
    const f = fields.find(x => x.name?.toLowerCase() === fieldName.toLowerCase() && x.options);
    if (!f) return;
    const opt = f.options.find(o => o.name?.toLowerCase() === targetValue.toLowerCase());
    if (!opt) return;

    if (!dryRun) {
      gql(
        `mutation($p:ID!,$i:ID!,$f:ID!, $v:String!){updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:{singleSelectOptionId:$v}}){projectV2Item{id}}}`,
        { p: project.id, i: itemId, f: f.id, v: opt.id }
      );
    }
    results.updated.push({ field: f.name, value: opt.name });
  }

  function updateNumber(fieldName, targetValue) {
    if (targetValue === null || isNaN(targetValue)) return;
    const f = fields.find(x => x.name?.toLowerCase() === fieldName.toLowerCase() && x.dataType === 'NUMBER');
    if (!f) return;

    if (!dryRun) {
      runGh(`api graphql -f query='mutation { updateProjectV2ItemFieldValue(input: { projectId: "${project.id}", itemId: "${itemId}", fieldId: "${f.id}", value: { number: ${targetValue} } }) { projectV2Item { id } } }'`);
    }
    results.updated.push({ field: f.name, value: targetValue });
  }

  updateSelect('Priority', priorityVal);
  updateSelect('Size', sizeVal);
  updateNumber('Estimate', estimateVal);
  updateSelect('Status', statusVal);

  if (jsonOutput) {
    console.log(JSON.stringify(results, null, 2));
  } else {
    console.log(`✅ [SyncMetadata] Issue #${issueNumber} synchronized on Project #${projectNumber}:`);
    for (const u of results.updated) console.log(`   • ${u.field}: ${u.value}`);
    if (dryRun) console.log(`   (Dry-run simulation mode)`);
  }
} catch (err) {
  if (jsonOutput) {
    console.error(JSON.stringify({ error: err.message, issueNumber }, null, 2));
  } else {
    console.error(`❌ [SyncMetadata] Error on #${issueNumber}:`, err.message);
  }
  process.exit(1);
}
