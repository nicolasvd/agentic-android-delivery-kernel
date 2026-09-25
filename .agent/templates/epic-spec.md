---
template: epic-spec
version: 2.0.0
usage: Authoritative sealed body for Epic Issues created at Gate 1.4 via scripts/seal-issue.sh.
guardrail: Epic Branch Isolation — child tasks branch from and merge into epic/issue-<id>-<slug>.
---

# Epic Architectural Spec: #{{EPIC_ID}} — {{EPIC_TITLE}}

> **Epic Branch Isolation Guardrail**: This issue is an architectural container.
> An isolated integration branch `epic/issue-{{EPIC_ID}}-{{EPIC_SLUG}}` is created upon sealing.
> Direct commits on `epic/**` are strictly forbidden. Implementation proceeds via atomic child issues (< 300 diff lines) branching from and merging into the Epic integration branch before a final release PR lands on `main`.

---

## 🎯 1. Vision & Strategic Objectives

- **Goal**: {{EPIC_GOAL_SUMMARY}}
- **Core Value & User Impact**: {{VALUE_PROPOSITION_SUMMARY}}
- **Target Scope**: {{FUNCTIONAL_SCOPE_SUMMARY}}

---

## 🏛️ 2. Architectural Bounds & Invariants

- **Boundary Limits**: {{MODULES_OR_PACKAGES_AFFECTED}}
- **Expand/Contract DB Protocol**: {{EXPAND_CONTRACT_REQUIRED_YES_NO}}
- **Concurrency & State**: {{CONCURRENCY_MODEL}}
- **Cloud Security**: {{FIRESTORE_RULES_DELTA_SUMMARY}}

---

## 🗺️ 3. Sequential Decomposition DAG

Child issues must be implemented in topological order with strict WIP = 1. Child PRs target the Epic integration branch with `skip-release`.

| Seq | Child Issue Title | Type | Target Diff | Depends On | PR Base Target |
|:---|:---|:---|:---|:---|:---|
| 01 | `{{CHILD_1_TITLE}}` | `{{TYPE}}` | < 300 lines | None | `epic/issue-{{EPIC_ID}}-...` |
| 02 | `{{CHILD_2_TITLE}}` | `{{TYPE}}` | < 300 lines | Step 01 | `epic/issue-{{EPIC_ID}}-...` |
| 03 | `{{CHILD_3_TITLE}}` | `{{TYPE}}` | < 300 lines | Step 02 | `epic/issue-{{EPIC_ID}}-...` |

---

## 📋 4. Native Sub-Issues Architecture

Child tasks are sealed sequentially via JIT (`./scripts/seal-issue.sh --from-plan`) with native `--parent {{EPIC_ID}}`.
Tracking, status, and completion roll-ups are managed natively via GitHub's Sub-issues hierarchy on this ticket.

---

## ✅ 5. Definition of Done (Epic Level)

- [ ] All child issues merged sequentially into `epic/issue-{{EPIC_ID}}-{{EPIC_SLUG}}` with 100% CI pass.
- [ ] Expand/Contract phases validated (Phase 1 Expand tests pass; Phase 2 Contract safely executed).
- [ ] Zero regressions in existing Roborazzi snapshots and Firestore security rules.
- [ ] Full Quality Airbag passed on the consolidated Epic integration branch.
- [ ] Final Epic PR (`epic/issue-{{EPIC_ID}}-... → main`) merged with consolidated commit message closing #{{EPIC_ID}} and all child issues.
- [ ] Epic issue #{{EPIC_ID}} closed; release train successfully triggered.
