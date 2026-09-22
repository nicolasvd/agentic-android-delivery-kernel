#!/usr/bin/env node
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

function getRepoRoot() {
  try {
    return execSync('git rev-parse --show-toplevel', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return process.cwd();
  }
}

function getBlockedBranches() {
  try {
    const configPath = path.resolve(getRepoRoot(), 'kernel.config.json');
    if (fs.existsSync(configPath)) {
      const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      const def = cfg?.git?.defaultBranch || 'main';
      return [def, 'main', 'master'].filter((v, i, a) => a.indexOf(v) === i);
    }
  } catch {}
  return ['main', 'master'];
}

function isArtifactPath(targetFile, repoRoot) {
  if (!targetFile || typeof targetFile !== 'string') return false;
  const resolved = path.resolve(repoRoot, targetFile);
  const rel = path.relative(repoRoot, resolved);
  if (!rel.startsWith('..') && !path.isAbsolute(rel)) return false;

  return resolved.includes('/.gemini/antigravity/brain/') ||
         resolved.includes('/.system_generated/') ||
         Boolean(process.env.APP_DATA_DIR && resolved.startsWith(path.resolve(process.env.APP_DATA_DIR)));
}

function inspectFileWrite(targetFile, currentBranch, blockedBranches, repoRoot) {
  if (isArtifactPath(targetFile, repoRoot)) return { allow: true };

  if (blockedBranches.includes(currentBranch)) {
    return {
      allow: false,
      reason: `[Rule 0 Violation S-04] Direct modification to '${targetFile}' on '${currentBranch}' is blocked. Cut a dedicated feature branch first.`
    };
  }
  return { allow: true };
}

const isMain = Boolean(process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1]));
if (isMain) {
  let input = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', chunk => { input += chunk; });
  process.stdin.on('end', () => {
    try {
      const payload = JSON.parse(input || '{}');
      const targetFile = payload?.toolCall?.args?.TargetFile || '';
      const repoRoot = getRepoRoot();
      let currentBranch = '';
      try {
        currentBranch = execSync('git branch --show-current', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
      } catch {}

      const res = inspectFileWrite(targetFile, currentBranch, getBlockedBranches(), repoRoot);
      if (!res.allow) {
        process.stdout.write(JSON.stringify({ decision: 'deny', reason: res.reason }));
        process.exit(0);
      }
      process.stdout.write(JSON.stringify({ decision: 'allow' }));
    } catch {
      process.stdout.write(JSON.stringify({ decision: 'allow' }));
    }
  });
}

export { isArtifactPath, inspectFileWrite, getBlockedBranches, getRepoRoot };
