---
template: 4-pillar-spec
version: 2.0.0
usage: Post as GitHubMCP:add_issue_comment on the tracking issue after P1 creates the sealed issue.
---

# 4-Pillar Inception Spec — Issue #{{ISSUE_ID}}: {{ISSUE_TITLE}}

## P1 · Product Spec & User Story (P1 — Product Planner)

### User Story (Gherkin)
```gherkin
Feature: {{FEATURE_NAME}}

  Scenario: {{NOMINAL_SCENARIO_TITLE}}
    Given {{PRECONDITION}}
    When  {{USER_ACTION}}
    Then  {{EXPECTED_OUTCOME}}

  Scenario: Offline / Unauthenticated fallback
    Given the device has no network or user is Guest
    When  {{USER_ACTION}}
    Then  {{GRACEFUL_DEGRADATION_BEHAVIOR}}
```

### 3-State Access Matrix
| State | Behavior |
|---|---|
| **Guest** | {{GUEST_BEHAVIOR}} — 100% Room SQLite, zero unsolicited Firestore calls |
| **Solo** | {{SOLO_BEHAVIOR}} — personal Firestore namespace only |
| **Duo** | {{DUO_BEHAVIOR}} — shared real-time Firestore sync |

### Acceptance Criteria
- [ ] {{ACCEPTANCE_CRITERION_1}}
- [ ] {{ACCEPTANCE_CRITERION_2}}
- [ ] All 3-State behaviors validated (Guest · Solo · Duo).
- [ ] Zero regressions on existing Roborazzi snapshots.
- [ ] `./scripts/quality-check.sh` exits 0.

**Metadata**: **Milestone**: `{{MILESTONE_NAME}}` · **Cycle**: `{{CYCLE_NAME}}` · **Business Value**: `{{BUSINESS_VALUE}}`

---

## Pillar 1 · Design Spec (P2 — Design Lead)
*(If non-UI or explicitly overridden: `N/A — No visual/UI changes`)*

**Impacted screens**:
| Screen ID | Composable | Change Type |
|---|---|---|
| `{{SCREEN_ID}}` | `{{COMPOSABLE_FILE}}` | New · Modified · Unchanged |

**Material 3 token mapping**:
| Role | Light Token | Dark Token |
|---|---|---|
| Primary | `{{PRIMARY_LIGHT}}` | `{{PRIMARY_DARK}}` |
| Surface | `colorScheme.surface` | `colorScheme.surface` |

**4-State UI matrix**:
| State | Specification |
|---|---|
| Default | {{DEFAULT_STATE_SPEC}} |
| Loading | Skeleton shimmer — `ShimmerBox` |
| Empty | `{{EMPTY_ILLUSTRATION}}` + CTA `@string/{{EMPTY_CTA_STRING_KEY}}` |
| Error | Snackbar + retry — `@string/{{ERROR_MESSAGE_STRING_KEY}}` |

**Accessibility**: `48dp` (CTA) / `56dp` (FAB) · WCAG 2.1 AAA.
**Motion**: `{{ENTER_TRANSITION_SPEC}}` — `{{DURATION_MS}}`ms `{{EASING}}`.
**Roborazzi snapshots**: `{{COMPOSABLE_NAME}}` × `{{THEMES}}` × `{{STATES}}`.

---

## Pillar 2 · Data & Privacy Spec (P3 — Privacy & Data Lead)

**Tracking events**:
| Event Name | Trigger | Required Params | Forbidden |
|---|---|---|---|
| `{{EVENT_NAME}}` | {{TRIGGER}} | `{{PARAM}}: {{BUCKET_VALUE}}` | `user_id`, free text |

**User properties**: `{{PROP_NAME}}`: `{{ALLOWED_VALUES}}`
**Compliance**: Zero-PII ✅ · GDPR: `{{GDPR_BASIS}}` · AI Act: `{{INFERENCE_BUCKETING_STRATEGY}}`
**Test contract**:
- [ ] `{{EventName}}TrackingTest` (params & types)
- [ ] Negative test (zero PII in payload)

---

## Pillar 3 · Technical Blueprint (P4 — System Architect)

**Tech Complexity**: `{{XS_S_M_L}}` · **Breaking change**: `{{YES_NO}}`

**Data layer**:
- Room entity delta: `{{ENTITY_CHANGES}}`
- Migration: `{{DB_VERSION_FROM}} → {{DB_VERSION_TO}}` · DDL: `{{DDL_STATEMENT}}`
- Firestore path: `{{FIRESTORE_COLLECTION_PATH}}`
- Security rule delta: `{{RULE_DIFF_OR_NO_CHANGE}}`

**Domain layer**:
- Use Cases: `{{USE_CASE_LIST}}`
- Concurrency: `suspend fun` + `Dispatchers.IO` / `Flow` / `StateFlow`

**Presentation layer**:
- ViewModel `UiState` delta: `{{UISTATE_CHANGES}}`
- New Intents/Events: `{{INTENT_LIST}}`

**Test strategy**:
- Unit: `{{REPO_MOCK_TESTS}}` · ViewModel state machine: `{{VM_TESTS}}`
- Room in-memory: `{{DAO_TESTS}}`
- Roborazzi: `{{SNAPSHOT_TESTS}}`
- Security rules: `node scripts/test-firestore-rules.mjs`

**Infrastructure locks**: `{{INFRA_FILES_TOUCHED}}` _(flag concurrent branch conflicts: `AppDatabase.kt`, `firestore.rules`, `strings.xml`)_

---

## 🪞 Dual-Write IDE Mirror State Header (`implementation_plan.md`)

When mirroring into `implementation_plan.md`, prepend this YAML state block:

```yaml
---
status: {{proposed|approved|in_progress|in_review|completed}}
issue: {{ISSUE_ID}}
type: {{TYPE}}
scope: {{SCOPE}}
branch: {{BRANCH_NAME}}
gate: {{CURRENT_GATE}}
pr: {{PR_NUMBER_OR_NULL}}
milestone: "{{MILESTONE_NAME}}"
cycle: "{{CYCLE_NAME}}"
metadata:
  business_value: "{{BUSINESS_VALUE}}"
  tech_complexity: "{{TECH_COMPLEXITY}}"
  severity: {{SEVERITY_OR_NULL}}
---
```
