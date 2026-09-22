#!/usr/bin/env node
/**
 * ==============================================================================
 * Agentic Android Delivery Kernel — Runtime Guardrails Test Suite
 * ==============================================================================
 * Validates:
 * 1. Principle of Least Privilege (PoLP): run_command restricted from P1-P4.
 * 2. Plan Guard (plan-guard.mjs): command sanitization, airbag & branch protection.
 * 3. Branch Guard (branch-guard.mjs): canonical artifact path hardening (S-04).
 * ==============================================================================
 */

import assert from 'node:assert/strict';
import fs from 'fs';
import path from 'path';
import { inspectCommand } from '../.agent/hooks/plan-guard.mjs';
import { inspectFileWrite, isArtifactPath } from '../.agent/hooks/branch-guard.mjs';

const repoRoot = path.resolve(process.cwd());
const blockedBranches = ['main', 'master'];

console.log('🧪 Starting Runtime Guardrails & PoLP Verification Suite...\n');

// ------------------------------------------------------------------------------
// 1. Principle of Least Privilege (PoLP) Persona Audit
// ------------------------------------------------------------------------------
console.log('📋 1. Verifying Principle of Least Privilege (PoLP) on Personas:');

const personasDir = path.resolve(repoRoot, '.agent/personas');
const personaFiles = [
  'p1-product-planner.md',
  'p2-design-lead.md',
  'p3-privacy-data.md',
  'p4-system-architect.md'
];

for (const pf of personaFiles) {
  const content = fs.readFileSync(path.join(personasDir, pf), 'utf8');
  const allowMatch = content.match(/allow:([\s\S]*?)deny:/);
  const denyMatch = content.match(/deny:([\s\S]*?)contracts:/);

  assert.ok(allowMatch, `${pf} must have an 'allow:' section`);
  assert.ok(denyMatch, `${pf} must have a 'deny:' section`);

  const allowedTools = allowMatch[1];
  const deniedTools = denyMatch[1];

  assert.ok(
    !allowedTools.includes('run_command'),
    `❌ PoLP Violation: ${pf} allows 'run_command'`
  );
  assert.ok(
    deniedTools.includes('run_command'),
    `❌ PoLP Violation: ${pf} must deny 'run_command'`
  );
  console.log(`  ✅ [OK] ${pf}: run_command revoked & denied`);
}

// ------------------------------------------------------------------------------
// 2. Plan Guard (plan-guard.mjs) Verification
// ------------------------------------------------------------------------------
console.log('\n🛡️ 2. Verifying Plan Guard (plan-guard.mjs) Runtime Rejections:');

const testCasesPlanGuard = [
  // Airbag Bypass Checks
  {
    name: 'Reject git commit with --no-verify',
    cmd: 'git commit --no-verify -m "bypass"',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Airbag Bypass'
  },
  {
    name: 'Reject git commit with -n flag',
    cmd: 'git commit -n -m "bypass"',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Airbag Bypass'
  },
  {
    name: 'Reject git commit with combined -nm flag',
    cmd: 'git commit -nm "bypass"',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Airbag Bypass'
  },
  {
    name: 'Reject git push with --no-verify',
    cmd: 'git push --no-verify origin feat/issue-3-test',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Airbag Bypass'
  },

  // Hook Path Tampering Checks (S-02)
  {
    name: 'Reject inline -c core.hooksPath override',
    cmd: 'git -c core.hooksPath=/dev/null commit -m "bypass"',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Tampering with \'core.hooksPath\''
  },
  {
    name: 'Reject GIT_HOOKS_PATH environment override',
    cmd: 'GIT_HOOKS_PATH=/dev/null git commit -m "bypass"',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Tampering with \'core.hooksPath\''
  },

  // Protected Branch Commit Checks (S-01)
  {
    name: 'Reject git commit on main',
    cmd: 'git commit -m "direct commit"',
    branch: 'main',
    expectAllow: false,
    expectedErrorSubstring: 'Direct \'git commit\' on protected branch'
  },
  {
    name: 'Reject chained git add && git commit on main',
    cmd: 'git add -A && git commit -m "chained bypass"',
    branch: 'main',
    expectAllow: false,
    expectedErrorSubstring: 'Direct \'git commit\' on protected branch'
  },

  // Protected Branch Push Checks (S-01)
  {
    name: 'Reject direct git push while on main',
    cmd: 'git push',
    branch: 'main',
    expectAllow: false,
    expectedErrorSubstring: 'Direct \'git push\' from protected branch'
  },
  {
    name: 'Reject git push targeting main from feature branch',
    cmd: 'git push origin main',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Direct \'git push\' targeting protected branch'
  },
  {
    name: 'Reject git push targeting HEAD:main',
    cmd: 'git push origin HEAD:main',
    branch: 'feat/issue-3-test',
    expectAllow: false,
    expectedErrorSubstring: 'Direct \'git push\' targeting protected branch'
  },

  // Permitted Commands
  {
    name: 'Allow ./gradlew testDebugUnitTest',
    cmd: './gradlew testDebugUnitTest',
    branch: 'feat/issue-3-test',
    expectAllow: true
  },
  {
    name: 'Allow ./scripts/quality-check.sh',
    cmd: './scripts/quality-check.sh',
    branch: 'feat/issue-3-test',
    expectAllow: true
  },
  {
    name: 'Allow git status on any branch',
    cmd: 'git status',
    branch: 'main',
    expectAllow: true
  },
  {
    name: 'Allow git log -n 5 (flag -n on log is not commit)',
    cmd: 'git log -n 5',
    branch: 'feat/issue-3-test',
    expectAllow: true
  },
  {
    name: 'Allow normal git commit on feature branch',
    cmd: 'git commit -m "feat(security): valid commit"',
    branch: 'feat/issue-3-test',
    expectAllow: true
  },
  {
    name: 'Allow normal git push of feature branch',
    cmd: 'git push origin feat/issue-3-test',
    branch: 'feat/issue-3-test',
    expectAllow: true
  }
];

for (const tc of testCasesPlanGuard) {
  const result = inspectCommand(tc.cmd, tc.branch, blockedBranches);
  assert.equal(
    result.allow,
    tc.expectAllow,
    `❌ Assertion failed for '${tc.name}': expected allow=${tc.expectAllow}, got allow=${result.allow} (reason: ${result.reason})`
  );
  if (!tc.expectAllow && tc.expectedErrorSubstring) {
    assert.ok(
      result.reason && result.reason.includes(tc.expectedErrorSubstring),
      `❌ Expected error substring '${tc.expectedErrorSubstring}', got '${result.reason}'`
    );
  }
  console.log(`  ✅ [OK] ${tc.name}`);
}

// ------------------------------------------------------------------------------
// 3. Branch Guard (branch-guard.mjs) Path Hardening Verification (S-04)
// ------------------------------------------------------------------------------
console.log('\n🔒 3. Verifying Branch Guard (branch-guard.mjs) Path Hardening:');

const testCasesBranchGuard = [
  // S-04 Escape Hatch Exploits: Must be DENIED
  {
    name: 'Deny write to repo file named app/src/main/implementation_plan.md on main',
    file: 'app/src/main/implementation_plan.md',
    branch: 'main',
    expectAllow: false
  },
  {
    name: 'Deny write to repo file named scripts/walkthrough.md on main',
    file: 'scripts/walkthrough.md',
    branch: 'main',
    expectAllow: false
  },
  {
    name: 'Deny write to repo root implementation_plan.md on main',
    file: 'implementation_plan.md',
    branch: 'main',
    expectAllow: false
  },
  {
    name: 'Deny write to source file app/src/main/java/MainActivity.kt on main',
    file: 'app/src/main/java/MainActivity.kt',
    branch: 'main',
    expectAllow: false
  },

  // Legitimate External Brain Artifacts: Must be ALLOWED on any branch
  {
    name: 'Allow external brain artifact implementation_plan.md',
    file: '/Users/nicolasvd/.gemini/antigravity/brain/616e7271-ff38-4732-aead-b484ba0ee39d/implementation_plan.md',
    branch: 'main',
    expectAllow: true
  },
  {
    name: 'Allow external brain artifact walkthrough.md',
    file: '/Users/nicolasvd/.gemini/antigravity/brain/616e7271-ff38-4732-aead-b484ba0ee39d/walkthrough.md',
    branch: 'main',
    expectAllow: true
  },
  {
    name: 'Allow external system_generated step output',
    file: '/Users/nicolasvd/.gemini/antigravity/brain/616e7271-ff38-4732-aead-b484ba0ee39d/.system_generated/steps/1/output.txt',
    branch: 'main',
    expectAllow: true
  },

  // Feature Branch Writes: Must be ALLOWED
  {
    name: 'Allow source file write on dedicated feature branch',
    file: 'app/src/main/java/MainActivity.kt',
    branch: 'feat/issue-3-shell-execution-guardrails',
    expectAllow: true
  }
];

for (const tc of testCasesBranchGuard) {
  const result = inspectFileWrite(tc.file, tc.branch, blockedBranches, repoRoot);
  assert.equal(
    result.allow,
    tc.expectAllow,
    `❌ Assertion failed for '${tc.name}': expected allow=${tc.expectAllow}, got allow=${result.allow} (reason: ${result.reason})`
  );
  console.log(`  ✅ [OK] ${tc.name}`);
}

console.log('\n🎉 ALL RUNTIME GUARDRAILS, PoLP & PATH HARDENING TESTS PASSED 100%!');
