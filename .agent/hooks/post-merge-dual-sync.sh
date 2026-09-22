#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Delivery Kernel — Post-Merge Dual-Sync Hook
# ==============================================================================
# Checks if the latest merged commit/PR resolves a source:crashlytics issue,
# extracts the Firebase Issue ID, and prints the exact MCP payload required
# for Persona 6 (Release Manager) to close the incident in Firebase.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PR_NUMBER="${1:-}"

echo "=================================================="
echo "🔄 Agentic Android Kernel — Post-Merge Dual-Sync Hook"
echo "=================================================="

# 1. Determine PR or commit message to inspect
if [ -z "$PR_NUMBER" ]; then
    COMMIT_MSG=$(git log -1 --pretty=%B)
    echo "ℹ️  No PR number provided. Inspecting HEAD commit message:"
    echo "   $(git log -1 --oneline)"
    ISSUE_MATCH=$(echo "$COMMIT_MSG" | grep -oE '(Closes|Fixes|Resolves) #[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
else
    echo "ℹ️  Inspecting PR #$PR_NUMBER via GitHub CLI..."
    PR_JSON=$(gh pr view "$PR_NUMBER" --json title,body,labels,mergedAt 2>/dev/null || true)
    ISSUE_MATCH=$(echo "$PR_JSON" | grep -oE '(Closes|Fixes|Resolves) #[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
fi

if [ -z "$ISSUE_MATCH" ]; then
    echo "ℹ️  No tracking issue resolved by this merge. Dual-sync not required."
    exit 0
fi

echo "🔍 Tracking Issue identified: #$ISSUE_MATCH"

# 2. Inspect issue labels to verify source:crashlytics
ISSUE_LABELS=$(gh issue view "$ISSUE_MATCH" --json labels --jq '.labels[].name' 2>/dev/null || true)

if echo "$ISSUE_LABELS" | grep -q "source:crashlytics"; then
    echo "🚨 Issue #$ISSUE_MATCH is labeled 'source:crashlytics'."
    
    # 3. Extract Firebase Issue ID from issue body
    ISSUE_BODY=$(gh issue view "$ISSUE_MATCH" --json body --jq '.body' 2>/dev/null || true)
    FIREBASE_ISSUE_ID=$(echo "$ISSUE_BODY" | grep -oE '([a-f0-9]{24,32}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|[0-9]{8,12})' | head -1 || true)
    
    if [ -z "$FIREBASE_ISSUE_ID" ]; then
        FIREBASE_ISSUE_ID="<FIREBASE_ISSUE_ID>"
    fi

    HEAD_SHA=$(git rev-parse --short HEAD)
    
    # Determine owner and repo
    GH_OWNER="<OWNER>"
    GH_REPO="<REPO>"
    if [ -f "$ROOT_DIR/kernel.config.json" ]; then
        GH_OWNER=$(node -e 'try { console.log(require("./kernel.config.json").git.owner || ""); } catch {}' 2>/dev/null || true)
        GH_REPO=$(node -e 'try { console.log(require("./kernel.config.json").git.repo || ""); } catch {}' 2>/dev/null || true)
    fi

    echo ""
    echo "=================================================="
    echo "⚡ ACTION REQUIRED BY PERSONA 6 (RELEASE MANAGER):"
    echo "=================================================="
    echo "1. Close the incident in Firebase Crashlytics via MCP:"
    echo "   firebase-mcp-server:crashlytics_update_issue {"
    echo "     \"issue_id\": \"$FIREBASE_ISSUE_ID\","
    echo "     \"state\": \"CLOSED\""
    echo "   }"
    echo ""
    echo "2. Post resolution proof comment on GitHub Issue #$ISSUE_MATCH:"
    echo "   GitHubMCP:add_issue_comment {"
    echo "     \"owner\": \"$GH_OWNER\","
    echo "     \"repo\": \"$GH_REPO\","
    echo "     \"issue_number\": $ISSUE_MATCH,"
    echo "     \"body\": \"✅ Crashlytics incident $FIREBASE_ISSUE_ID closed via Dual-Sync. Commit: $HEAD_SHA.\""
    echo "   }"
    echo "=================================================="
else
    echo "ℹ️  Issue #$ISSUE_MATCH does not carry 'source:crashlytics'. Dual-sync skipped."
fi

exit 0
