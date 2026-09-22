#!/usr/bin/env node
/**
 * ==============================================================================
 * Agentic Android Delivery Kernel — Native Branch Guard Hook (PreToolUse)
 * ==============================================================================
 * Intercepts write_to_file and replace_file_content tool calls.
 * Blocks modifications to repository source files if the current git branch
 * matches the default branch (e.g. main/master), enforcing Gate 1.4 and Rule 0.
 * ==============================================================================
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

function getBlockedBranches() {
  try {
    const configPath = path.resolve(process.cwd(), 'kernel.config.json');
    if (fs.existsSync(configPath)) {
      const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      const def = cfg?.git?.defaultBranch || 'main';
      return [def, 'main', 'master'].filter((v, i, a) => a.indexOf(v) === i);
    }
  } catch {}
  return ['main', 'master'];
}

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });

process.stdin.on('end', () => {
  try {
    const payload = JSON.parse(input || '{}');
    const toolCall = payload.toolCall || {};
    const args = toolCall.args || {};
    const targetFile = args.TargetFile || '';

    // Allow writes to Antigravity brain artifacts, system logs, or scratchpads
    const isArtifact = targetFile.includes('/.gemini/antigravity/brain/') ||
                       targetFile.includes('/.system_generated/') ||
                       targetFile.endsWith('implementation_plan.md') ||
                       targetFile.endsWith('walkthrough.md');

    if (isArtifact) {
      process.stdout.write(JSON.stringify({ decision: 'allow' }));
      process.exit(0);
    }

    // Determine current git branch
    let currentBranch = '';
    try {
      currentBranch = execSync('git branch --show-current', {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore']
      }).trim();
    } catch {
      currentBranch = '';
    }

    const blockedBranches = getBlockedBranches();
    if (blockedBranches.includes(currentBranch)) {
      const response = {
        decision: 'deny',
        reason: `[Rule 0 Violation] Direct modification to '${targetFile}' on branch '${currentBranch}' is strictly blocked.\n` +
                `You must complete Phase 1 Inception, post the 4-Pillar Spec, obtain explicit written approval at Gate 1.4, ` +
                `and cut a dedicated branch (<type>/issue-<id>-<slug>) before modifying repository files.`
      };
      process.stdout.write(JSON.stringify(response));
      process.exit(0);
    }

    process.stdout.write(JSON.stringify({ decision: 'allow' }));
  } catch {
    // Fail-safe to allow in case of unparseable payload
    process.stdout.write(JSON.stringify({ decision: 'allow' }));
  }
});
