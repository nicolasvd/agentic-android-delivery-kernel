---
name: triage-feedback
description: Native Antigravity triage skill for 100% native MCP ingestion, 4-tier deduplication, and qualification of fatal crashes, non-fatal errors, and tester feedback into structured GitHub issues.
triggers:
  - "triage feedback"
  - "crashlytics incident"
  - "crash report"
  - "tester feedback"
  - "triage crash"
  - "non-fatal error"
  - "/triage-feedback"
owner: Persona 1 (Product Planner) · Persona 6 (Release Manager)
consumers: [P1, P4, P6]
version: 2.0.0
---

# Skill: `triage-feedback` (100% MCP Natif)

Standardizes the capture, multi-level deduplication, and integration of **fatal crashes**, **non-fatal Crashlytics errors**, and **Firebase App Distribution tester feedback** into the autonomous governance of **Agentic Android Kernel** via **`GitHubMCP`** and native Antigravity MCP tools.

> **Governance References**:
> - [`.agent/rules/backlog-planner.md`](../../rules/backlog-planner.md) — *Rule 1 (Anti-Duplicate), Rule 2 (Assignment), Rule 8 (Triage)*
> - [`.agent/templates/crashlytics-triage-issue.md`](../../templates/crashlytics-triage-issue.md) — *Crashlytics Issue Template*

---

## 🎯 1. Priority Qualification

| Tier | Category | Source & Impact | Target Labels | Project Priority |
|---|---|---|---|---|
| **CRITICAL** | Fatal Crash | Uncaught runtime crash | `["source:crashlytics", "bug"]` | `P0` |
| **HIGH** | Non-Fatal Error | Intercepted AI or sync failure | `["source:crashlytics", "bug"]` | `P1` |
| **NORMAL** | Tester Feedback | Firebase App Distribution feedback | `["source:tester-feedback", "bug"\|"feature"]` | `P1` or `P2` |

---

## 🔍 2. Deduplication & GitHub Action Flow

### Step 1: Anti-Duplicate Search (`GitHubMCP:search_issues`)
Search for open or closed issues matching the component, stack trace signature, or error message:
```json
GitHubMCP:search_issues {
  "q": "repo:<owner>/<repo> is:issue <Component or Keywords>"
}
```

### Step 2: Decision Matrix

* **Case A: Duplicate of an OPEN Issue**
  Call `GitHubMCP:add_issue_comment` on the open issue:
  ```json
  GitHubMCP:add_issue_comment {
    "owner": "@me",
    "repo": "<repo>",
    "issue_number": 42,
    "body": "### 📱 New Occurrence Detected\n- **Device**: Pixel 8, Android 15\n- **Context**: ..."
  }
  ```

* **Case B: Regression on a CLOSED Issue**
  Call `GitHubMCP:create_issue` referencing the regression:
  - Title: `bug(regression): [<Component>] <Description> (reopens #<id>)`
  - Assignee: `@me`
  - Labels: `["bug", "source:crashlytics"]`

* **Case C: Unseen Problem (New Issue)**
  Call `GitHubMCP:create_issue` using [`.agent/templates/crashlytics-triage-issue.md`](../../templates/crashlytics-triage-issue.md):
  - Assignee: `@me`
  - Body contains: deep link, device matrix, stack trace, and 4-Pillar fix plan.

### Step 3: Dual-Sync Closure Protocol (Post-PR Merge)
When the resolving PR is merged, Persona 6 closes the Crashlytics incident via `firebase-mcp-server:crashlytics_update_issue`:
```json
{
  "issue_id": "<FIREBASE_ISSUE_ID>",
  "state": "CLOSED"
}
```
Emits comment: `"✅ Crashlytics <id> closed. Build: <versionName> (<versionCode>). Commit: <sha>."`
