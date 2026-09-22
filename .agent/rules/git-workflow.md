# Git Workflow & Release Execution — Personas 5 & 6

> **Scope**: Native code execution, testing, branch lifecycle, release validation, and deployment.
> **Companion rules**: [`backlog-planner.md`](backlog-planner.md) · [`agent-lifecycle.md`](agent-lifecycle.md) · [`agent.md`](../../agent.md)

---

## 1. Persona I/O Contracts

### Persona 5 · Software Engineer (Developer)
| | Detail |
|---|---|
| **Inputs** | Approved 4-Pillar Issue spec (Pillars 1–4 comments), `.agent/rules/agent-lifecycle.md`, `app/src/main/res/values/strings.xml` |
| **Responsibilities** | Native Kotlin/Compose implementation (Clean MVI); Zero Hardcoded Strings; unit + Robolectric Compose tests; atomic commits on dedicated branch |
| **Outputs** | Working application code, updated test suite, local commits on `<type>/issue-<id>-<slug>` |
| **Tools** | `replace_file_content`, `write_to_file`, `view_file`, `grep_search`, `find_by_name` |

### Persona 6 · Release Manager (Delivery & Platform)
| | Detail |
|---|---|
| **Inputs** | Dedicated branch from Persona 5, git status, CI feedback, GitHub Milestone completion status |
| **Responsibilities** | Branch immutability, monotonic `versionCode`, pre-PR Airbag, PR creation, **Immediate Crashlytics Dual-Sync Closure**, Tier 1 continuous distribution, **Tier 2 Milestone Release Train**, clean release asset guardrails |
| **Outputs** | PR with Walkthrough, Firebase App Distribution build, Crashlytics closure, SemVer tag (Milestone-gated), GitHub Release (binaries only) |
| **Tools** | `run_command`, `firebase-mcp-server:crashlytics_update_issue`, `GitHubMCP:create_pull_request`, `GitHubMCP:add_issue_comment` |

---

## 2. Core Principles

- **Protected `main` Branch**: NEVER commit or push directly to `main`.

- **Zero Auto-Merge**:
  > [!CAUTION]
  > The agent NEVER merges a PR without explicit user approval. Present the PR link and stop. Merge only after the user says *"Tu peux merger"* or equivalent.

- **One Branch per Task / Issue**: every modification begins with `<type>/issue-<id>-<slug>` cut from up-to-date `main`.

- **Branch & Type Immutability** (Rule A from `backlog-planner.md`):
  > [!CAUTION]
  > Branch names and types are immutable. A `feat/issue-<id>-*` stays `feat/` even if Phase 2 reveals bugs. Never rename a branch mid-flight. All scope revisions go as new comments on the GitHub Issue via `GitHubMCP:add_issue_comment`.

- **Zero Commits on Closed / Merged Branches**:
  > [!CAUTION]
  > Once a PR is merged, the branch is dead. Delete it locally and remotely immediately. Return to `main`, pull, then open a new Issue + branch for any follow-up.

- **Issue vs PR Separation**: Issue = 4-Pillar Plan · PR = Walkthrough (`Closes #<id>`). All `gh` rich-text bodies use `--body-file`. Zero heredocs.

- **Mandatory Quality Gate**: every commit/push must pass `./scripts/quality-check.sh`.

---

## 3. Branch Naming Convention

```
Issue-tracked : <type>/issue-<id>-<short-kebab-description>
Standalone    : <type>/<short-kebab-description>
```

Types: `feature` · `enhancement` · `bug` · `refactor` · `chore` · `documentation`

---

## 4. Commit Convention & Semantic Versioning (SemVer)

Format: `<type>(<scope>): <present-tense description>`

| Impact | Trigger |
|---|---|
| Patch (`v0.0.1→v0.0.2`) | `bug:` · `chore:` · `documentation:` · `refactor:` · `#patch` |
| Minor (`v0.0.1→v0.1.0`) | `feature:` · `enhancement:` · `#minor` |
| Major (`v0.0.1→v1.0.0`) | `BREAKING CHANGE:` · `feature!:` · `#major` |

### Git-Driven Android Versioning
- **`versionCode`** — Monotonic Multiplier (×100):
  `versionCode = (baseMainCommitCount × 100) + min(commitsAheadOfMain, 99)`
- **`versionName`** — from latest semantic git tag: `git describe --tags --always` (no `v` prefix).

---

## 5. Two-Tier Release Cadence (Persona 6)

### Tier 1 · Continuous Dev Distribution (Every Merge to `main`)
- **Trigger**: every squash-merge PR landing on `main`.
- **Action**: CI compiles the debug APK and uploads to Firebase App Distribution (`admin, testers`).
- **Guardrails**: Zero git tags created. Zero GitHub Releases created. Internal tooling only.
- **Purpose**: continuous tester coverage without polluting the release history.

### Tier 2 · Milestone Release Train (Milestone 100% Complete)
- **Trigger**: Persona 6 verifies that a GitHub Milestone has reached **100% closed issues**.
  ```bash
  # Verify milestone completion before cutting the tag
  gh milestone list --repo <owner>/<repo>
  gh issue list --milestone "<Milestone Name>" --state open
  # Proceed only if: 0 open issues in milestone
  ```
- **Action sequence**:
  1. Cut the official SemVer git tag (`vX.Y.Z`) and push it.
  2. Create the GitHub Release — **binaries and checksums only** (see Clean Release Assets below).
  3. Attach the signed APK and `checksums.sha256`.
  4. Post release announcement.
- **Milestone ownership**: Persona 1 creates and scopes Milestones. Persona 6 validates completion and closes them post-release.

---

## 6. Feature Development Lifecycle

### Phase A — Implementation (Persona 5)
1. **Branch creation & In-Progress Sync**:
   ```bash
   git checkout main && git pull
   git checkout -b <type>/issue-<id>-<slug>
   # Automatically triggered in background via .agent/hooks/post-checkout (or run manually):
   node .agent/sidecars/sync-issue-progress.mjs <id>
   ```
   > **Automated Sidecar Binding**: The Git hook `.agent/hooks/post-checkout` triggers `.agent/sidecars/sync-issue-progress.mjs <id>` in the background upon checkout, binding the open milestone, active cycle, and moving the issue to **"In Progress"** on GitHub Project #1.
2. **Implementation**: Clean MVI (`data/model → data/repository → ui/viewmodel → ui/components`). Zero hardcoded strings. 3-State Access parity.
3. **Atomic commits** exclusively on `<type>/issue-<id>-<slug>`.

### Phase B — Release Preparation (Persona 6)
4. **Pre-PR Airbag**:
   ```bash
   ./scripts/quality-check.sh   # or ./gradlew codeSanityCheck
   ```
   Acceptance: 0 errors · 0 lint warnings · 100% tests · 100% Firestore rules.

5. **Push & anti-duplicate PR check**:
   ```bash
   git push -u origin <type>/issue-<id>-<slug>
   gh pr list --head <type>/issue-<id>-<slug> --state open
   ```

6. **PR with Walkthrough** (using [`.agent/templates/pr-walkthrough.md`](../templates/pr-walkthrough.md) via `--body-file`):
   ```bash
   gh pr create --base main --head <type>/issue-<id>-<slug> \
     --title "<type>(<scope>): <title>" --body-file ./walkthrough.md
   ```
   Assign to `@me`. Attach to "Project Kanban". **STOP & WAIT FOR USER APPROVAL**.

7. **Post-merge cleanup** (after explicit user approval):
   ```bash
   git checkout main && git pull origin main
   git branch -d <type>/issue-<id>-<slug>
   git push origin --delete <type>/issue-<id>-<slug>
   git fetch --prune
   ```

8. **Crashlytics Dual-Sync Closure** (mandatory if `source:crashlytics`):
   > [!IMPORTANT]
   > Immediately close the Firebase incident upon merge via [`.agent/hooks/post-merge-dual-sync.sh`](../hooks/post-merge-dual-sync.sh) or direct MCP:
   ```
   firebase-mcp-server:crashlytics_update_issue { "issue_id": "<id>", "state": "CLOSED" }
   GitHubMCP:add_issue_comment → "✅ Crashlytics <id> closed. Build: <versionName> (<versionCode>). Commit: <sha>."
   ```

9. **Milestone completion check** (Persona 6):
   After each merge, verify whether the Milestone is now 100% complete. If yes, trigger Tier 2 release.

---

## 7. Clean Release Asset Guardrails

> [!CAUTION]
> **GitHub Releases MUST NEVER attach internal documentation files.**

Allowed release attachments:
- ✅ `app-release.apk` (signed release binary)
- ✅ `app-debug.apk` (debug binary, if included)
- ✅ `checksums.sha256` (SHA-256 of all attached binaries)
- ✅ Auto-generated release notes (GitHub `generate_release_notes: true`)

Strictly forbidden from GitHub Release attachments:
- ⛔ `agent.md`
- ⛔ `DESIGN.md`
- ⛔ `design-system.md`
- ⛔ Any `.agent/rules/*.md`, `.agent/playbooks/*.md`, or `.agent/skills/*.md` file
- ⛔ Any internal markdown or governance document

Checksum generation (before GitHub Release attachment):
```bash
sha256sum app/build/outputs/apk/release/app-release.apk \
          app/build/outputs/apk/debug/app-debug.apk \
  > checksums.sha256
```

---

## 8. Automated CI/CD Architecture

### A. Delivery Pipeline & Quality Gate (`.github/workflows/delivery-pipeline.yml`)
Unified workflow for PR checks, `main` push quality gate, dev distribution, and milestone releases:
- **PR & Push `main`**: JDK 21 (Temurin) · `./scripts/validate-docs.sh` · `./gradlew codeSanityCheck`.
- Cache: `gradle/actions/setup-gradle@v4` with `cache-read-only: true`.

```
PR targeting main
    ──► Job 1: Quality Gate (codeSanityCheck + validate-docs.sh)

Push/Merge main (Tier 1)
    ──► Job 1: Quality Gate (codeSanityCheck + validate-docs.sh)
    ──► Job 2: Build + Firebase App Distribution (admin, testers) — NO tag, NO GitHub Release

Milestone 100% complete → manual trigger (Tier 2)
    ──► Job 3: SemVer tag (vX.Y.Z) + GitHub Release (APK + checksums only, zero internal docs)
```

### C. Local Distribution (Manual / Ad-hoc)
```bash
./scripts/deploy-app-distribution.sh                          # latest commit message
./scripts/deploy-app-distribution.sh "Fix Duo Mode sync"     # custom release notes
./scripts/deploy-app-distribution.sh "Release Notes" release # signed Release APK
```
