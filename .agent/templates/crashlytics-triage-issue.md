---
template: crashlytics-triage-issue
version: 1.0.0
usage: Use as the body for GitHubMCP:create_issue when triaging a Firebase Crashlytics incident.
labels: ["bug", "source:crashlytics"]
---

## 🚨 Severity: {{P0_BLOCKER|P1_MAJOR|P2_MINOR|P3_TRIVIAL}}

> **Severity guide**: `P0 - Blocker 💥` = app crash / data loss / security breach · `P1 - Major 🔴` = core feature broken, no workaround · `P2 - Minor 🟠` = degraded UX, workaround exists · `P3 - Trivial 🟢` = cosmetic / logging

---

## 🔗 Incident Reference

| Field | Value |
|---|---|
| **Firebase Issue ID** | `{{FIREBASE_ISSUE_ID}}` |
| **Firebase Deep Link** | [View in Crashlytics Console]({{FIREBASE_DEEP_LINK_URL}}) |
| **First Seen** | `{{FIRST_SEEN_DATE}}` |
| **Last Seen** | `{{LAST_SEEN_DATE}}` |
| **Status** | `OPEN` |

---

## 💥 Blast Radius

| Dimension | Value |
|---|---|
| **Impacted versions** | `{{APP_VERSION_RANGE}}` (versionCode `{{VERSION_CODE_RANGE}}`) |
| **Impacted users (bucket)** | `{{USER_COUNT_BUCKET}}` (e.g. `"1-5"`, `"6-10"`, `"10+"`) |
| **OS API levels** | `{{OS_API_LEVEL_RANGE}}` |
| **Access state affected** | Guest · Solo · Duo (circle all that apply) |
| **Crash rate** | `{{CRASH_RATE_PERCENT}}`% of sessions |

---

## 🧵 Crash Thread & Stack Trace

**Exception**: `{{EXCEPTION_CLASS}}: {{EXCEPTION_MESSAGE}}`
**Thread**: `{{THREAD_NAME}}`

```
{{STACK_TRACE_LINE_1}}
{{STACK_TRACE_LINE_2}}
{{STACK_TRACE_LINE_3}}
...
```

<details>
<summary>customKeys payload (Zero-PII — no raw user data)</summary>

```json
{{CUSTOM_KEYS_JSON}}
```
</details>

---

## 🔍 Reproduction & Root Cause Analysis

**Steps to reproduce**:
1. {{REPRO_STEP_1}}
2. {{REPRO_STEP_2}}

**Root cause hypothesis**: {{ROOT_CAUSE_HYPOTHESIS}}

**Minimal repro build**: `{{REPRO_BUILD_VERSION}}` (or N/A)

---

## 📐 4-Pillar Fix Plan (P4 blueprint)

- **Fix approach**: {{FIX_APPROACH}}
- **Impacted files**: `{{IMPACTED_FILES}}`
- **Room migration required**: `{{YES_NO}}`
- **Firestore rules delta**: `{{DIFF_OR_NO_CHANGE}}`
- **Regression tests to add**: `{{TEST_NAMES}}`

---

## ✅ P6 Dual-Sync Closure Checklist

Upon merging the fix PR:
- [ ] `firebase-mcp-server:crashlytics_update_issue { "issue_id": "{{FIREBASE_ISSUE_ID}}", "state": "CLOSED" }`
- [ ] `GitHubMCP:add_issue_comment` → `"✅ Crashlytics {{FIREBASE_ISSUE_ID}} closed. Build: <versionName> (<versionCode>). Commit: <sha>."`
- [ ] Kanban → `Done`. Milestone completion check (P6).
