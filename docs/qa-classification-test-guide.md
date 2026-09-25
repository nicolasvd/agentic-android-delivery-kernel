# 🧠 QA Test Guide & AI Classification Reference (Clarity Matrix & Areas of Life)

This document details the cognitive management philosophy of **Agentic Android Kernel**, the behavior of the **Two-Tier hybrid classification engine (Local Heuristic + Gemini Flash-Lite)**, and the **exhaustive test matrix (all 12 combinations)** used to validate quadrant and life area suggestions.

---

## 🌿 1. Philosophy & Positive Emotional Vocabulary

Agentic Android Kernel applies principles from the **Eisenhower Matrix** and the **GTD (Getting Things Done)** methodology, reinterpreted through a calming approach (*Serene UX*):

* **Zero Stress / Non-prescriptive**: The interface avoids anxiety-inducing terminology.
* **Duo Teamwork**: The traditional *"Delegate"* label is replaced by **"Duo Teamwork"** and **"Propose to partner"**, emphasizing positive interdependence and shared mental load reduction.
* **Mental Sanctuary**: The *"Eliminate / Won't do"* quadrant is replaced by **"Park in Sanctuary"**, providing a space to capture valuable thoughts without deadlines or guilt.

---

## 🧭 2. The 4 Clarity Matrix Quadrants

```
                       URGENT (Short Term)                   NON-URGENT (Long Term)
                 ┌───────────────────────────────────┬───────────────────────────────────┐
                 │  ⚡ DO TODAY                      │  🌿 SCHEDULE & ALIGN              │
  IMPORTANT      │  • High urgency & high impact     │  • High impact, serene execution  │
 (High Value)    │  • Imminent deadline (tonight)    │  • Structuring projects, Self-care│
                 ├───────────────────────────────────┼───────────────────────────────────┤
                 │  🤝 DUO TEAMWORK                  │  🍃 PARK IN SANCTUARY             │
 NON-IMPORTANT   │  • Urgent, low complexity         │  • Low urgency & low impact       │
  (Low Load)     │  • Propose to partner             │  • Someday-maybe, Wishlist        │
                 └───────────────────────────────────┴───────────────────────────────────┘
```

### 🔍 Focus: "Schedule & Align" vs. "Park in Sanctuary"

A fundamental distinction exists between these two categories:

1. **🌿 Schedule & Align (`SCHEDULE` - Quadrant II)**:
   * This is the **"Golden Quadrant"** of calm efficiency.
   * It gathers essential actions deserving deliberate attention without panic: medical checkups, life intentions, strategic roadmaps, and **active self-care**.
   * 👉 *Example:* **"Take time for myself"** or **"Book doctor checkup"** are classified here because personal balance is an **important** intention that should be planned calmly.

2. **🍃 Park in Sanctuary (`PARK` - Quadrant IV / Someday-Maybe)**:
   * A dedicated space to **free the mind** from commitments with zero immediate urgency.
   * It welcomes exploratory curiosities, wishlists, and distant ambitions stored safely without cluttering current attention.
   * 👉 *Example:* **"Idea for later: try aerial yoga someday"** or **"Someday learn how to play piano"**.

---

## 🏷️ 3. The 3 Areas of Life

1. **🧘 For Self (`SELF`)**: Health, preventive medicine, physical fitness, sleep, meditation, well-being, personal hobbies, and disconnecting.
2. **🏡 Home (`HOME`)**: Housing, indoor/outdoor maintenance, gardening, repairs, groceries, meals, pets, kids, and family logistics.
3. **💼 Work (`WORK`)**: Professional activities, project management, meetings, taxes/accounting, clients, quotes, contracts, and strategy.

---

## ⚡ 4. Two-Tier Hybrid Architecture

1. **Tier 1 — Local Heuristics (`< 5ms`)**:
   * Instant synchronous deterministic analysis with 0 ms network latency.
   * Strict Unicode tokenization (`\p{L}`) natively handling accented characters without substring false positives.
   * Immediately suggests the Quadrant and Area of Life.

2. **Tier 2 — Gemini 3.5 Flash-Lite via Firebase AI Logic (Asynchronous)**:
   * Triggered after typing stops (400ms debounce) or on focus loss.
   * Uses `gemini-3.5-flash-lite` via `com.google.firebase:firebase-ai` with App Check (Play Integrity in production, `DebugAppCheckProvider` on emulator).
   * Evaluates cognitive complexity, refines life area (`HOME`, `WORK`, `SELF`), enriches benevolent rationale, and tunes confidence.
   * **Emulator App Check Resilience**: If debug tokens are not whitelisted in local environments, 403 errors are caught without polluting Crashlytics, and Tier 1 heuristics guarantee uninterrupted, instant classification.

---

## 📋 5. Complete Test Matrix (All 12 Combinations)

This table provides the canonical test phrases used to validate all 12 combinations in the input interface (`AddMentalLoadScreen.kt` and `EditMentalLoadSheet.kt`).

### 🧘 Area: For Self (`SELF`)

| # | Expected Quadrant | Test Phrase (Copy-Paste) | Triggers / Rationale |
|:---:|---|---|---|
| **1** | ⚡ **Do Today** | `Prendre mes antibiotiques et appeler médecin en urgence aujourd'hui` | `urgence`, `aujourd'hui` + `santé`, `médecin` |
| **2** | 🌿 **Schedule & Align** | `Prendre rendez-vous bilan de santé médecin` *(or `Prendre du temps pour moi`)* | `santé`, `médecin`, `rdv`, `temps pour moi` (no urgency marker) |
| **3** | 🤝 **Duo Teamwork** | `Demander à Sam de passer à la pharmacie chercher mon ordonnance` | `demander à Sam` + `pharmacie`, `ordonnance` |
| **4** | 🍃 **Park in Sanctuary** | `Idée pour plus tard : tester le yoga aérien un jour` | `idée pour plus tard`, `un jour` + `yoga` |

---

### 🏡 Area: Home (`HOME`)

| # | Expected Quadrant | Test Phrase (Copy-Paste) | Triggers / Rationale |
|:---:|---|---|---|
| **5** | ⚡ **Do Today** | `Sortir les poubelles et réparer la fuite d'eau ce soir urgent` | `urgent`, `ce soir` + `poubelles`, `fuite`, `eau` |
| **6** | 🌿 **Schedule & Align** | `Tailler la haie et tondre la pelouse ce week-end` | `tailler`, `haie`, `tondre`, `pelouse` |
| **7** | 🤝 **Duo Teamwork** | `Demander à Sam de faire les courses et acheter du lait` | `demander à Sam` + `courses`, `lait` |
| **8** | 🍃 **Park in Sanctuary** | `Idée pour plus tard : créer un potager dans le jardin` | `idée pour plus tard` + `jardin`, `potager` |

---

### 💼 Area: Work (`WORK`)

| # | Expected Quadrant | Test Phrase (Copy-Paste) | Triggers / Rationale |
|:---:|---|---|---|
| **9** | ⚡ **Do Today** | `Déclaration impôts urgente aujourd'hui avant 18h` | `urgente`, `aujourd'hui`, `avant 18h` + `impôts`, `déclaration` |
| **10** | 🌿 **Schedule & Align** | `Préparer la roadmap stratégique du projet Q4` | `roadmap`, `stratégique`, `projet`, `q4` |
| **11** | 🤝 **Duo Teamwork** | `Demander à Sam de relire le devis et le contrat` | `demander à Sam` + `devis`, `contrat` |
| **12** | 🍃 **Park in Sanctuary** | `Idée pour plus tard : explorer un projet open source un jour` | `idée pour plus tard`, `explorer`, `un jour` + `projet` |

---

## 🧪 6. Automated Verification

The unit test suite validates all of these rules:

```bash
./gradlew testDebugUnitTest --tests com.secondbrain.app.data.classifier.HeuristicTaskClassifierTest
```

Validated test: `verify all 12 combinations of AreaOfLife and PriorityQuadrant` in `HeuristicTaskClassifierTest.kt`.
