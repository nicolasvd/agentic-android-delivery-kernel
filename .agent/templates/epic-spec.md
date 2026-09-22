---
template: epic-spec
version: 1.0.0
usage: Use for Complexity L issues. Post as GitHubMCP:add_issue_comment on the parent Epic.
guardrail: Zero Branch on Epic — child issues must be created for implementation.
---

# Epic Architectural Spec: #{{EPIC_ID}} — {{EPIC_TITLE}}

> **Zero Branch Guardrail**: This issue is an architectural container.
> Creating branches or committing code directly on #{{EPIC_ID}} is **strictly forbidden**.
> Implementation proceeds exclusively via atomic child issues (< 300 diff lines) merged sequentially to `main`.

---

## 🎯 1. Vision & Strategic Objectives

- **Goal**: {{EPIC_GOAL_SUMMARY}}
- **Business Value ⭐**: {{BUSINESS_VALUE}}
- **Tech Complexity 🧩**: `L - Architectural 🔴`
- **Target Milestone**: `{{MILESTONE_NAME}}`

---

## 🏛️ 2. Architectural Bounds & Invariants

- **Boundary Limits**: {{MODULES_OR_PACKAGES_AFFECTED}}
- **Expand/Contract DB Protocol**: {{EXPAND_CONTRACT_REQUIRED_YES_NO}}
- **Concurrency & State**: {{CONCURRENCY_MODEL}}
- **Cloud Security**: {{FIRESTORE_RULES_DELTA_SUMMARY}}

---

## 🗺️ 3. Sequential Decomposition DAG

Child issues must be implemented in topological order. Intermediate child PRs carry the `skip-release` label to merge silently without triggering tags or distribution builds.

| Seq | Issue Title | Type | Target Diff | Depends On | Silent (`skip-release`) |
|:---|:---|:---|:---|:---|:---|
| 01 | `{{CHILD_1_TITLE}}` | `{{TYPE}}` | < 300 lines | None | ✅ Yes |
| 02 | `{{CHILD_2_TITLE}}` | `{{TYPE}}` | < 300 lines | Step 01 | ✅ Yes |
| 03 | `{{CHILD_3_TITLE}}` | `{{TYPE}}` | < 300 lines | Step 02 | ❌ No (Triggers Release) |

---

## 📋 4. Child Issues Checklist

- [ ] #{{CHILD_1_ID}} — `{{CHILD_1_TITLE}}` (parent: #{{EPIC_ID}})
- [ ] #{{CHILD_2_ID}} — `{{CHILD_2_TITLE}}` (parent: #{{EPIC_ID}})
- [ ] #{{CHILD_3_ID}} — `{{CHILD_3_TITLE}}` (parent: #{{EPIC_ID}})

---

## ✅ 5. Definition of Done (Epic Level)

- [ ] All child issues merged sequentially into `main` with 100% CI pass.
- [ ] Expand/Contract phases validated (Phase 1 Expand tests pass; Phase 2 Contract safely executed).
- [ ] Zero regressions in existing Roborazzi snapshots and Firestore security rules.
- [ ] Final child PR merged without `skip-release` label, successfully cutting release.
- [ ] Milestone completion check passed; Epic issue #{{EPIC_ID}} closed.
