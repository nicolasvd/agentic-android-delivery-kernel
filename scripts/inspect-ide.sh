#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Kernel — Android Studio Headless Code Inspection Runner
# ==============================================================================
# Ce script exécute le moteur d'inspection complet d'Android Studio / IntelliJ
# (Kotlin, Java, JVM, Gradle, Proofreading/Typos, XML, etc.) en mode headless.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSPECT_BIN="/Applications/Android Studio.app/Contents/bin/inspect.sh"
PROFILE_PATH="$PROJECT_ROOT/.idea/inspectionProfiles/Project_Default.xml"
OUTPUT_DIR="$PROJECT_ROOT/build/reports/ide-inspections"

echo "=================================================================="
echo "🔍 Android Studio — Exécution Headless des Inspections de l'IDE"
echo "=================================================================="

if [[ ! -f "$INSPECT_BIN" ]]; then
    echo "⚠️ Android Studio inspect.sh non trouvé dans /Applications/Android Studio.app"
    echo "ℹ️ Veuillez vous assurer qu'Android Studio est installé."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
TMP_CONFIG="/tmp/as_inspect_config"
TMP_SYSTEM="/tmp/as_inspect_system"
mkdir -p "$TMP_CONFIG" "$TMP_SYSTEM"

cat << EOF > /tmp/idea.properties
idea.config.path=$TMP_CONFIG
idea.system.path=$TMP_SYSTEM
idea.plugins.path=$TMP_CONFIG/plugins
idea.log.path=$TMP_SYSTEM/log
EOF

echo "🚀 Lancement de l'inspection IntelliJ sur le projet..."
STUDIO_PROPERTIES=/tmp/idea.properties "$INSPECT_BIN" \
    "$PROJECT_ROOT" \
    "$PROFILE_PATH" \
    "$OUTPUT_DIR" \
    -v2 \
    -d "$PROJECT_ROOT/app" || true

echo "=================================================================="
echo "📊 Rapports générés dans : $OUTPUT_DIR"
echo "=================================================================="
