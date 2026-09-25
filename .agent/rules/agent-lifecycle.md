# Agent Lifecycle & Operational Governance

> **Project**: Agentic Android Kernel (Android & Google Stitch)
> **Source of Truth**: `.agent/rules/agent-lifecycle.md`
> **Companion Rules**: [`backlog-planner.md`](backlog-planner.md) · [`git-workflow.md`](git-workflow.md) · [`agent.md`](../../agent.md)

---

## 1. Core Principles

Every task follows a strict **3-Phase Deterministic Lifecycle** executed by 6 Engineering Personas:

| Phase | Persona(s) | Consortium |
|---|---|---|
| **Phase 1 — Inception & Scoping** | P1 PM · P2 Design · P3 Privacy · P4 Architect | Inception |
| **Phase 2 — Construction & Isolation** | P5 Software Engineer | Delivery |
| **Phase 3 — Delivery, PR & Observability Sync** | P6 Release Manager | Delivery |

**Non-negotiable guardrails (all phases):**
- **Native tools only**: `replace_file_content`, `write_to_file`, `view_file`, `grep_search`, `find_by_name`. Zero transient shell scripts.
- **MCP-only for remote ops**: `GitHubMCP`, `firebase-mcp-server`, `StitchMCP`.
- **Zero Auto-Merge**: the agent never merges a PR without explicit user approval.
- **WIP = 1 (Single Active Pair)**: exactly 1 issue `In Progress` and at most 1 PR `In Review` at a time.
- **Rule A**: issue title, body, and branch type are immutable after creation (§ 2.1).

### 1.1 FinOps Guardrails, Circuit Breaker & Anti-Cognitive Drift

> [!IMPORTANT]
> **Token Sobriety & Anti-Loop Circuit Breaker**: Prevent infinite trial-and-error loops (*Token Burn*) and context degradation (*Context Bloating*).

1. **Circuit Breaker (Strict 3-Iteration Limit)**:
   - If a build error or unit test failure persists across **3 consecutive attempts** on the exact same root cause, the agent MUST immediately suspend code modifications.
   - Document the technical impasse: root cause hypothesis, the 3 attempts made, and why they failed.
   - Request developer arbitration before attempting any fourth change.
2. **Clean Context Delegation**:
   - Heavy exploratory tasks (mass codebase grep, deep documentation lookups, multi-file inspection) MUST be delegated to read-only `research` subagents to keep the primary session's working memory clean.
3. **Anti-Cognitive Drift Checkpoints**:
   - Every **15 conversational turns** or before opening any UI/Architecture PR, the agent MUST perform a rapid adherence check against [`DESIGN.md`](../../DESIGN.md) (Serene Intellectual tokens: `#C2B2D6`, `#7E9F85`, `#5E4B66`, radii `SoftCard` 20dp, zero raw M3 drop shadows) and 3-state access parity (Guest local SQLite vs Solo vs Duo).

---

## 2. Phase 1 · Inception & Scoping (Personas 1–4)

### Step 1.0 · Anti-Duplication & Local Inception (P1 & P4)
**Rule 0 (JIT Issue-First)**: Zero code, branch, or premature GitHub issues before Gate 1.4.
- Anti-duplication first: `GitHubMCP:search_issues` → `{ "query": "repo:<owner>/<repo> is:issue <keywords>" }`
- P1 & P4 elaborate specification locally in `implementation_plan.md` artifact (`issue: null`, `RequestFeedback: true`).
- P4 consolidates `Size` (XS–XL) and `Estimate` into Pillar 3 before sealing.

### Step 1.1 · Rule A — Issue & Branch Immutability (Append-Only)

> [!CAUTION]
> **Issue title and initial body are permanently sealed upon creation (READ-ONLY).**

- `GitHubMCP:update_issue` targeting `title` or `body` is strictly forbidden.
- Branch type is immutable: a `feat/issue-<id>-*` stays `feat/` even if Phase 2 reveals bugs.
- Scope revisions/corrections MUST use `GitHubMCP:add_issue_comment`.

### Step 1.2 · 4-Pillar Spec Orchestration (P1 orchestrates P2–P4)
- **P1 Product Planner** → User Story (Gherkin) & 3-State Access Matrix (Guest/Solo/Duo).
- **P2 Design Lead** → Pillar 1: Material 3 tokens, WCAG 2.1 AAA, 4-state UI matrix, Roborazzi expectations (or `N/A — No visual/UI changes`).
- **P3 Privacy & Data Lead** → Pillar 2: Zero-PII telemetry, value bucketing, GDPR/AI Act compliance.
- **P4 System Architect** → Pillar 3: Room schema/DDL, Firestore rules delta, Clean MVI, infra locks, Size & Estimate.

### Step 1.3 · Gate 1.4 Approval & JIT Sealing (Rule 1.5)
- **Gate 1.4 Hard Stop**: **STOP AND WAIT**. Zero branches, code edits, or remote issue creation before explicit user approval.
- **JIT Sealing via CLI**: Upon user approval, execute:
  `./scripts/seal-issue.sh --from-plan [path_to_plan]`
  This creates the GitHub issue, applies native flags (`--milestone`, `--parent`), attaches Project v2 metadata (`Priority`, `Size`, `Estimate`, `Status: Ready`), and initializes `epic/**` branch if Epic.

### Step 1.4 · Hand-off to Persona 5
Phase 1 is complete. Dedicated branch creation and source edits begin exclusively in Phase 2.

---

## 3. Phase 2 · Construction & Isolation (Persona 5)

### Step 2.1 · Dedicated Branch Creation (Branch-First Isolation & WIP = 1)
**WIP = 1 Pre-check**: `gh pr list --state open` must be empty. If an open PR exists, STOP until it merges.
Base branch resolution:
- Standalone / Epic: branched from `main`.
- Epic Child Task: branched from active parent branch (`epic/issue-<epic_id>-<slug>`).

```bash
git checkout <base_branch> && git pull origin <base_branch>
git checkout -b <type>/issue-<id>-<short-kebab-slug>
```
Kanban status transitions to `In Progress`.

**FORBIDDEN**: any file edit on `main` or `epic/*` or starting while another PR is open.

### Step 2.2 · Native Implementation
- **Clean MVI**: `data/model` → `data/repository` → `ui/viewmodel` (StateFlow) → `ui/components` (Compose).
- **Zero Hardcoded Strings**: 100% of user-facing text in `res/values/strings.xml` + `res/values-fr/strings.xml`.
- **3-State Access Parity**: Guest = 100% Room SQLite (zero unsolicited Firestore) · Solo = personal cloud · Duo = shared real-time sync.
- **Zero Secret Leak**: no token, key, or PII in commits, logs, or GitHub comments.
- **Native tools only**: `replace_file_content`, `write_to_file`, `view_file`. Zero transient shell scripts.

### Step 2.3 · Atomic Commits on Dedicated Branch
Format: `<type>(<scope>): <present-tense description>`
Push exclusively to `<type>/issue-<id>-<slug>`. Zero commits on `main` or `epic/*`.

### Step 2.4 · Hand-off to Persona 6
Phase 2 complete. Delivery and observability sync begin in Phase 3.

---

## 4. Phase 3 · Delivery, PR & Observability Sync (Persona 6)

### Step 3.1 · Pre-PR Quality Airbag
Mandatory before opening any PR:
```bash
./scripts/quality-check.sh   # or: ./gradlew codeSanityCheck
```
Acceptance: 0 Kotlin/Java errors · 0 Android Lint warnings · 100% unit & Robolectric tests · 100% Firestore rules tests.

### Step 3.2 · PR Creation with Walkthrough
Anti-duplicate & WIP check: `gh pr list --state open`

If no open PR:
```bash
git fetch origin <base_branch> && git rebase origin/<base_branch>
git push -u origin <type>/issue-<id>-<slug>
gh pr create --base <base_branch> --head <type>/issue-<id>-<slug> \
  --title "<type>(<scope>): <title>" --body-file ./walkthrough.md
```
- PR targets `epic/**` with `skip-release` for intermediate child PRs; `main` for standalone or consolidated Epic release PRs.
- Assign to `@me`. Never add PRs directly to Project board (board hygiene).
- PR body hosts **exclusively** the Walkthrough (`Closes #<id>`, files, test proofs, Roborazzi snapshots).
- **STOP & WAIT FOR USER APPROVAL (Gate 3.5)**.

### Step 3.3 · Zero Auto-Merge Rule

> [!CAUTION]
> The agent NEVER merges a PR autonomously. Present the PR link and stop. Merge only after the user says *"Tu peux merger"* or equivalent.

### Step 3.4 · Post-Merge Branch Cleanup & Dynamic Sync

> [!IMPORTANT]
> Mandatory remote branch deletion and base synchronization via post-merge hook.

Run the post-merge hook:
```bash
./.agent/hooks/post-merge-dual-sync.sh <pr_number>
```
This hook dynamically switches to the target base branch (`epic/**` or `main`), pulls latest, and cleans local/remote branches. Issue auto-closed by `Closes #<id>`. Kanban → `Done`.

### Step 3.5 · Crashlytics Dual-Sync Closure (P6 — mandatory for `source:crashlytics`)

> [!IMPORTANT]
> If the merged PR resolves an issue labeled `source:crashlytics` or containing a Firebase incident URL, Persona 6 MUST immediately close the Firebase incident.

1. Extract `issue_id` from the GitHub issue body (Firebase deep link field).
2. Close via MCP: `firebase-mcp-server:crashlytics_update_issue { "issue_id": "<id>", "state": "CLOSED" }`
3. Post resolution proof via `GitHubMCP:add_issue_comment`:
   `"✅ Crashlytics <id> closed. Build: <versionName> (versionCode: <versionCode>). Commit: <sha>."`

### Step 3.6 · Formal Chat Recap
Persona 6 concludes the mission with a structured chat summary detailing the closed GitHub Issue, merged PR, quality check results, Crashlytics status, and the list of modified files.

---

## 5. Kanban State Machine

| Status | Meaning | Trigger |
|---|---|---|
| `Backlog` | Issue created, pending 4-Pillar spec | Step 1.0 |
| `Ready` | Plan approved by user | Step 1.3 |
| `In Progress` | Dedicated branch active | Step 2.1 |
| `In Review` | PR opened with Walkthrough | Step 3.2 |
| `Done` | PR merged, issue auto-closed | Step 3.4 |
