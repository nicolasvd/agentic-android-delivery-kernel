Closes #<!-- ISSUE_ID -->

## 📌 Summary

**Branch**: `<!-- BRANCH_NAME -->` → `main`
**Type**: `<!-- TYPE(SCOPE) -->`
**Related Issue**: [#<!-- ISSUE_ID --> <!-- TITLE -->](https://github.com/<owner>/<repo>/issues/<!-- ISSUE_ID -->)

- <!-- Bullet 1: What changed and why -->
- <!-- Bullet 2 -->
- <!-- Bullet 3 -->

---

## 📂 Affected Files

| File | Diff | Role |
|---|---|---|
| `<!-- File path -->` | `+<!-- additions --> -<!-- deletions -->` | <!-- Architectural role --> |

---

## ✅ Quality Airbag — `./scripts/quality-check.sh`

| Check | Result |
|---|---|
| Kotlin / Java compilation | ✅ 0 errors |
| Android Lint (debug) | ✅ 0 warnings |
| Android Lint (release) | ✅ 0 warnings |
| Unit tests | ✅ <!-- count --> passed · 0 failed |
| Robolectric UI tests | ✅ <!-- count --> passed · 0 failed |
| Firestore security rules | ✅ <!-- count --> passed · 0 failed |
| `./scripts/validate-docs.sh` | ✅ 100% contracts valid |

---

## ⚡ FinOps & Agent Efficiency

| Metric | Measurement | Status |
|---|---|---|
| Conversation turns | <!-- count --> turns | ✅ Optimal (< 20) |
| Circuit Breaker | 0 trip (max 3 itérations) | ✅ Passed · No loop |
| Context Hygiene | Clean delegation (`research`) | ✅ Compliant |
| Design Drift Check | Tokens & 3-state access audited | ✅ Compliant |

---

## 📸 UI Snapshots / Roborazzi Visual Diffs

<!-- Describe snapshot diffs or specify "No UI changes introduced." -->

| Composable | Theme | State | Status |
|---|---|---|---|
| `<!-- ComposableName -->` | Light | Default | ✅ Unchanged / ⚠️ Updated / 🆕 New |

---

<!--
CRITICAL: The section below is strictly conditional.
OMIT THIS ENTIRE SECTION if this PR does not resolve an issue labeled 'source:crashlytics'.
Zero "N/A" lines or empty placeholders are permitted.
-->
## 🔥 Crashlytics Dual-Sync (strictly for source:crashlytics)

- **Firebase Incident ID**: `<!-- FIREBASE_ISSUE_ID -->`
- **Dual-Sync Status**: `<!-- OPEN | CLOSED by P6 upon merge -->`
- **Closure Command**: `firebase-mcp-server:crashlytics_update_issue { "issue_id": "<!-- FIREBASE_ISSUE_ID -->", "state": "CLOSED" }`

---

> [!CAUTION]
> **Zero Auto-Merge — Explicit approval required.**
> This PR will NOT be merged until the author explicitly confirms: *"Tu peux merger"* or equivalent.
> P6 presents this PR link and stops. Merge is a deliberate human action.
