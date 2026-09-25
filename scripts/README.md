# 🛠️ Automation Scripts — Agentic Android Kernel

This directory contains all **atomic scripts** and **orchestrators** for the **Agentic Android Kernel** project.

> 📖 **Comprehensive Documentation & Detailed Architecture:**  
> See [**`docs/scripts-reference.md`**](../docs/scripts-reference.md) for exhaustive reference sheets, CLI options, and the composition matrix.

---

## ⚡ Quick Script Index

| Script | Language | Concise Description | Command |
|---|---|---|---|
| [`validate-docs.sh`](validate-docs.sh) | Bash | Validates presence and contract conformance of specifications (`DESIGN.md`, playbooks, skills, rules) | `./scripts/validate-docs.sh` |
| [`quality-check.sh`](quality-check.sh) | Bash | Executes the complete Kotlin/Java compilation, Android Lint, and unit/UI test suite | `./scripts/quality-check.sh` |
| [`test-runtime-guardrails.mjs`](test-runtime-guardrails.mjs) | Node.js | Runs 18 security assertions on runtime guardrails (`branch-guard.mjs`, `plan-guard.mjs`) | `node scripts/test-runtime-guardrails.mjs` |
| [`install-hooks.sh`](install-hooks.sh) | Bash | Binds local Git hooks to `.agent/hooks/` and enables the pre-commit airbag | `./scripts/install-hooks.sh` |
| [`deploy-app-distribution.sh`](deploy-app-distribution.sh) | Bash | Builds and deploys APK to Firebase App Distribution with monotonic version multiplier (x100) | `./scripts/deploy-app-distribution.sh` |
| [`generate-screenshots.sh`](generate-screenshots.sh) | Bash | Generates Roborazzi screenshots for the Design System | `./scripts/generate-screenshots.sh` |
| [`upload-screenshots.py`](upload-screenshots.py) | Python | Validates and maps Roborazzi screenshots to Google Stitch screens | `python3 scripts/upload-screenshots.py --check-only` |
| [`inspect-ide.sh`](inspect-ide.sh) | Bash | Runs Android Studio / IntelliJ inspections in headless mode | `./scripts/inspect-ide.sh` |

---

## 🎯 Composition by Semantic Skills ([`.agent/skills/`](../.agent/skills/))

Each script fulfills a single responsibility. End-to-end workflows are driven by the agent's native semantic skills:
- **`quality-airbag`** (`/quality-check`) ➔ `validate-docs.sh` + `quality-check.sh` + `test-runtime-guardrails.mjs`
- **`sync-stitch`** (`/sync-stitch`) ➔ `validate-docs.sh` + `generate-screenshots.sh` + `upload-screenshots.py`
- **`distribute-local`** (`/distribute-local`) ➔ `quality-check.sh` + `deploy-app-distribution.sh`
- **`open-pr`** (`/open-pr`) ➔ `quality-check.sh` + Walkthrough & PR creation
- **`triage-feedback`** (`/triage-feedback`) ➔ 100% native MCP (`GitHubMCP`: `search_issues`, `add_issue_comment`, `create_issue`)
