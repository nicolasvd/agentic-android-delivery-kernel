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

function tokenize(cmd) {
  return cmd.match(/(?:[^\s"']+|"[^"]*"|'[^']*')+/g) || [];
}

function inspectCommand(commandLine, currentBranch, blockedBranches) {
  if (!commandLine || typeof commandLine !== 'string') return { allow: true };

  // 1. Hook Path Tampering: Block overriding core.hooksPath or GIT_HOOKS_PATH
  if (/-c\s*core\.hooksPath/i.test(commandLine) ||
      /\bGIT_HOOKS_PATH\b/i.test(commandLine) ||
      /\bcore\.hooksPath\s*=/i.test(commandLine)) {
    return {
      allow: false,
      reason: "[Security Violation S-02] Tampering with 'core.hooksPath' is strictly prohibited. Pre-commit airbag cannot be deactivated."
    };
  }

  const segments = commandLine.split(/(?:&&|\|\||[;\n|&])/).map(s => s.trim()).filter(Boolean);

  for (const segment of segments) {
    const tokens = tokenize(segment);
    let i = 0;
    while (i < tokens.length && /^[a-zA-Z_]\w*=/.test(tokens[i])) i++;

    if (i >= tokens.length || tokens[i] !== 'git') continue;
    i++;

    const flagsWithArg = new Set(['-C', '-c', '--git-dir', '--work-tree', '--namespace', '--super-prefix', '--exec-path', '--config-env']);
    let subcommand = null;
    let subArgs = [];

    while (i < tokens.length) {
      const t = tokens[i];
      if (t.startsWith('--')) {
        i += (!t.includes('=') && flagsWithArg.has(t)) ? 2 : 1;
      } else if (t.startsWith('-')) {
        i += flagsWithArg.has(t) ? 2 : 1;
      } else {
        subcommand = t;
        subArgs = tokens.slice(i + 1);
        break;
      }
    }

    if (!subcommand) continue;

    if (subcommand === 'commit') {
      const hasNoVerify = subArgs.some(a => (!a.startsWith('"') && !a.startsWith("'")) && (a === '--no-verify' || /^-[a-zA-Z]*n[a-zA-Z]*$/.test(a)));
      if (hasNoVerify) {
        return {
          allow: false,
          reason: "[Airbag Bypass S-02] 'git commit' with '--no-verify' or '-n' is strictly prohibited. All commits must pass the airbag."
        };
      }

      if (blockedBranches.includes(currentBranch) || currentBranch.startsWith('epic/')) {
        const code = currentBranch.startsWith('epic/') ? 'Rule 0.1 Violation E-01' : 'Rule 0 Violation S-01';
        return {
          allow: false,
          reason: `[${code}] Direct 'git commit' on protected branch '${currentBranch}' is blocked. Cut a dedicated child feature branch first.`
        };
      }
    }

    if (subcommand === 'push') {
      if (subArgs.some(a => a === '--no-verify')) {
        return { allow: false, reason: "[Airbag Bypass S-02] 'git push' with '--no-verify' is strictly prohibited." };
      }

      if (blockedBranches.includes(currentBranch)) {
        return { allow: false, reason: `[Security Violation S-01] Direct 'git push' from protected branch '${currentBranch}' is strictly blocked.` };
      }

      const targetsBlocked = subArgs.some(a => {
        const c = a.replace(/^['"]|['"]$/g, '');
        return blockedBranches.includes(c) || c.endsWith(':main') || c.endsWith(':master') || c === 'origin/main' || c === 'origin/master';
      });

      if (targetsBlocked) {
        return { allow: false, reason: "[Security Violation S-01] Direct 'git push' targeting protected branch 'main'/'master' is strictly prohibited." };
      }
    }

    if (subcommand === 'merge' && (blockedBranches.includes(currentBranch) || currentBranch.startsWith('epic/'))) {
      return { allow: false, reason: `[Rule 0 Violation S-01] Direct 'git merge' on protected branch '${currentBranch}' is blocked. Merge via PR at Gate 3.5.` };
    }
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
      const commandLine = payload?.toolCall?.args?.CommandLine || payload?.toolCall?.args?.command || payload?.toolCall?.args?.Command || '';

      let currentBranch = '';
      try {
        currentBranch = execSync('git branch --show-current', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
      } catch {}

      const res = inspectCommand(commandLine, currentBranch, getBlockedBranches());
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

export { inspectCommand, tokenize, getBlockedBranches, getRepoRoot };
