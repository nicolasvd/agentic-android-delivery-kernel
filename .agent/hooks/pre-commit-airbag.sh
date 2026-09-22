#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Delivery Kernel — Pre-Commit Quality Airbag Hook
# ==============================================================================
# Runs code quality inspections and verifies that no hardcoded user-facing
# strings were staged in Kotlin Compose files before allowing git commit.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================="
echo "🛡️  Agentic Android Kernel — Pre-Commit Airbag Hook"
echo "=================================================="

# Read configuration from kernel.config.json if available
ENFORCE_ZERO_STRINGS=true
CHECK_CMD="./scripts/quality-check.sh"
DOC_CMD="./scripts/validate-docs.sh"

if [ -f "$ROOT_DIR/kernel.config.json" ]; then
    CFG_STRINGS=$(node -e 'try { console.log(require("./kernel.config.json").airbag.enforceZeroHardcodedStrings ?? true); } catch { console.log("true"); }' 2>/dev/null || echo "true")
    if [ "$CFG_STRINGS" = "false" ]; then
        ENFORCE_ZERO_STRINGS=false
    fi
    CFG_CHECK=$(node -e 'try { console.log(require("./kernel.config.json").airbag.checkCommand || "./scripts/quality-check.sh"); } catch { console.log("./scripts/quality-check.sh"); }' 2>/dev/null || echo "./scripts/quality-check.sh")
    if [ -n "$CFG_CHECK" ]; then
        CHECK_CMD="$CFG_CHECK"
    fi
    CFG_DOC=$(node -e 'try { console.log(require("./kernel.config.json").airbag.validateDocsCommand || "./scripts/validate-docs.sh"); } catch { console.log("./scripts/validate-docs.sh"); }' 2>/dev/null || echo "./scripts/validate-docs.sh")
    if [ -n "$CFG_DOC" ]; then
        DOC_CMD="$CFG_DOC"
    fi
fi

# 1. Audit staged Kotlin files for hardcoded strings in Text(...) composables
if [ "$ENFORCE_ZERO_STRINGS" = true ]; then
    echo "🔍 1. Auditing staged Kotlin files for hardcoded strings..."
    STAGED_KT_FILES=$(git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACM | grep '\.kt$' || true)

    if [ -n "$STAGED_KT_FILES" ]; then
        HARDCODED_FOUND=0
        while IFS= read -r file; do
            if [ -f "$ROOT_DIR/$file" ]; then
                # Look for Text("literal") or contentDescription = "literal" on staged diffs
                SUSPICIOUS=$(git -C "$ROOT_DIR" diff --cached "$ROOT_DIR/$file" | grep -E '^\+[ ]*(Text\(["\x27]|contentDescription\s*=\s*["\x27])' || true)
                if [ -n "$SUSPICIOUS" ]; then
                    echo "  ❌ Potential hardcoded string in $file:"
                    echo "$SUSPICIOUS" | sed 's/^/     /'
                    HARDCODED_FOUND=1
                fi
            fi
        done <<< "$STAGED_KT_FILES"

        if [ "$HARDCODED_FOUND" -eq 1 ]; then
            echo ""
            echo "🚨 COMMIT BLOCKED: User-facing text must reside in res/values/strings.xml."
            echo "   Use stringResource(R.string.<key>) instead of hardcoded strings."
            echo "=================================================="
            exit 1
        fi
        echo "  ✅ Zero hardcoded strings detected in staged files."
    else
        echo "  ℹ️  No Kotlin files staged."
    fi
else
    echo "  ℹ️  Hardcoded strings enforcement is disabled in kernel.config.json."
fi

# 2. Run documentation contract validation
echo ""
echo "📑 2. Validating documentation contracts..."
if [ -f "$ROOT_DIR/$DOC_CMD" ]; then
    "$ROOT_DIR/$DOC_CMD"
else
    echo "  ⚠️ $DOC_CMD not found, skipping doc check."
fi

# 3. Run Quality Check suite if check command is present
echo ""
echo "🧪 3. Running code sanity check ($CHECK_CMD)..."
if [ -f "$ROOT_DIR/$CHECK_CMD" ]; then
    "$ROOT_DIR/$CHECK_CMD"
elif [ -f "$ROOT_DIR/gradlew" ]; then
    cd "$ROOT_DIR"
    ./gradlew codeSanityCheck --stacktrace
else
    echo "  ⚠️ $CHECK_CMD not found and gradlew missing. Airbag passed with warning."
fi

echo ""
echo "=================================================="
echo "✅ Airbag passed: All pre-commit checks succeeded."
echo "=================================================="
exit 0
