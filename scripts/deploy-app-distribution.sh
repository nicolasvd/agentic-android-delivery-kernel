#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Agentic Android Kernel — Local Firebase App Distribution (1-Click Upload)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SERVICE_ACCOUNT_FILE="$ROOT_DIR/service-account.json"
FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-<firebase-project-id>}"
FIREBASE_CONSOLE_URL="https://console.firebase.google.com/project/${FIREBASE_PROJECT_ID}/appdistribution"

echo "=================================================="
echo "🚀 Agentic Android Kernel — Local Firebase App Distribution"
echo "=================================================="

# 1. Check for service-account.json
if [ ! -f "$SERVICE_ACCOUNT_FILE" ]; then
    echo ""
    echo "❌ Erreur : Fichier '$SERVICE_ACCOUNT_FILE' introuvable !"
    echo ""
    echo "ℹ️  Comment obtenir et configurer vos identifiants :"
    echo "   1. Rendez-vous sur la console Google Cloud / Firebase :"
    echo "      https://console.cloud.google.com/iam-admin/serviceaccounts?project=${FIREBASE_PROJECT_ID}"
    echo "   2. Créez ou sélectionnez un compte de service avec le rôle 'Firebase App Distribution Admin'."
    echo "   3. Générez et téléchargez une clé privée au format JSON."
    echo "   4. Placez le fichier à la racine du projet sous le nom :"
    echo "      service-account.json"
    echo "   (Note : ce fichier est automatiquement ignoré par .gitignore pour votre sécurité)"
    echo ""
    exit 1
fi

echo "✅ Compte de service détecté : $SERVICE_ACCOUNT_FILE"

# 2. Extract Git version metadata
git -C "$ROOT_DIR" fetch --tags 2>/dev/null || true

# Compute Monotonic Multiplier (x100) versionCode or extract from build.gradle.kts
GRADLE_VERSION_CODE=$(grep -E '^\s*versionCode\s*=' "$ROOT_DIR/app/build.gradle.kts" 2>/dev/null | head -n 1 | sed -E 's/.*=[[:space:]]*([0-9]+).*/\1/' || echo "")
BASE_MAIN_COUNT=$(git -C "$ROOT_DIR" rev-list --count origin/main 2>/dev/null || git -C "$ROOT_DIR" rev-list --count main 2>/dev/null || git -C "$ROOT_DIR" rev-list --count HEAD 2>/dev/null || echo "50")
COMMITS_AHEAD_MAIN=$(git -C "$ROOT_DIR" rev-list origin/main..HEAD --count 2>/dev/null || git -C "$ROOT_DIR" rev-list main..HEAD --count 2>/dev/null || echo "0")
if [ "$COMMITS_AHEAD_MAIN" -gt 99 ]; then
    COMMITS_AHEAD_MAIN=99
fi
DEFAULT_VERSION_CODE="${GRADLE_VERSION_CODE:-$(( BASE_MAIN_COUNT * 100 + COMMITS_AHEAD_MAIN ))}"
VERSION_CODE=""

EXACT_TAG=$(git -C "$ROOT_DIR" describe --tags --exact-match 2>/dev/null || echo "")
if [ -n "$EXACT_TAG" ]; then
    VERSION_NAME="${EXACT_TAG#v}"
else
    LATEST_TAG=$(git -C "$ROOT_DIR" describe --tags --abbrev=0 2>/dev/null || echo "")
    if [ -n "$LATEST_TAG" ]; then
        BASE_TAG="${LATEST_TAG#v}"
        COMMITS_AHEAD=$(git -C "$ROOT_DIR" rev-list "${LATEST_TAG}..HEAD" --count 2>/dev/null || echo "0")
        if [ "$COMMITS_AHEAD" -gt 0 ]; then
            VERSION_NAME="${BASE_TAG}-dev.${COMMITS_AHEAD}"
        else
            VERSION_NAME="$BASE_TAG"
        fi
    else
        VERSION_NAME="0.1.0"
    fi
fi

# 3. Parse arguments & options
USER_GROUPS=""
USER_NOTES=""
BUILD_VARIANT="release"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --groups|-g)
            USER_GROUPS="$2"
            shift 2
            ;;
        --groups=*)
            USER_GROUPS="${1#*=}"
            shift
            ;;
        --version-code)
            VERSION_CODE="$2"
            shift 2
            ;;
        --version-code=*)
            VERSION_CODE="${1#*=}"
            shift
            ;;
        --variant|-v|--build-type)
            BUILD_VARIANT="$2"
            shift 2
            ;;
        --variant=*|--build-type=*)
            BUILD_VARIANT="${1#*=}"
            shift
            ;;
        release|debug)
            BUILD_VARIANT="$1"
            shift
            ;;
        *)
            if [ -z "$USER_NOTES" ]; then
                USER_NOTES="$1"
            fi
            shift
            ;;
    esac
done

VERSION_CODE="${VERSION_CODE:-$DEFAULT_VERSION_CODE}"

if [ -n "$USER_GROUPS" ]; then
    TARGET_GROUPS="$USER_GROUPS"
elif [ "$BUILD_VARIANT" = "debug" ]; then
    TARGET_GROUPS="${FIREBASE_DEBUG_TESTER_GROUPS:-admin}"
else
    TARGET_GROUPS="${FIREBASE_TESTER_GROUPS:-admin, testers}"
fi

# 4. Format Release Notes: v<versionName> (build <versionCode>) : <message>
if [ -n "$USER_NOTES" ]; then
    RAW_MESSAGE="$USER_NOTES"
else
    RAW_MESSAGE=$(git -C "$ROOT_DIR" log -1 --pretty=%B | sed '/^$/d')
    if [ -z "$RAW_MESSAGE" ]; then
        RAW_MESSAGE="Local build from branch $(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD)"
    fi
fi

FORMATTED_RELEASE_NOTES="v${VERSION_NAME} (build ${VERSION_CODE}) : ${RAW_MESSAGE}"

echo "📦 Version : v${VERSION_NAME} (build ${VERSION_CODE})"
echo "👥 Groupes cibles : $TARGET_GROUPS"
echo "🏗️  Variante build : $BUILD_VARIANT"
echo "📝 Notes de version :"
echo "--------------------------------------------------"
echo "$FORMATTED_RELEASE_NOTES"
echo "--------------------------------------------------"

# Write root release notes for Firebase Gradle plugin
echo "$FORMATTED_RELEASE_NOTES" > "$ROOT_DIR/release-notes.txt"
mkdir -p "$ROOT_DIR/app/build/outputs"
echo "$FORMATTED_RELEASE_NOTES" > "$ROOT_DIR/app/build/outputs/release-notes.txt"
export FIREBASE_RELEASE_NOTES="$FORMATTED_RELEASE_NOTES"
export FIREBASE_TESTER_GROUPS="$TARGET_GROUPS"
export GOOGLE_APPLICATION_CREDENTIALS="$SERVICE_ACCOUNT_FILE"

# 5. Detect and set Java environment if needed
if [ -z "${JAVA_HOME:-}" ] && [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
fi

ASSEMBLE_TASK="assembleDebug"
GRADLE_TASK="appDistributionUploadDebug"

if [ "$BUILD_VARIANT" = "release" ]; then
    ASSEMBLE_TASK="assembleRelease"
    GRADLE_TASK="appDistributionUploadRelease"
fi

echo ""
echo "📦 Lancement de la compilation ($ASSEMBLE_TASK) et de l'upload Firebase ($GRADLE_TASK)..."
echo ""

cd "$ROOT_DIR"
./gradlew "$ASSEMBLE_TASK" "$GRADLE_TASK" --stacktrace || {
    rm -f "$ROOT_DIR/release-notes.txt"
    exit 1
}

rm -f "$ROOT_DIR/release-notes.txt"

echo ""
echo "=================================================="
echo "🎉 Distribution locale terminée avec succès !"
echo "📱 Console Firebase App Distribution :"
echo "   $FIREBASE_CONSOLE_URL"
echo "=================================================="
