---
name: open-pr
description: Native Antigravity delivery skill activated when implementation is complete or when asked to deliver, open PR, or merge. Validates quality airbag, generates structured walkthrough, auto-detects skip-release requirements, pushes branch, and opens PR with Zero Auto-Merge guardrail.
triggers:
  - "open pr"
  - "create pull request"
  - "open pull request"
  - "deliver"
  - "ship it"
  - "merge"
  - "/open-pr"
owner: Persona 6 (Release Manager)
consumers: [P6]
version: 2.0.0
---

# Skill: `open-pr` (Delivery Consortium — Persona 6)

Standardizes the closure, synchronization, and Pull Request opening phase for any intervention on **Agentic Android Kernel**. Driven by **Persona 6 (Release Manager)**.

> **Governance References**:
> - [`.agent/rules/agent-lifecycle.md`](../../rules/agent-lifecycle.md) — *Phase 3: Delivery & Release*
> - [`.agent/rules/git-workflow.md`](../../rules/git-workflow.md) — *Zero Auto-Merge, Branch Isolation*
> - Template: [`.agent/templates/pr-walkthrough.md`](../../templates/pr-walkthrough.md)

---

## 🎯 Sequential Execution Recipe

### Step 1: Pre-PR Quality Airbag (Mandatory)
Before pushing or generating the Walkthrough, run:
```bash
./scripts/quality-check.sh
./scripts/validate-docs.sh
```
Acceptance criteria:
- 0 Kotlin/Java compilation errors.
- 0 Android Lint warnings (debug & release).
- 100% unit and Robolectric tests passing.
- 100% Firestore security assertions valid.

### Step 2: Anti-Duplicate & WIP = 1 Concurrency Check
Ensure no other open PR exists on the repository (WIP = 1 rule):
```bash
gh pr list --state open
```
If an open PR exists, STOP. The active PR must be reviewed and merged first.

### Step 3: Rebase on Base Branch & Push Dedicated Branch
```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BASE_BRANCH="main" # Or epic/issue-<epic_id>-<slug> if child task
git fetch origin "$BASE_BRANCH" && git rebase "origin/$BASE_BRANCH"
git push -u origin "$CURRENT_BRANCH"
```

### Step 4: Generate Walkthrough from Template
Populate [`.agent/templates/pr-walkthrough.md`](../../templates/pr-walkthrough.md) in `./walkthrough.md`:
- Link source issue: `Closes #<issue_id>`
- Base branch: `{{BASE_BRANCH|main}}`
- Summary of changes
- Affected files and diff statistics
- Quality Airbag verification table
- Roborazzi visual diffs or N/A note
- Crashlytics Dual-Sync note (only if `source:crashlytics`)

### Step 5: Open Pull Request with Auto-Labeling (`skip-release`)
Inspect staged changes and conventional commit type:
- If type is `docs` or `chore(governance)`, OR
- If no files under `app/` are touched, OR
- If PR is an intermediate child task of an Epic:
**Append `--label "skip-release"`** (or pass `["skip-release"]` in labels array to MCP).

```json
GitHubMCP:create_pull_request {
  "owner": "@me",
  "repo": "<repo>",
  "title": "<type>(<scope>): <description>",
  "head": "<CURRENT_BRANCH>",
  "base": "<BASE_BRANCH>",
  "body": "..."
}
```

### Invariant: Board Hygiene — Zero Pull Requests on Project Board
> [!CAUTION]
> **Strict Board Hygiene**: Pull Requests MUST NEVER be added to the GitHub Project board (`Project Kanban`). The board tracks GitHub Issues exclusively. Pull Requests link to their tracking issue via `Closes #<id>` without creating project items. Never run `gh project item-add` on a PR.

### Step 6: Zero Auto-Merge Guardrail (STOP & WAIT)

> [!CAUTION]
> **Zero Auto-Merge Rule**: Persona 6 MUST NEVER merge the PR automatically. Present the PR link in chat and stop. Wait for explicit user approval (e.g. *"Tu peux merger"* / *"Approve merge"*).

### Step 7: Post-Merge Cleanup & Dual-Sync
Once user confirms merge:
1. Merge PR (squash): `GitHubMCP:merge_pull_request`
2. Run post-merge dual-sync hook:
   ```bash
   ./.agent/hooks/post-merge-dual-sync.sh <pr_number>
   ```
3. Clean local and remote branches.
