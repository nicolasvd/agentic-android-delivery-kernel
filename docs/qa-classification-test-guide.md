# 🧠 Guide de Test & Référentiel de Classification IA (Matrice de Clarté & Domaines de Vie)

Ce document détaille la philosophie de gestion cognitive de **Agentic Android Kernel**, le comportement du moteur hybride **Two-Tier (Heuristique locale + Gemini Flash-Lite)**, ainsi que la **matrice de test exhaustive (les 12 combinaisons)** pour valider les suggestions de quadrants et de domaines de vie.

---

## 🌿 1. Philosophie & Vocabulaire Émotionnel Positif

Agentic Android Kernel applique les principes de la **Matrice d'Eisenhower** et de la méthode **GTD (Getting Things Done)**, réinterprétés à travers une approche apaisante (*Serene UX*) :

* **Zéro Stress / Non-injonction** : L'interface évite les termes anxiogènes.
* **Entraide Duo** : Le terme traditionnel *"Déléguer"* est remplacé par **« Entraide Duo »** et **« À proposer au partenaire »** (*Duo Teamwork / Propose to partner*), valorisant l'interdépendance positive et l'allègement partagé de la charge mentale.
* **Sanctuaire Mental** : Le quadrant *"Éliminer / Ne pas faire"* est remplacé par **« Déposer au Sanctuaire »** (*Park in Sanctuary*), permettant de consigner une idée précieuse sans s'imposer d'échéance ni culpabilité.

---

## 🧭 2. Les 4 Quadrants de la Matrice de Clarté

```
                       URGENT (Court Terme)                  NON-URGENT (Long Terme)
                 ┌───────────────────────────────────┬───────────────────────────────────┐
                 │  ⚡ À FAIRE AUJOURD'HUI           │  🌿 PLANIFIER & ALIGNER           │
  IMPORTANT      │  • Haute urgence & Fort impact    │  • Fort impact, sérénité          │
 (Haute Valeur)  │  • Échéance imminente (ce soir)   │  • Projets structurants, Self-care│
                 ├───────────────────────────────────┼───────────────────────────────────┤
                 │  🤝 ENTRAIDE DUO                  │  🍃 DÉPOSER AU SANCTUAIRE         │
 NON-IMPORTANT   │  • Urgent, faible complexité      │  • Faible urgence & faible impact │
(Faible Charge)  │  • À proposer au partenaire       │  • Idée pour plus tard, Wishlist  │
                 └───────────────────────────────────┴───────────────────────────────────┘
```

### 🔍 Focus : "Planifier & Aligner" vs "Déposer au Sanctuaire"

Une distinction fondamentale existe entre ces deux catégories :

1. **🌿 Planifier & Aligner (`SCHEDULE` - Quadrant II)** :
   * C'est le **« Quadrant d'or »** de l'efficacité et de la sérénité.
   * Il regroupe les actions fondamentales qui méritent une attention délibérée mais sans panique : bilans de santé, intentions de vie, roadmap stratégique et **self-care actif**.
   * 👉 *Exemple :* **« Prendre du temps pour moi »** ou **« Prendre rendez-vous médecin »** sont classés ici car prendre soin de son équilibre est une intention **importante** qui doit être planifiée calmement.

2. **🍃 Déposer au Sanctuaire (`PARK` - Quadrant IV / Someday-Maybe)** :
   * C'est l'espace pour **libérer son esprit** des pensées sans engagement immédiat.
   * Il accueille les envies d'exploration, curiosités, wishlists ou projets lointains qu'on veut stocker en lieu sûr sans encombrer son champ attentionnel du moment.
   * 👉 *Exemple :* **« Idée pour plus tard : tester le yoga aérien un jour »** ou **« Un jour apprendre à jouer du piano »**.

---

## 🏷️ 3. Les 3 Domaines de Vie (Areas of Life)

1. **🧘 Pour Soi (`SELF`)** : Santé, médecine préventive, forme physique, sommeil, méditation, bien-être, loisirs personnels et déconnexion.
2. **🏡 Maison (`HOME`)** : Logement, entretien intérieur/extérieur, jardinage, bricolage, courses, repas, animaux de compagnie, enfants et logistique familiale.
3. **💼 Travail (`WORK`)** : Activité professionnelle, gestion de projets, réunions, fiscalité/comptabilité, clients, devis, contrats et stratégie.

---

## ⚡ 4. Architecture Hybride Two-Tier

1. **Tier 1 — Heuristique Locale (`< 5ms`)** :
   * Analyse déterministe synchrone instantanée avec 0 ms de latence réseau.
   * Tokenisation Unicode stricte (`\p{L}`) pour gérer nativement les accents français (*impôts*, *santé*, *médecin*) sans faux positifs sur les sous-chaînes.
   * Suggère immédiatement le Quadrant et le Domaine de Vie.

2. **Tier 2 — Gemini 3.5 Flash-Lite via Firebase AI Logic (Asynchrone)** :
   * Déclenché après une pause de frappe (debounce de 400ms) ou à la perte de focus.
   * Utilise le modèle `gemini-3.5-flash-lite` via `com.google.firebase:firebase-ai` avec App Check (Play Integrity en production, `DebugAppCheckProvider` sur émulateur).
   * Évalue la complexité cognitive, affine le domaine de vie (`HOME`, `WORK`, `SELF`), enrichit l'explication bienveillante (*rationale*) et ajuste la confiance.
   * **Résilience App Check Émulateur** : Si le jeton de debug n'est pas whitelisté en environnement local, l'erreur 403 est interceptée sans polluer Crashlytics, et le Tier 1 heuristique garantit une classification instantanée et ininterrompue.

---

## 📋 5. Matrice de Test Complète (Les 12 Combinaisons)

Ce tableau fournit les phrases de test canoniques pour valider les 12 combinaisons possibles dans l'interface de saisie (`AddMentalLoadScreen.kt` et `EditMentalLoadSheet.kt`).

### 🧘 Domaines : Pour Soi (`SELF`)

| # | Quadrant Attendu | Phrase de Test à Copier-Coller | Déclencheurs / Justification |
|:---:|---|---|---|
| **1** | ⚡ **À Faire Aujourd'hui** | `Prendre mes antibiotiques et appeler médecin en urgence aujourd'hui` | `urgence`, `aujourd'hui` + `santé`, `médecin` |
| **2** | 🌿 **Planifier & Aligner** | `Prendre rendez-vous bilan de santé médecin` *(ou `Prendre du temps pour moi`)* | `santé`, `médecin`, `rdv`, `temps pour moi` (sans marqueur d'urgence) |
| **3** | 🤝 **Entraide Duo** | `Demander à Sam de passer à la pharmacie chercher mon ordonnance` | `demander à Sam` + `pharmacie`, `ordonnance` |
| **4** | 🍃 **Déposer au Sanctuaire** | `Idée pour plus tard : tester le yoga aérien un jour` | `idée pour plus tard`, `un jour` + `yoga` |

---

### 🏡 Domaines : Maison (`HOME`)

| # | Quadrant Attendu | Phrase de Test à Copier-Coller | Déclencheurs / Justification |
|:---:|---|---|---|
| **5** | ⚡ **À Faire Aujourd'hui** | `Sortir les poubelles et réparer la fuite d'eau ce soir urgent` | `urgent`, `ce soir` + `poubelles`, `fuite`, `eau` |
| **6** | 🌿 **Planifier & Aligner** | `Tailler la haie et tondre la pelouse ce week-end` | `tailler`, `haie`, `tondre`, `pelouse` |
| **7** | 🤝 **Entraide Duo** | `Demander à Sam de faire les courses et acheter du lait` | `demander à Sam` + `courses`, `lait` |
| **8** | 🍃 **Déposer au Sanctuaire** | `Idée pour plus tard : créer un potager dans le jardin` | `idée pour plus tard` + `jardin`, `potager` |

---

### 💼 Domaines : Travail (`WORK`)

| # | Quadrant Attendu | Phrase de Test à Copier-Coller | Déclencheurs / Justification |
|:---:|---|---|---|
| **9** | ⚡ **À Faire Aujourd'hui** | `Déclaration impôts urgente aujourd'hui avant 18h` | `urgente`, `aujourd'hui`, `avant 18h` + `impôts`, `déclaration` |
| **10** | 🌿 **Planifier & Aligner** | `Préparer la roadmap stratégique du projet Q4` | `roadmap`, `stratégique`, `projet`, `q4` |
| **11** | 🤝 **Entraide Duo** | `Demander à Sam de relire le devis et le contrat` | `demander à Sam` + `devis`, `contrat` |
| **12** | 🍃 **Déposer au Sanctuaire** | `Idée pour plus tard : explorer un projet open source un jour` | `idée pour plus tard`, `explorer`, `un jour` + `projet` |

---

## 🧪 6. Vérification Automatisée

La suite de tests unitaires valide l'intégralité de ces règles :

```bash
./gradlew testDebugUnitTest --tests com.secondbrain.app.data.classifier.HeuristicTaskClassifierTest
```

Test validé : `verify all 12 combinations of AreaOfLife and PriorityQuadrant` dans `HeuristicTaskClassifierTest.kt`.
