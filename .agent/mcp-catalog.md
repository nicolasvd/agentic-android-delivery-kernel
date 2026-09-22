---
version: 1.0.0
last_updated: 2026-09-04
security: zero-secrets — env var names only, never raw credentials
---

# MCP Catalog — Available Tool Interfaces

> This catalog lists only tool interfaces and **environment variable names**.
> Raw tokens, API keys, and credentials are NEVER documented here.
> All secrets are injected by the host environment at runtime.

---

## 1. GitHubMCP
**Runtime**: `npx -y @modelcontextprotocol/server-github`
**Env var**: `GITHUB_PERSONAL_ACCESS_TOKEN`
**Consumers**: P1, P2, P3, P4, P6

| Tool | Input (key fields) | Output | Persona |
|---|---|---|---|
| `search_issues` | `q: string` (e.g. `"repo:<o>/<r> is:issue <kw>"`) | `{ total_count, items }` | P1 |
| `create_issue` | `owner, repo, title, body, assignees?, labels?` | `{ number, html_url }` | P1 only |
| `add_issue_comment` | `owner, repo, issue_number, body` | `{ id, html_url }` | P1–P4, P6 |
| `create_pull_request` | `owner, repo, title, body, head, base` | `{ number, html_url }` | P6 only |
| `create_branch` | `owner, repo, branch, from_branch` | `{ ref, object.sha }` | P6 |
| `merge_pull_request` | `owner, repo, pull_number, merge_method` | `{ sha, merged }` | P6 — explicit approval only |

> [!CAUTION]
> `update_issue` targeting `title` or `body` is **strictly forbidden** (Rule A — Append-Only).

---

## 2. firebase-mcp-server
**Runtime**: `npx -y firebase-mcp-server`
**Env vars**: `FIREBASE_PROJECT_ID` · `GOOGLE_APPLICATION_CREDENTIALS` (path to service-account JSON — never committed)
**Consumers**: P6

| Tool | Input | Output | Usage |
|---|---|---|---|
| `crashlytics_get_issue` | `{ issue_id: string }` | `{ issue_id, state, title, impacted_users_count }` | Sentinel Audit (Rule B) |
| `crashlytics_update_issue` | `{ issue_id: string, state: "OPEN"\|"CLOSED" }` | `{ issue_id, state }` | Dual-Sync Closure |

**P6 Dual-Sync Closure sequence** (mandatory on merge of `source:crashlytics` PR):
1. `crashlytics_update_issue { issue_id, state: "CLOSED" }`
2. `add_issue_comment` → `"✅ Crashlytics <id> closed. Build: <versionName> (<versionCode>). Commit: <sha>."`

**P6 Sentinel Audit sequence** (weekly — Rule B):
1. Query: `label:source:crashlytics is:closed`
2. `crashlytics_get_issue` → if state is `OPEN`
3. `crashlytics_update_issue { state: "CLOSED" }`
4. `add_issue_comment` → `"🤖 Sentinel Audit [YYYY-MM-DD]: incident <id> auto-closed."`

---

## 3. StitchMCP
**Runtime**: `python3 scripts/stitch-mcp-server.py`
**Env var**: `STITCH_API_KEY`
**Consumers**: P2

| Tool | Input | Output | Usage |
|---|---|---|---|
| `list_screens` | `{ project_id?: string }` | `{ screens: [{ id, name, last_updated }] }` | Audit existing screens before design |
| `get_screen` | `{ screen_id: string }` | `{ id, name, components, tokens, last_updated }` | Inspect current layout before specifying diff |

**P2 Incremental Design Policy**:
- `list_screens` + `get_screen` MUST be called before any UI specification.
- Screen exists → specify diff only. New screen → full spec allowed.

---

## Security Constraints

| Rule | Enforcement |
|---|---|
| Zero secrets in comments | Never paste tokens or key file contents in GitHub issue comments |
| Credential injection | Host runtime injects env vars; never hardcode in agent code |
| RBAC | Each tool is restricted to the persona(s) listed above |
| Forbidden ops | `update_issue(title/body)`, auto-merge without human approval |
