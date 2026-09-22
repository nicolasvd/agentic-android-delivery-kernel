#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Kernel — Generate Roborazzi Screenshots
# ==============================================================================
# Exécute les tests d'UI Robolectric/Roborazzi pour générer ou mettre à jour
# les captures d'écran de l'application en local (dans build/outputs/roborazzi).
# ==============================================================================

set -euo pipefail

echo "=================================================="
echo "📸 Agentic Android Kernel — Génération des captures Roborazzi"
echo "=================================================="

# On exécute la tâche Gradle standard pour enregistrer les captures Roborazzi.
./gradlew recordRoborazziDebug --stacktrace

echo "=================================================="
echo "✨ Captures générées avec succès dans build/outputs/roborazzi !"
echo "=================================================="
