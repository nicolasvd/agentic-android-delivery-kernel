# 📊 Taxonomie & Événements Analytics (Zero-PII & Privacy-First)

Ce document formalise la structure, les événements et les paramètres de télémétrie de **Agentic Android Kernel**.

---

## 🛡️ 1. Principes de Confidentialité & Éthique (Zero-PII)

L'architecture de télémétrie de Agentic Android Kernel est conçue selon le principe strict du **Privacy by Design** :

1. **Aucune Donnée Personnelle Identifiable (Zero-PII)** : Les titres de tâches, descriptions, noms propres, adresses emails et contenus saisis par l'utilisateur ne sont **jamais** envoyés dans les événements d'analytics.
2. **Bucketing / Plages de Valeurs** : Toutes les longueurs de texte et les nombres d'éléments sont regroupés en intervalles discrets (ex: `1-20`, `21-50`, `51-100`, `100+`) pour éviter tout traçage indirect par empreinte textuelle.
3. **Comportement Hors-Ligne & Robuste** : Si Firebase Analytics n'est pas initialisé ou en mode avion, le tracker encapsule les appels sans aucun crash ni blocage de l'UI (`FirebaseAnalyticsTracker`).

---

## 📈 2. Propriétés Utilisateur (User Properties)

| Clé | Type | Exemples de Valeurs | Description |
|---|---|---|---|
| `access_state` | String | `guest`, `solo`, `duo` | État d'accès actuel (Invité, Connecté Solo, Jumelé en Duo). |
| `theme_preference` | String | `light`, `dark`, `system` | Préférence de thème d'affichage. |
| `is_partner_linked` | Boolean | `true`, `false` | Indique si le compte est jumelé à un partenaire. |
| `active_loads_bucket` | String | `0`, `1-5`, `6-15`, `16-30`, `30+` | Tranche du nombre de charges mentales actives. |
| `focus_streak_bucket` | String | `0`, `1-3`, `4-7`, `8-14`, `15-30`, `30+` | Série quotidienne de priorisation active. |

---

## 🏷️ 3. Catalogue des Événements par Domaine Fonctionnel

### 🧠 A. Intelligence Artificielle & Classification Two-Tier (Issue #2)

| Nom de l'Événement | Paramètres | Description |
|---|---|---|
| `ai_classification_triggered` | `input_length_bucket` (String : `1-10`, `11-20`, `21-50`, `50+`)<br>`has_partner_context` (Boolean) | Déclenché lors de l'évaluation cognitive d'une tâche. |
| `ai_quadrant_suggested` | `source` (String : `heuristic`, `gemini_flash`)<br>`suggested_quadrant` (String : `do_today`, `schedule`, `delegate`, `park`)<br>`suggested_area` (String : `self`, `home`, `work`)<br>`confidence_bucket` (String : `high`, `medium`, `low`) | Émis lorsqu'une suggestion de quadrant et de domaine de vie est présentée à l'utilisateur. |
| `ai_quadrant_applied` | `quadrant` (String)<br>`area` (String)<br>`source` (String)<br>`time_to_apply_ms` (Long) | Enregistré lorsque l'utilisateur touche le chip de suggestion pour l'appliquer en 1-tap. |
| `ai_quadrant_dismissed` | `suggested_quadrant` (String)<br>`manual_selected_quadrant` (String)<br>`suggested_area` (String, opt)<br>`manual_selected_area` (String, opt) | Enregistré lorsque l'utilisateur ignore ou remplace la suggestion IA par un choix manuel. |

---

### 📝 B. Capture Rapide & Gestion des Charges Mentales

| Nom de l'Événement | Paramètres | Description |
|---|---|---|
| `quick_capture_submitted` | `char_count_bucket` (String : `1-20`, `21-50`, `51-100`, `100+`)<br>`has_details` (Boolean) | Soumission d'une pensée depuis la barre d'accueil. |
| `mental_load_created` | `area` (String : `self`, `home`, `work`)<br>`quadrant` (String)<br>`is_shared` (Boolean)<br>`is_ai_assisted` (Boolean) | Création et sauvegarde d'une nouvelle charge mentale. |
| `mental_load_updated` | `area` (String)<br>`quadrant` (String)<br>`is_shared` (Boolean)<br>`changed_quadrant` (Boolean)<br>`changed_area` (Boolean) | Mise à jour des propriétés d'une tâche existante. |
| `mental_load_deleted` | `area` (String)<br>`quadrant` (String)<br>`was_completed` (Boolean)<br>`was_shared` (Boolean) | Suppression d'une charge mentale. |
| `task_completed` | `area` (String)<br>`quadrant` (String)<br>`is_shared` (Boolean)<br>`is_voted_today` (Boolean) | Coche / complétion d'une tâche. |
| `task_reopened` | `area` (String)<br>`quadrant` (String)<br>`is_shared` (Boolean) | Réouverture d'une tâche terminée. |
| `task_filter_applied` | `filter_mode` (String : `all`, `shared`, `personal`, `top3`)<br>`results_count` (Int) | Application d'un filtre sur la liste des charges. |

---

### 🧭 C. Matrice d'Eisenhower & Priorisation Quotidienne

| Nom de l'Événement | Paramètres | Description |
|---|---|---|
| `daily_vote_toggled` | `action` (String : `added`, `removed`)<br>`current_voted_count` (Int : `1` à `3`)<br>`area` (String)<br>`quadrant` (String) | Ajout ou retrait d'une tâche dans le Top 3 quotidien. |
| `daily_vote_limit_reached` | `max_votes` (Int : `3`)<br>`active_loads_count` (Int) | Tentative de dépassement de la limite de 3 votes. |
| `daily_votes_reset` | `previous_voted_count` (Int) | Réinitialisation quotidienne des votes Top 3. |
| `quadrant_reassigned` | `previous_quadrant` (String, opt)<br>`target_quadrant` (String)<br>`area` (String) | Déplacement direct d'une tâche vers un autre quadrant. |

---

### 👫 D. Espace Duo & Jumelage Partenaire

| Nom de l'Événement | Paramètres | Description |
|---|---|---|
| `partner_invite_generated` | `is_regenerated` (Boolean) | Génération d'un code sanctuaire `SANCTUARY-XXXXXX`. |
| `partner_join_attempted` | `code_format_valid` (Boolean) | Soumission d'un code d'invitation partenaire. |
| `partner_paired_success` | `method` (String : `sanctuary_code`) | Jumelage réussi des deux profils. |
| `partner_paired_failed` | `error_reason` (String) | Échec de jumelage (code invalide, déjà lié). |
| `partner_unpaired` | `active_tasks_count` (Int) | Dissociation du partenaire. |
| `partner_upvote_toggled` | `action` (String)<br>`area` (String)<br>`is_completed` (Boolean) | Vote de soutien/priorité sur une tâche partagée. |
| `partner_ledger_viewed` | `active_dimension` (String)<br>`total_shared_tasks` (Int) | Consultation du Grand Livre de synergie. |
| `partner_ledger_dim_changed`| `selected_dimension` (String : `active`, `initiated`, `resolved`)<br>`user_percentage` (Int)<br>`partner_percentage` (Int) | Bascule entre les 3 dimensions de charge du couple. |
| `couple_synergy_viewed` | `focus_streak_days` (Int)<br>`total_completed_shared` (Int) | Ouverture de la modale de célébration de couple. |
| `shared_privacy_updated` | `privacy_mode` (String) | Modification de la visibilité des tâches partagées. |

---

### 🔐 E. Authentification, Soft-Gating & Paramètres

| Nom de l'Événement | Paramètres | Description |
|---|---|---|
| `screen_view` | `screen_name` (String)<br>`screen_class` (String)<br>`access_state` (String)<br>`active_loads_count` (Int)<br>`voted_loads_count` (Int) | Navigation vers un écran. |
| `sign_in_started` | `source` (String) | Déclenchement de la connexion Google. |
| `sign_in_success` | *(aucun)* | Connexion réussie. |
| `sign_in_failed` | `error_type` (String)<br>`error_message` (String) | Échec de connexion Google. |
| `sign_out` | `previous_access_state` (String) | Déconnexion volontaire de l'utilisateur. |
| `soft_gate_shown` | `trigger_feature` (String) | Affichage de la boîte de dialogue invitant à la connexion/jumelage. |
| `theme_changed` | `new_theme` (String)<br>`previous_theme` (String, opt) | Changement du mode de thème (Clair / Sombre / Système). |
| `gentle_reset_started` | `source` (String) | Lancement de la respiration guidée 4-4-4. |
| `gentle_reset_completed` | `duration_seconds` (Int : `30`)<br>`current_streak` (Int) | Complétion d'une session de recentrage zen. |

---

### 🔁 F. Récurrence, Échéances & Rotation Alternée Duo (Issue #1)

| Nom de l'Événement | Paramètres | Description |
|---|---|---|
| `task_due_date_set` | `is_preset` (Boolean)<br>`preset_type` (String, opt : `today`, `tomorrow`, `weekend`, `next_week`)<br>`is_recurring` (Boolean)<br>`days_until_due` (Int, opt) | Définition ou sélection rapide d'une échéance temporelle sur une charge mentale. |
| `recurring_task_created` | `frequency` (String : `daily`, `weekdays_only`, `weekends_only`, `weekly`, `biweekly`, `monthly`, `yearly`)<br>`is_duo_rotating` (Boolean)<br>`has_due_date` (Boolean)<br>`area` (String) | Création d'une tâche récurrente ou périodique. |
| `recurring_task_completed` | `frequency` (String)<br>`cycle_count` (Int)<br>`is_duo_rotating` (Boolean)<br>`has_due_date` (Boolean) | Complétion d'un cycle de tâche récurrente et déclenchement automatique du cycle suivant. |
| `duo_rotation_assigned` | `frequency` (String)<br>`cycle_count` (Int)<br>`next_assignee_role` (String : `partner`, `self`)<br>`days_to_next_due` (Int, opt) | Alternance automatique du responsable de la tâche pour le cycle suivant. |

---

## 🧪 4. Validation & Tests Automatisés

Tous les événements et leurs sérialisations de paramètres sont validés dans les tests unitaires :

```bash
./gradlew testDebugUnitTest --tests com.secondbrain.app.data.analytics.AnalyticsTrackerTest
```
