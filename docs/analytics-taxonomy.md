# 📊 Analytics Taxonomy & Events (Zero-PII & Privacy-First)

This document formalizes the telemetry structure, event catalog, and parameters for the **Agentic Android Kernel**.

---

## 🛡️ 1. Privacy Principles & Ethics (Zero-PII)

The telemetry architecture of Agentic Android Kernel is designed under the strict principle of **Privacy by Design**:

1. **Zero Personally Identifiable Information (Zero-PII)**: Task titles, descriptions, personal names, email addresses, and user-generated text are **never** transmitted in analytics events.
2. **Bucketing / Value Ranges**: All text lengths and item counts are grouped into discrete intervals (e.g., `1-20`, `21-50`, `51-100`, `100+`) to prevent indirect fingerprinting through textual cardinality.
3. **Robust & Offline Behavior**: If Firebase Analytics is uninitialized or in airplane mode, the tracker safely encapsulates calls without causing crashes or blocking the UI (`FirebaseAnalyticsTracker`).

---

## 📈 2. User Properties

| Key | Type | Example Values | Description |
|---|---|---|---|
| `access_state` | String | `guest`, `solo`, `duo` | Current access state (Guest, Authenticated Solo, Paired Duo). |
| `theme_preference` | String | `light`, `dark`, `system` | Display theme preference. |
| `is_partner_linked` | Boolean | `true`, `false` | Indicates whether the account is paired with a partner. |
| `active_loads_bucket` | String | `0`, `1-5`, `6-15`, `16-30`, `30+` | Bucket of active mental load items. |
| `focus_streak_bucket` | String | `0`, `1-3`, `4-7`, `8-14`, `15-30`, `30+` | Daily active prioritization streak bucket. |

---

## 🏷️ 3. Event Catalog by Functional Domain

### 🧠 A. Artificial Intelligence & Two-Tier Classification (Issue #2)

| Event Name | Parameters | Description |
|---|---|---|
| `ai_classification_triggered` | `input_length_bucket` (String: `1-10`, `11-20`, `21-50`, `50+`)<br>`has_partner_context` (Boolean) | Triggered when evaluating cognitive workload for a task. |
| `ai_quadrant_suggested` | `source` (String: `heuristic`, `gemini_flash`)<br>`suggested_quadrant` (String: `do_today`, `schedule`, `delegate`, `park`)<br>`suggested_area` (String: `self`, `home`, `work`)<br>`confidence_bucket` (String: `high`, `medium`, `low`) | Emitted when a quadrant and life area suggestion is presented to the user. |
| `ai_quadrant_applied` | `quadrant` (String)<br>`area` (String)<br>`source` (String)<br>`time_to_apply_ms` (Long) | Recorded when the user taps the suggestion chip to apply it in 1-tap. |
| `ai_quadrant_dismissed` | `suggested_quadrant` (String)<br>`manual_selected_quadrant` (String)<br>`suggested_area` (String, opt)<br>`manual_selected_area` (String, opt) | Recorded when the user dismisses or overrides the AI suggestion with a manual selection. |

---

### 📝 B. Quick Capture & Mental Load Management

| Event Name | Parameters | Description |
|---|---|---|
| `quick_capture_submitted` | `char_count_bucket` (String: `1-20`, `21-50`, `51-100`, `100+`)<br>`has_details` (Boolean) | Submitting a thought from the home capture bar. |
| `mental_load_created` | `area` (String: `self`, `home`, `work`)<br>`quadrant` (String)<br>`is_shared` (Boolean)<br>`is_ai_assisted` (Boolean) | Creating and saving a new mental load item. |
| `mental_load_updated` | `area` (String)<br>`quadrant` (String)<br>`is_shared` (Boolean)<br>`changed_quadrant` (Boolean)<br>`changed_area` (Boolean) | Updating properties of an existing task. |
| `mental_load_deleted` | `area` (String)<br>`quadrant` (String)<br>`was_completed` (Boolean)<br>`was_shared` (Boolean) | Deleting a mental load item. |
| `task_completed` | `area` (String)<br>`quadrant` (String)<br>`is_shared` (Boolean)<br>`is_voted_today` (Boolean) | Checking / completing a task. |
| `task_reopened` | `area` (String)<br>`quadrant` (String)<br>`is_shared` (Boolean) | Reopening a completed task. |
| `task_filter_applied` | `filter_mode` (String: `all`, `shared`, `personal`, `top3`)<br>`results_count` (Int) | Applying a filter on the task list. |

---

### 🧭 C. Eisenhower Matrix & Daily Prioritization

| Event Name | Parameters | Description |
|---|---|---|
| `daily_vote_toggled` | `action` (String: `added`, `removed`)<br>`current_voted_count` (Int: `1` to `3`)<br>`area` (String)<br>`quadrant` (String) | Adding or removing a task from the daily Top 3. |
| `daily_vote_limit_reached` | `max_votes` (Int: `3`)<br>`active_loads_count` (Int) | Attempting to exceed the 3-vote daily limit. |
| `daily_votes_reset` | `previous_voted_count` (Int) | Daily reset of Top 3 votes. |
| `quadrant_reassigned` | `previous_quadrant` (String, opt)<br>`target_quadrant` (String)<br>`area` (String) | Direct reassignment of a task to another quadrant. |

---

### 👫 D. Duo Space & Partner Pairing

| Event Name | Parameters | Description |
|---|---|---|
| `partner_invite_generated` | `is_regenerated` (Boolean) | Generating a sanctuary code `SANCTUARY-XXXXXX`. |
| `partner_join_attempted` | `code_format_valid` (Boolean) | Submitting a partner invitation code. |
| `partner_paired_success` | `method` (String: `sanctuary_code`) | Successful pairing of both profiles. |
| `partner_paired_failed` | `error_reason` (String) | Pairing failure (invalid code, already linked). |
| `partner_unpaired` | `active_tasks_count` (Int) | Unpairing from partner. |
| `partner_upvote_toggled` | `action` (String)<br>`area` (String)<br>`is_completed` (Boolean) | Support/priority vote on a shared task. |
| `partner_ledger_viewed` | `active_dimension` (String)<br>`total_shared_tasks` (Int) | Viewing the Synergy Ledger. |
| `partner_ledger_dim_changed`| `selected_dimension` (String: `active`, `initiated`, `resolved`)<br>`user_percentage` (Int)<br>`partner_percentage` (Int) | Switching between the 3 couple workload dimensions. |
| `couple_synergy_viewed` | `focus_streak_days` (Int)<br>`total_completed_shared` (Int) | Opening the couple synergy celebration modal. |
| `shared_privacy_updated` | `privacy_mode` (String) | Updating shared tasks visibility mode. |

---

### 🔐 E. Authentication, Soft-Gating & Settings

| Event Name | Parameters | Description |
|---|---|---|
| `screen_view` | `screen_name` (String)<br>`screen_class` (String)<br>`access_state` (String)<br>`active_loads_count` (Int)<br>`voted_loads_count` (Int) | Navigating to a screen. |
| `sign_in_started` | `source` (String) | Initiating Google Sign-In. |
| `sign_in_success` | *(none)* | Successful sign-in. |
| `sign_in_failed` | `error_type` (String)<br>`error_message` (String) | Google Sign-In failure. |
| `sign_out` | `previous_access_state` (String) | Voluntary user sign-out. |
| `soft_gate_shown` | `trigger_feature` (String) | Displaying sign-in/pairing soft-gate modal. |
| `theme_changed` | `new_theme` (String)<br>`previous_theme` (String, opt) | Changing theme mode (Light / Dark / System). |
| `gentle_reset_started` | `source` (String) | Launching 4-4-4 guided breathing session. |
| `gentle_reset_completed` | `duration_seconds` (Int: `30`)<br>`current_streak` (Int) | Completing a zen centering session. |

---

### 🔁 F. Recurrence, Due Dates & Alternating Duo Rotation (Issue #1)

| Event Name | Parameters | Description |
|---|---|---|
| `task_due_date_set` | `is_preset` (Boolean)<br>`preset_type` (String, opt: `today`, `tomorrow`, `weekend`, `next_week`)<br>`is_recurring` (Boolean)<br>`days_until_due` (Int, opt) | Setting or quick-selecting a due date on a mental load item. |
| `recurring_task_created` | `frequency` (String: `daily`, `weekdays_only`, `weekends_only`, `weekly`, `biweekly`, `monthly`, `yearly`)<br>`is_duo_rotating` (Boolean)<br>`has_due_date` (Boolean)<br>`area` (String) | Creating a recurring or periodic task. |
| `recurring_task_completed` | `frequency` (String)<br>`cycle_count` (Int)<br>`is_duo_rotating` (Boolean)<br>`has_due_date` (Boolean) | Completing a recurring task cycle and triggering the next cycle. |
| `duo_rotation_assigned` | `frequency` (String)<br>`cycle_count` (Int)<br>`next_assignee_role` (String: `partner`, `self`)<br>`days_to_next_due` (Int, opt) | Automatic alternation of task assignee for the next cycle. |

---

## 🧪 4. Validation & Automated Tests

All events and parameter serializations are validated in unit tests:

```bash
./gradlew testDebugUnitTest --tests com.secondbrain.app.data.analytics.AnalyticsTrackerTest
```
