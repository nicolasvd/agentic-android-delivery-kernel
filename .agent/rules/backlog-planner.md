# Autonomous Backlog Planning — The Inception Consortium (Personas 1–4)

> **Scope**: Issue scoping, creation, and 4-Pillar Spec orchestration. Zero implementation code in this phase.
> **Companion rules**: [`agent-lifecycle.md`](agent-lifecycle.md) · [`git-workflow.md`](git-workflow.md) · [`agent.md`](../../agent.md)
> **Manifests**: [`.agent/personas/`](../personas/) · **Templates**: [`.agent/templates/`](../templates/)

---

## 1. The Inception Consortium — Persona I/O Contracts

Detailed RBAC and deliverable formats are specified in each persona's manifest:

| Persona | Manifest | Key Responsibilities | Key Outputs |
|---|---|---|---|
| **P1 · Product Planner** | [`p1-product-planner.md`](../personas/p1-product-planner.md) | User stories, acceptance criteria, Priority, Milestone, Estimate | Sealed Issue, Milestone assignment, Kanban linking |
| **P2 · Design Lead** | [`p2-design-lead.md`](../personas/p2-design-lead.md) | Material 3 token compliance, WCAG AAA, incremental screen diff policy | Pillar 1 (Design Spec) comment, Roborazzi list |
| **P3 · Privacy & Data Lead** | [`p3-privacy-data.md`](../personas/p3-privacy-data.md) | Zero-PII telemetry enforcement, value bucketing, event schema taxonomy | Pillar 2 (Data & Privacy Spec) comment |
| **P4 · System Architect** | [`p4-system-architect.md`](../personas/p4-system-architect.md) | Clean Arch audit, Room local-first guarantee, Size, Estimate, infra locks | Pillar 3 (Technical Blueprint) comment |

---

## 2. Universal Naming Standard

```
Conversation/Session : [#<id>] <type>(<scope>): <title>
Git Branch           : <type>/issue-<id>-<short-kebab-slug>
```

---

## 3. Native GitHub Projects v2 Metadata

Configured on GitHub Projects v2 board. Revisions require an `add_issue_comment` rationale.

| Field | Owner | Allowed Values & Format |
|---|---|---|
| **Priority** | P1 (PM) / Triage | `P0` (Blocker/Fatal) · `P1` (Major) · `P2` (Minor) |
| **Size** | P4 (Architect) | `XS` (<½d) · `S` (½–1d) · `M` (1–3d) · `L` (3–5d) · `XL` (>5d) |
| **Estimate** | P1 & P4 | Numeric estimate (days or story points) |

---

## 4. The 10 Golden Rules of Backlog Governance

### 🚨 Rule 0 · No Branch or Code Without a GitHub Issue
Every task (feature, bug, refactor, chore, docs) requires:
1. A GitHub Issue created **before** any development starts.
2. A dedicated `<type>/issue-<id>-<slug>` branch cut from up-to-date `main`.
3. A 1:1 PR closing the issue (`Closes #<id>`).

> ⛔ **FORBIDDEN**: coding on `main`, creating a branch/PR without an Issue number.

---

### 🏛️ Rule 0.1 · Epic Gating (Size: L / XL)
Issues rated `Size: L` or `Size: XL` (or `Estimate >= 3d`) are classified as **Epics**.
- **Zero Branch Guardrail**: Never branch or commit directly on an Epic issue.
- **Sequential Decomposition**: P1 & P4 decompose Epics into atomic child issues (< 300 diff lines) referencing the parent (`parent: #<id>`), merged sequentially to `main` (Trunk-Based) using [`.agent/templates/epic-spec.md`](../templates/epic-spec.md).
- **Silent Merges (`skip-release`)**: Intermediate child PRs carry `skip-release`.

---

### 🔏 Rule A · Issue & Branch Immutability (Append-Only)

> [!CAUTION]
> **The Issue title and initial body are permanently sealed upon creation (READ-ONLY).**

- `GitHubMCP:update_issue` targeting `title` or `body` is **strictly forbidden**.
- Branch names and types are **immutable**: a `feat/issue-<id>-*` stays `feat/` even if Phase 2 reveals minor bugs.
- Native project fields (`Priority`, `Size`, `Estimate`, `Status`) are set on the Project board; revisions require an explanatory `add_issue_comment` for auditability.
- All scope changes, plan pivots, and discussions are appended via `GitHubMCP:add_issue_comment`.

---

### 🛡️ Rule 1 · Systematic Anti-Duplication & Issue Reuse
Before creating any issue, check if referenced by user or run `GitHubMCP:search_issues` (`repo:<owner>/<repo> is:issue <keywords>`).
- **Existing Issue referenced (e.g. #69)**: Adopt it immediately. NEVER create a duplicate issue.
- **Open duplicate in backlog**: enrich via `GitHubMCP:add_issue_comment`. Do NOT create a new issue.
- **Closed issue = regression**: create new issue referencing `Regression of #<id>`.

---

### 👤 Rule 2 · Mandatory Assignation (@@me)
Every Issue and PR must be assigned to `@me` at creation. No unowned tickets.

---

### 📋 Rule 3 · Kanban Attachment & Milestone Linking
**At `Backlog` creation**: Attach to project board and assign Priority, Size, Estimate, Status.
**At `Ready` transition**: Link active Cycle and target Milestone:
```bash
gh issue edit <id> --milestone "<Milestone>"
gh project item-edit <PROJECT> --owner @me --url "..." --field "Status" --value "Ready"
```
Column lifecycle: `Backlog` → `Ready` → `In Progress` → `In Review` → `Done`.

---

### 📝 Rule 4 · Issue vs PR Separation & Dual-Write Pattern
- **Issue**: hosts canonical 4-Pillar Plan via comment ([`.agent/templates/4-pillar-spec.md`](../templates/4-pillar-spec.md)).
- **Dual-Write**: spec is mirrored to local `implementation_plan.md` artifact at Gate 1.4 for Antigravity IDE harmony.
- **PR**: hosts exclusively the Walkthrough ([`.agent/templates/pr-walkthrough.md`](../templates/pr-walkthrough.md)). Zero heredocs.

---

### 🌿 Rule 5 · Branch-First Isolation
```bash
git checkout main && git pull origin main
git checkout -b <type>/issue-<id>-<slug>
```
**FORBIDDEN**: editing files on `main` or any generic branch before this sequence.

---

### 🚀 Rule 6 · Anti-Duplicate PR & Auto-Close (`Closes #<id>`)
Check existing PRs via `gh pr list --state open`. Never open duplicate PRs. Every PR closes its issue with `Closes #<id>`.

---

### 🧪 Rule 7 · Pre-Commit Quality Airbag (Zero Regressions)
Run `./.agent/hooks/pre-commit-airbag.sh` or `./scripts/quality-check.sh` before commit.
Acceptance: 0 errors · 0 warnings · 100% unit/Robolectric tests · 100% Firestore rules valid.

---

### 📱 Rule 8 · Observability Triage (Crashlytics)
Format incident issues using [`.agent/templates/crashlytics-triage-issue.md`](../templates/crashlytics-triage-issue.md).
- Set `Priority` (P0 to P2). On PR merge, P6 triggers Dual-Sync closure.

---

### 🔁 Rule B · Weekly Sentinel Crashlytics Audit
Weekly audit of closed issues labeled `source:crashlytics`: verify Firebase incident status via `firebase-mcp-server:crashlytics_get_issue` and close if open via `crashlytics_update_issue { "state": "CLOSED" }`.

---

### 📐 Rule 9 · 4-Pillar Spec Matrix
All specifications adhere to [`.agent/templates/4-pillar-spec.md`](../templates/4-pillar-spec.md):
- `feature`: User Story (P1) · Design (P2) · Privacy/Data (P3) · Tech Blueprint (P4)
- `enhancement`: Delta UX (P2) · Adoption Analytics (P3) · Tech Blueprint (P4)
- `bug`: Repro/RCA (P1) · Fix Blueprint (P4) · Regression Tests
- `chore`: Technical target & performance metrics (P4)

---

### 🔒 Rule 10 · Zero-Leak Security & 3-State Access Parity
- **Zero Secret Leak**: no tokens, credentials, or PII in git or GitHub comments.
- **3-State Parity**: Guest = 100% Room SQLite · Solo = personal cloud · Duo = shared real-time cloud.

---

### ⚡ Rule 11 · FinOps, Token Sobriety & Anti-Drift Checkpoints
- **Token Sobriety**: Prohibit endless trial-and-error loops; activate Circuit Breaker after 3 consecutive failures on the same issue.
- **Clean Context**: Delegate deep document scanning to read-only `research` subagents.
- **Anti-Cognitive Drift**: P1/P2 must verify Serene tokens (`DESIGN.md`) and 3-state isolation before plan sign-off.

---

### 🔒 Rule 12 · Strict WIP = 1 Concurrency Guardrail (Single Active Pair Policy)
- **Single Active Pair**: Exactly 1 active issue in `In Progress` and at most 1 PR in `In Review` at any time across the repository.
- **By-Design Concurrency Protection**: Eliminates race conditions and parallel merge conflicts on `strings.xml`, `AppDatabase.kt` and `firestore.rules`.
- **Pre-flight Check**: Running `gh pr list --state open` MUST return zero open PRs before creating any new branch or moving an issue to `In Progress`.

---

## 5. Inception Workflow (Chat-to-Issue)

```
User Request
    │
    ▼ P1: Anti-duplication (GitHubMCP:search_issues)
    │
    ▼ P1: Create sealed Issue + assign Priority/Estimate + link Milestone
    │
    ▼ P1: Kanban attachment (Backlog)
    │
    ├─▶ P2: Pillar 1 comment (Design Spec)
    ├─▶ P3: Pillar 2 comment (Data & Privacy Spec)
    └─▶ P4: Pillar 3 comment (Technical Blueprint) + assign Size/Estimate
    │
    ▼ P1: Cycle & Milestone linking → Kanban to Ready
    │
    ▼ User explicit approval (Rule 1.5 of agent-lifecycle.md)
    │
    ▼ Hand-off to Personas 5 & 6 (git-workflow.md)
```

---

## 6. Project Board State Machine

| Status | Meaning | Next Step |
|---|---|---|
| `Backlog` | Issue created, native fields assigned | Run `/plan-issue` |
| `Ready` | 4-Pillar plan validated, Cycle & Milestone linked | Create branch → code |
| `In Progress` | Active branch, Cycle & Metadata set | Finish tests, push |
| `In Review` | PR opened with Walkthrough (`Closes #<id>`) | CI gate & review |
| `Done` | PR merged on `main`, issue auto-closed | Sentinel audit (Rule B); P6 checks Milestone completion |
