#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Agentic Android Kernel — Full Code Inspection & Sanity Check Suite
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================================================="
echo "🔍 Agentic Android Kernel — Full Code Inspection & Sanity Checks Suite"
echo "=================================================================="

# 1. Detect and set Java environment dynamically & portably
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    echo "☕ Using existing JAVA_HOME: $JAVA_HOME"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -x "/usr/libexec/java_home" ]; then
        DETECTED_JAVA=$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home 2>/dev/null || true)
        if [ -n "$DETECTED_JAVA" ]; then
            export JAVA_HOME="$DETECTED_JAVA"
        fi
    fi
    if [ -z "${JAVA_HOME:-}" ]; then
        for as_path in \
            "/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
            "/Applications/Android Studio Preview.app/Contents/jbr/Contents/Home" \
            "$HOME/Applications/Android Studio.app/Contents/jbr/Contents/Home"; do
            if [ -d "$as_path" ]; then
                export JAVA_HOME="$as_path"
                break
            fi
        done
    fi
elif [[ "$OSTYPE" == "linux"* ]]; then
    for linux_path in \
        "/usr/lib/jvm/java-21-openjdk-amd64" \
        "/usr/lib/jvm/default-java" \
        "/opt/android-studio/jbr"; do
        if [ -d "$linux_path" ]; then
            export JAVA_HOME="$linux_path"
            break
        fi
    done
fi

if [ -z "${JAVA_HOME:-}" ]; then
    echo "☕ Java Home : system default (${JAVA_HOME:-unset})"
else
    echo "☕ Java Home : $JAVA_HOME"
fi

echo "📂 Project   : $ROOT_DIR"
echo ""
echo "🚀 Lancement des vérifications complètes :"
echo "   1. Kotlin Progressive Compiler Checks & Opt-in annotations"
echo "   2. Java Compiler Warnings (-Xlint:all)"
echo "   3. Android Lint Debug & Release (Kotlin Language & Compose Static Analysis)"
echo "   4. Unit Tests & Roborazzi Screenshot Tests"
echo "------------------------------------------------------------------"

cd "$ROOT_DIR"
./gradlew codeSanityCheck --stacktrace

echo ""
echo "=================================================================="
echo "🎉 Toutes les vérifications de code ont été exécutées avec succès !"
echo "📊 Rapports générés :"
echo "   • Lint Debug   : app/build/reports/lint-results-debug.html"
echo "   • Lint Release : app/build/reports/lint-results-release.html"
echo "   • Unit Tests   : app/build/reports/tests/testDebugUnitTest/index.html"
echo "=================================================================="
