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

### Step 3: Sealed Issue Creation & Native Project Metadata (Persona 1)
If new, P1 creates the issue assigned strictly to `@me` (`@me`):
```json
GitHubMCP:create_issue {
  "owner": "@me",
  "repo": "<repo>",
  "title": "<type>(<scope>): <explicit title>",
  "body": "## Context & User Story\n...",
  "labels": ["<type>", "source:internal"],
  "assignees": ["@me"]
}
```
P1 assigns the native **GitHub Projects v2 Metadata**:
- `Priority`: `P0` / `P1` / `P2`
- `Size`: `XS` / `S` / `M` / `L` / `XL` (determined with P4)
- `Estimate`: Numeric estimate in points or days (co-owned with P4)
- `Status`: `Backlog`

### Step 4: 4-Pillar Spec Orchestration & Conditional P2 Design Gate
Consortium members populate [`.agent/templates/4-pillar-spec.md`](../../templates/4-pillar-spec.md) through contextual triage:
1. **P1 (Product Planner)**: User Story (Gherkin) & 3-State Access Matrix (Guest/Solo/Duo).
2. **P2 (Design Lead — Conditional Gate)**:
   - **UI Changes**: If changes touch `@Composable`, screens, or theme tokens, P2 defines Material 3 tokens, component states, and Roborazzi snapshot expectations.
   - **Non-UI Changes**: For pure backend, Room, Firestore rules, CI/CD, scripts, or chores, mark: `N/A — No visual/UI changes`.
   - **Explicit User Override**: If prompt explicitly requests to skip design (e.g. *"skip design"*), bypass P2 immediately.
3. **P3 (Privacy & Data Lead)**: Pillar 2 Data Spec (Zero-PII telemetry, event taxonomy, GDPR).
4. **P4 (System Architect)**: Pillar 3 Technical Blueprint (Room, Firestore, architecture boundaries, `Size` and `Estimate`).

### Step 4.1: Complexity L/XL Route — Epic Decomposition (Rule 0.1)
If `Size` is `L` or `XL` (or `Estimate >= 3d`):
- **Classify as Epic**: Zero Branch Guardrail — strictly forbidden to branch or commit on this issue.
- **Decompose**: P1 & P4 produce [`.agent/templates/epic-spec.md`](../../templates/epic-spec.md) detailing the child-issue DAG (< 300 diff lines each).
- Intermediate child PRs carry the `skip-release` label.

### Step 5: Publish Spec & Dual-Write Pattern (Rule A)
- **Canonical Remote Source**: Post compiled spec via `GitHubMCP:add_issue_comment`. Never edit original issue body.
- **Local IDE Mirror**: Mirror 4-Pillar spec into `implementation_plan.md` artifact (`RequestFeedback: true`, `UserFacing: true`) prepending the YAML state header.

### Step 6: Step 1.4 Gating Check (STOP & WAIT)

> [!CAUTION]
> **Step 1.4 Gate**: Do NOT create branches or write code until the user gives explicit written approval on the plan (Rule 1.5 of `agent-lifecycle.md`).
