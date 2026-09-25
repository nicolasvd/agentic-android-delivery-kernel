---
name: plan-issue
description: Native Antigravity inception skill intercepting prompts discussing features, enhancements, bugs, or backlog tasks. Halts coding, enforces Rule 0 & Rule 5, orchestrates Personas 1-4 with Conditional P2 Design Gate, and pauses at Step 1.4 for approval.
triggers:
  - "new feature"
  - "feature request"
  - "enhancement"
  - "bug report"
  - "fix issue"
  - "backlog task"
  - "user need"
  - "idea"
  - "/plan-issue"
owner: Persona 1 (Product Planner)
consumers: [P1, P2, P3, P4]
version: 2.0.0
---

# Skill: `plan-issue` (Inception Consortium)

Standardizes specification and architectural framing on **Agentic Android Kernel**. Intercepts feature ideas, bug reports, and backlog tasks to orchestrate **Personas 1 to 4** and produce a sealed, immutable plan before coding.

> **References**: [`backlog-planner.md`](../../rules/backlog-planner.md) (Rule 0, 0.1, A) · [`agent-lifecycle.md`](../../rules/agent-lifecycle.md) · [`4-pillar-spec.md`](../../templates/4-pillar-spec.md) · [`epic-spec.md`](../../templates/epic-spec.md)

---

## 🎯 Sequential Execution Recipe

### Step 1: Immediate Halt of Local Coding (Rule 0 Guardrail)
If the user prompt discusses a new feature, change, or bug:
- **HALT** any direct file editing or branching on `main` or existing local branches.
- Every modification MUST originate from a sealed GitHub issue.

### Step 2: Anti-Duplication Check (Persona 1)
Query existing issues to prevent redundant work:
```json
GitHubMCP:search_issues { "q": "repo:<owner>/<repo> is:issue <keywords>" }
```
If an open issue already covers the scope, switch to that issue or add context via comment.

### Step 3: Local 4-Pillar Spec Orchestration & Sizing Consolidation
Consortium members populate [`.agent/templates/4-pillar-spec.md`](../../templates/4-pillar-spec.md) locally in `implementation_plan.md` (`issue: null`):
1. **P1 (Product Planner)**: User Story (Gherkin) & 3-State Access Matrix (Guest/Solo/Duo).
2. **P2 (Design Lead — Conditional Gate)**: Material 3 tokens, component states, Roborazzi expectations (or `N/A — No visual/UI changes`). Bypass immediately if requested (*"skip design"*).
3. **P3 (Privacy & Data Lead)**: Zero-PII telemetry, event taxonomy, GDPR/AI Act compliance.
4. **P4 (System Architect)**: Room, Firestore, Clean MVI, and consolidated `Size` (XS–XL) and `Estimate`.

### Step 3.1: Complexity L/XL Route — Epic Decomposition (Rule 0.1)
If `Size` is `L` or `XL` (or `Estimate >= 3d`):
- P1 & P4 produce [`.agent/templates/epic-spec.md`](../../templates/epic-spec.md) detailing sequential child tasks (< 300 diff lines each).
- Epic integration branch `epic/issue-<id>-<slug>` will be created upon sealing.
- Intermediate child PRs carry `skip-release`.

### Step 4: Step 1.4 Gating Check (STOP & WAIT)

> [!CAUTION]
> **Step 1.4 Gate**: Do NOT create branches, code edits, or remote GitHub issues until the user provides explicit written approval on `implementation_plan.md` (Rule 1.5).

### Step 5: Just-In-Time (JIT) Sealing via CLI
Upon explicit human approval:
```bash
./scripts/seal-issue.sh --from-plan [path_to_plan]
```
- Creates the GitHub issue assigned to `@me` with native flags (`--milestone`, `--parent`).
- Synchronizes Project v2 metadata atomically (`Priority`, `Size`, `Estimate`, `Status: Ready`).
- Automatically cuts and pushes `epic/issue-<id>-<slug>` from `origin/main` if Epic.
- Updates local `implementation_plan.md` header with sealed `issue: <id>`, `branch: ...`, and `status: approved`.
