# 🛡️ Firebase Standards & Best Practices

Cette règle définit les standards de développement pour tout ce qui touche à l'écosystème Firebase (Firestore, Auth, Crashlytics) dans le projet Agentic Android Kernel. Elle s'appuie sur les "Skills" natives d'Antigravity pour garantir un code sécurisé, optimisé et conforme aux recommandations officielles de Google.

## 📚 1. Consultation Obligatoire des Skills Firebase

Lors de la rédaction du **Plan 4 Piliers (Pilier 4 : Blueprint Technique)** ou lors de la phase d'implémentation (`In Progress`), l'Agent **DOIT obligatoirement** consulter la skill appropriée (via `view_file` sur les fichiers `SKILL.md` associés) avant d'écrire ou modifier du code :

- **Base de données & Modélisation** : Consultation de la skill `firebase-firestore` obligatoire pour toute création de collection, choix de structure (sous-collections vs collections racine), indexation et requêtage.
- **Authentification & Permissions** : Consultation de `firebase-auth-basics` pour toute gestion d'utilisateurs, custom claims, ou authentification.
- **IA & Logique Générative (Gemini)** : Consultation obligatoire de `firebase-ai-logic-basics` pour l'intégration de Gemini via Firebase AI Logic (SDK `com.google.firebase:firebase-ai`, modèle `gemini-3.5-flash-lite`, App Check obligatoire).
- **Monitoring & Télémétrie** : Consultation de `firebase-crashlytics` pour l'ajout de logs, Custom Keys, Non-fatal exceptions ou l'enrichissement des données pour la routine Sentinel.
- **Configuration Générale** : Consultation de `firebase-basics` pour l'initialisation et l'environnement.

## 🔐 2. Sécurité Firestore et Audit "Red Team"

La sécurité de la base de données est critique. Les règles Firestore (`firestore.rules`) ne doivent **jamais** être modifiées sans un audit de sécurité rigoureux.

- **Conception** : L'écriture des règles doit suivre le principe du moindre privilège et valider strictement le schéma de données (types, longueurs, champs autorisés, bypass update).
- **Tests Unitaires** : L'exécution des tests locaux avec l'émulateur (via `scripts/test-firestore-rules.mjs`) est une condition sine qua non avant tout commit.
- **Audit Agent** : Toute modification de `firestore.rules` déclenche obligatoirement l'audit IA via la skill `firebase-security-rules-auditor` (intégré de manière systématique au workflow `/open-pr`).
