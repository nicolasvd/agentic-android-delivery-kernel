---
template: pr-walkthrough
version: 2.0.0
usage: Pass as --body-file to `gh pr create`. Replace all {{PLACEHOLDER}} values before use.
status: {{in_review|completed}}
issue: {{ISSUE_ID}}
pr: {{PR_NUMBER}}
type: {{TYPE}}
scope: {{SCOPE}}
branch: {{BRANCH_NAME}}
airbag: {{passed|failed}}
zero_auto_merge_lock: active
---

Closes #{{ISSUE_ID}}

## 📌 Summary

**Branch**: `{{BRANCH_NAME}}` → `main`
**Type**: `{{TYPE}}({{SCOPE}})`
**Related Issue**: [#{{ISSUE_ID}} {{ISSUE_TITLE}}](https://github.com/{{OWNER}}/{{REPO}}/issues/{{ISSUE_ID}})

{{CHANGE_SUMMARY_BULLET_1}}
{{CHANGE_SUMMARY_BULLET_2}}
{{CHANGE_SUMMARY_BULLET_3}}

---

## 📂 Affected Files

| File | Diff | Role |
|---|---|---|
| `{{FILE_PATH_1}}` | `+{{INSERTIONS}} -{{DELETIONS}}` | {{ROLE_1}} |
| `{{FILE_PATH_2}}` | `+{{INSERTIONS}} -{{DELETIONS}}` | {{ROLE_2}} |

---

## ✅ Quality Airbag — `./scripts/quality-check.sh`

| Check | Result |
|---|---|
| Kotlin / Java compilation | ✅ 0 errors |
| Android Lint (debug) | ✅ 0 warnings |
| Android Lint (release) | ✅ 0 warnings |
| Unit tests | ✅ {{UNIT_TEST_COUNT}} passed · 0 failed |
| Robolectric UI tests | ✅ {{ROBOLECTRIC_TEST_COUNT}} passed · 0 failed |
| Firestore security rules | ✅ {{RULES_TEST_COUNT}} passed · 0 failed |
| `./scripts/validate-docs.sh` | ✅ {{DOC_CONTRACT_COUNT}}/{{DOC_CONTRACT_TOTAL}} contracts valid |

---

## ⚡ FinOps & Agent Efficiency

| Metric | Measurement | Status |
|---|---|---|
| Conversation turns | {{TURNS_COUNT}} turns | ✅ Optimal (< 20) |
| Circuit Breaker | 0 trip (max 3 itérations) | ✅ Passed · No loop |
| Context Hygiene | Clean delegation (`research`) | ✅ Compliant |
| Design Drift Check | Tokens & 3-state access audited | ✅ Compliant |

---

## 📸 UI Snapshots / Roborazzi Visual Diffs

{{ROBORAZZI_DIFF_DESCRIPTION}}

| Composable | Theme | State | Status |
|---|---|---|---|
| `{{COMPOSABLE_NAME}}` | Light | Default | ✅ Unchanged · ⚠️ Updated · 🆕 New |
| `{{COMPOSABLE_NAME}}` | Dark | Error | ✅ Unchanged · ⚠️ Updated · 🆕 New |

> Screenshot artifacts: [`main-code-inspection-reports`]({{CI_ARTIFACTS_URL}}) (uploaded by CI)

<!--
CRITICAL: The section below is strictly conditional.
OMIT THIS ENTIRE SECTION if this PR does not resolve an issue labeled 'source:crashlytics'.
Zero "N/A" lines or empty placeholders are permitted.
-->
## 🔥 Crashlytics Dual-Sync (strictly for source:crashlytics)

- **Firebase Incident ID**: `{{FIREBASE_INCIDENT_ID}}`
- **Dual-Sync Status**: `{{OPEN | CLOSED by P6 upon merge}}`
- **Closure Command**: `firebase-mcp-server:crashlytics_update_issue { "issue_id": "{{FIREBASE_INCIDENT_ID}}", "state": "CLOSED" }`

---

> [!CAUTION]
> **Zero Auto-Merge — Explicit approval required.**
> This PR will NOT be merged until the author explicitly confirms: *"Tu peux merger"* or equivalent.
> P6 presents this PR link and stops. Merge is a deliberate human action.
