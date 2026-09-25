# 📊 Zero-PII Analytics & Telemetry Taxonomy Contract

This document formalizes the telemetry structure, event taxonomy, and privacy invariants for applications built on the **Agentic Android Delivery Kernel**.

---

## 🛡️ 1. Privacy Principles & Ethics (Zero-PII)

The telemetry architecture of the Agentic Android Delivery Kernel enforces a strict **Privacy by Design** foundation:

1. **Zero Personally Identifiable Information (Zero-PII)**: User-generated content, free-form text, titles, notes, personal names, email addresses, and phone numbers are **strictly prohibited** in analytics event parameters.
2. **Cardinality Control & Bucketing**: All textual lengths, item quantities, and durations must be grouped into discrete intervals (e.g., `1-10`, `11-20`, `21-50`, `50+` or `0`, `1-5`, `6-15`, `16-30`, `30+`) to eliminate indirect user fingerprinting.
3. **Graceful Degradation & Offline Safety**: If the analytics provider is uninitialized, blocked by network configuration, or in airplane mode, the tracking layer safely encapsulates calls without causing runtime exceptions or blocking the main thread.

---

## 📈 2. Canonical User Properties

User properties capture macro-level application state without storing individual behavioral profiles:

| Property Key | Type | Example Values | Description |
|---|---|---|---|
| `access_state` | String | `guest`, `solo`, `duo` | Current access level within the 3-State Access Matrix. |
| `theme_preference` | String | `light`, `dark`, `system` | Active UI theme preference. |
| `account_link_state` | String | `anonymous`, `authenticated_solo`, `paired_shared` | Identity and authentication topology. |
| `active_entities_bucket` | String | `0`, `1-5`, `6-15`, `16-30`, `30+` | Total volume of active domain entities managed by the user. |
| `engagement_streak_bucket` | String | `0`, `1-3`, `4-7`, `8-14`, `15-30`, `30+` | Daily usage and prioritization streak interval. |

---

## 🏷️ 3. Event Taxonomy by Functional Domain

### 🧠 A. AI Assistance & Two-Tier Classification

Telemetry events measuring the accuracy, latency, and user adoption of AI suggestions:

| Event Name | Parameters | Description |
|---|---|---|
| `ai_classification_triggered` | `input_length_bucket` (String: `1-10`, `11-20`, `21-50`, `50+`)<br>`has_context` (Boolean) | Triggered when cognitive evaluation of an input starts. |
| `ai_suggestion_presented` | `source` (String: `heuristic`, `cloud_llm`)<br>`suggested_category` (String)<br>`suggested_priority` (String)<br>`confidence_bucket` (String: `high`, `medium`, `low`) | Emitted when an AI recommendation is displayed in the UI. |
| `ai_suggestion_applied` | `category` (String)<br>`priority` (String)<br>`source` (String)<br>`time_to_apply_ms` (Long) | Recorded when the user applies an AI suggestion with a 1-tap interaction. |
| `ai_suggestion_dismissed` | `suggested_category` (String)<br>`manual_override_selected` (String)<br>`source` (String) | Recorded when the user dismisses or manually overrides the AI recommendation. |

---

### 📝 B. Entity Lifecycle & Data Operations

Lifecycle events tracking the creation, mutation, and completion of domain entities:

| Event Name | Parameters | Description |
|---|---|---|
| `quick_capture_submitted` | `char_count_bucket` (String: `1-20`, `21-50`, `51-100`, `100+`)<br>`has_details` (Boolean) | Rapid thought or item capture from entry surfaces. |
| `entity_created` | `category` (String)<br>`priority_tier` (String)<br>`is_shared` (Boolean)<br>`is_ai_assisted` (Boolean) | Creation and persistence of a new domain entity. |
| `entity_updated` | `category` (String)<br>`changed_category` (Boolean)<br>`changed_priority` (Boolean)<br>`is_shared` (Boolean) | Mutation of existing entity attributes. |
| `entity_deleted` | `category` (String)<br>`was_completed` (Boolean)<br>`was_shared` (Boolean) | Entity deletion from local or remote stores. |
| `entity_completed` | `category` (String)<br>`priority_tier` (String)<br>`is_shared` (Boolean) | Marking an entity as resolved or completed. |
| `entity_reopened` | `category` (String)<br>`is_shared` (Boolean) | Reopening a previously completed entity. |
| `entity_filter_applied` | `filter_mode` (String: `all`, `shared`, `personal`, `priority`)<br>`results_count_bucket` (String) | Filtering entity lists or collection views. |

---

### 🧭 C. Priority Matrix & Workflow State

Events monitoring workflow state transitions and daily prioritization:

| Event Name | Parameters | Description |
|---|---|---|
| `priority_item_toggled` | `action` (String: `added`, `removed`)<br>`current_priority_count` (Int)<br>`category` (String) | Adding or removing an item from primary focus. |
| `priority_limit_reached` | `max_limit` (Int)<br>`active_items_count` (Int) | User notification when attempting to exceed daily focus caps. |
| `priority_batch_reset` | `previous_count` (Int) | Scheduled or manual reset of high-priority focus items. |
| `workflow_state_reassigned` | `previous_state` (String, opt)<br>`target_state` (String)<br>`category` (String) | Moving an entity across workflow states or quadrants. |

---

### 👫 D. Duo Collaboration & Real-Time Sync

Telemetry covering shared state, pairing rituals, and collaborative interactions:

| Event Name | Parameters | Description |
|---|---|---|
| `pairing_invite_generated` | `is_regenerated` (Boolean) | Generating a secure pairing or invitation code. |
| `pairing_join_attempted` | `code_format_valid` (Boolean) | Submitting an invitation code to join a shared workspace. |
| `pairing_success` | `method` (String: `invite_code`, `qr`, `link`) | Successful establishment of a shared session. |
| `pairing_failed` | `error_reason` (String) | Pairing error (expired token, mismatched version, already linked). |
| `pairing_disconnected` | `active_shared_count` (Int) | Unlinking from a shared workspace. |
| `collaborator_interaction` | `action` (String)<br>`category` (String)<br>`is_completed` (Boolean) | Collaborative action or support vote on a shared item. |
| `shared_ledger_viewed` | `active_dimension` (String)<br>`total_shared_items` (Int) | Inspecting shared collaboration metrics or ledgers. |
| `shared_privacy_updated` | `privacy_mode` (String) | Updating visibility or permission rules for shared data. |

---

### 🔐 E. Authentication, Soft-Gating & System Settings

Core system lifecycle, authentication flows, and accessibility preferences:

| Event Name | Parameters | Description |
|---|---|---|
| `screen_view` | `screen_name` (String)<br>`screen_class` (String)<br>`access_state` (String)<br>`active_items_bucket` (String) | Screen navigation tracking. |
| `sign_in_started` | `source` (String) | Initiating an authentication provider flow. |
| `sign_in_success` | `provider` (String: `google`, `credential`) | Successful identity authentication. |
| `sign_in_failed` | `error_type` (String)<br>`error_message` (String) | Authentication failure or cancellation. |
| `sign_out` | `previous_access_state` (String) | User-initiated sign-out. |
| `soft_gate_prompt_shown` | `trigger_feature` (String)<br>`target_state` (String) | Prompting an unauthenticated user to sign in or pair. |
| `theme_changed` | `new_theme` (String)<br>`previous_theme` (String, opt) | Theme mode change (Light, Dark, System). |

---

### 🔁 F. Recurrence, Scheduling & Workload Rotation

Events governing temporal rules, recurring schedules, and collaborative rotation:

| Event Name | Parameters | Description |
|---|---|---|
| `entity_due_date_set` | `is_preset` (Boolean)<br>`preset_type` (String, opt)<br>`is_recurring` (Boolean)<br>`days_until_due_bucket` (String, opt) | Setting a deadline or due date on an entity. |
| `recurring_rule_created` | `frequency` (String: `daily`, `weekly`, `monthly`, `custom`)<br>`is_shared_rotating` (Boolean)<br>`category` (String) | Creating an automated recurrence schedule. |
| `recurring_cycle_completed` | `frequency` (String)<br>`cycle_count` (Int)<br>`is_shared_rotating` (Boolean) | Completing a cycle and generating the next scheduled instance. |
| `rotation_assigned` | `frequency` (String)<br>`cycle_count` (Int)<br>`next_assignee_role` (String: `partner`, `self`, `team`) | Automatic rotation of responsibility across collaborators. |

---

## 🧪 4. Automated Verification

All analytics events and parameter bundle builders must be validated with unit tests verifying:
1. Zero PII parameter keys and value formats.
2. Proper bucketing of numeric and length inputs.
3. Safe execution when analytics dependencies are mocked or disabled.

```bash
./gradlew testDebugUnitTest --tests "*AnalyticsTrackerTest*"
```
