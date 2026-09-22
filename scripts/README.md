# 🛠️ Scripts d'Automatisation — Agentic Android Kernel

Ce dossier contient l'ensemble des **scripts atomiques** et des **orchestrateurs** du projet **Agentic Android Kernel**.

> 📖 **Documentation Complète & Architecture Détaillée :**
> Consultez [**`docs/scripts-reference.md`**](../docs/scripts-reference.md) pour les fiches exhaustives, les options CLI, et la matrice de composition.

---

## ⚡ Index Rapide des Scripts

| Script | Langage | Description Synthétique | Commande |
|---|---|---|---|
| [`validate-docs.sh`](validate-docs.sh) | Bash | Valide la présence et la conformité des contrats de spécifications (`DESIGN.md`, playbooks, skills, règles) | `./scripts/validate-docs.sh` |
| [`quality-check.sh`](quality-check.sh) | Bash | Exécute la suite complète de compilation Kotlin/Java, Lint Android et tests unitaires/UI | `./scripts/quality-check.sh` |
| [`test-firestore-rules.mjs`](test-firestore-rules.mjs) | Node.js | Exécute 16 assertions de sécurité et de non-régression sur `firestore.rules` | `node scripts/test-firestore-rules.mjs` |
| [`deploy-firestore-rules.mjs`](deploy-firestore-rules.mjs) | Node.js | Déploie et publie `firestore.rules` via l'API REST avec JWT compte de service | `node scripts/deploy-firestore-rules.mjs` |
| [`deploy-app-distribution.sh`](deploy-app-distribution.sh) | Bash | Compile et déploie l'APK sur Firebase App Distribution avec multiplicateur de version (x100) | `./scripts/deploy-app-distribution.sh` |
| [`generate-screenshots.sh`](generate-screenshots.sh) | Bash | Génère les captures d'écran Roborazzi pour le Design System | `./scripts/generate-screenshots.sh` |
| [`upload-screenshots.py`](upload-screenshots.py) | Python | Valide et mappe les captures Roborazzi sur les écrans Google Stitch | `python3 scripts/upload-screenshots.py --check-only` |
| [`cleanup-e2e-firestore.mjs`](cleanup-e2e-firestore.mjs) | Node.js | Purge les documents de sondes de test dans la collection Firestore `/users` | `node scripts/cleanup-e2e-firestore.mjs` |
| [`inspect-ide.sh`](inspect-ide.sh) | Bash | Exécute les inspections Android Studio / IntelliJ en mode headless | `./scripts/inspect-ide.sh` |

---

## 🎯 Composition par Compétences Sémantiques ([`.agent/skills/`](../.agent/skills/))

Chaque script remplit une responsabilité unique. Les enchaînements sont pilotés par les compétences sémantiques natives de l'agent :
- **`quality-airbag`** (`/quality-check`) ➔ `validate-docs.sh` + `quality-check.sh` + `test-firestore-rules.mjs`
- **`sync-stitch`** (`/sync-stitch`) ➔ `validate-docs.sh` + `generate-screenshots.sh` + `upload-screenshots.py`
- **`distribute-local`** (`/distribute-local`) ➔ `quality-check.sh` + `deploy-app-distribution.sh`
- **`open-pr`** (`/open-pr`) ➔ `quality-check.sh` + Walkthrough & PR creation
- **`triage-feedback`** (`/triage-feedback`) ➔ 100% MCP natif (`GitHubMCP` : `search_issues`, `add_issue_comment`, `create_issue`)
