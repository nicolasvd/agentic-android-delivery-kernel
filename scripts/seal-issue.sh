#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Delivery Kernel — Deterministic Issue Sealer
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

function print_usage() {
    cat <<EOF
Usage: seal-issue.sh [options]

Modes:
  --from-plan [path]       Seal issue atomically from plan (default: implementation_plan.md)
  --sync <issue_id>        Synchronize Project v2 metadata for an existing issue
  --dry-run                Simulate without remote mutations
  -h, --help               Display help

Options (for --sync mode):
  --priority <P0|P1|P2>    Set Priority
  --size <XS|S|M|L|XL>     Set Size
  --estimate <number>      Set Estimate
  --status <StatusName>    Set Status
EOF
}

MODE=""
PLAN_FILE="implementation_plan.md"
DRY_RUN=false
SYNC_ISSUE_ID=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --from-plan)
            MODE="plan"
            if [[ $# -gt 1 && ! "$2" =~ ^-- ]]; then PLAN_FILE="$2"; shift; fi
            shift
            ;;
        --sync)
            MODE="sync"
            if [[ $# -gt 1 && ! "$2" =~ ^-- ]]; then SYNC_ISSUE_ID="$2"; shift; fi
            shift
            ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) print_usage; exit 0 ;;
        *) EXTRA_ARGS+=("$1"); shift ;;
    esac
done

if [ -z "$MODE" ]; then
    if [ -f "$ROOT_DIR/$PLAN_FILE" ] || [ -f "$PLAN_FILE" ]; then MODE="plan"; else print_usage; exit 1; fi
fi

if [ "$MODE" = "sync" ]; then
    if [ -z "$SYNC_ISSUE_ID" ]; then
        echo "❌ Error: --sync requires a numeric Issue ID."
        exit 1
    fi
    SYNC_SCRIPT="$SCRIPT_DIR/sync-project-metadata.mjs"
    DRY_FLAG=""
    if [ "$DRY_RUN" = true ]; then DRY_FLAG="--dry-run"; fi
    node "$SYNC_SCRIPT" "$SYNC_ISSUE_ID" "${EXTRA_ARGS[@]}" $DRY_FLAG
    exit 0
fi

TARGET_PLAN="$ROOT_DIR/$PLAN_FILE"
if [ ! -f "$TARGET_PLAN" ]; then
    if [ -f "$PLAN_FILE" ]; then TARGET_PLAN="$PLAN_FILE"; else
        echo "❌ Error: Plan file '$PLAN_FILE' not found."
        exit 1
    fi
fi

echo "=================================================="
echo "🔒 Agentic Android Kernel — JIT Issue Sealer"
echo "=================================================="
echo "📄 Target Plan: $TARGET_PLAN"

TEMP_VARS=$(mktemp)
TEMP_BODY=$(mktemp)

node -e '
  const fs = require("fs");
  const planPath = process.argv[1];
  const varsPath = process.argv[2];
  const bodyPath = process.argv[3];
  const content = fs.readFileSync(planPath, "utf8");

  let type = "feat", scope = "core", parent = "", milestone = "";
  let priority = "P1", size = "M", estimate = "1.0", titleRaw = "";

  const fmM = content.match(/^---\s*\n([\s\S]*?)\n---/);
  if (fmM) {
    const y = fmM[1];
    const getVal = (regex, def) => { const m = y.match(regex); return m && m[1] !== "null" ? m[1].trim() : def; };
    type = getVal(/type:\s*["\x27]?([^"\x27\n\r]+)/, "feat");
    scope = getVal(/scope:\s*["\x27]?([^"\x27\n\r]+)/, "core");
    parent = getVal(/parent:\s*["\x27]?([^"\x27\n\r]+)/, "");
    milestone = getVal(/milestone:\s*["\x27]?([^"\x27\n\r]+)/, "");
    priority = getVal(/priority:\s*["\x27]?([^"\x27\n\r]+)/, "P1");
    size = getVal(/size:\s*["\x27]?([^"\x27\n\r]+)/, "M");
    estimate = getVal(/estimate:\s*([0-9.]+)/, "1.0");
  }

  const lines = content.split("\n");
  for (const line of lines) {
    if (line.startsWith("# ")) {
      titleRaw = line.substring(2).trim();
      break;
    }
  }

  const cleanTitle = titleRaw.replace(/^[a-zA-Z0-9_-]+(\([a-zA-Z0-9_.-]+\))?:\s*/, "");
  const formattedTitle = (scope && scope !== "core") ? `${type}(${scope}): ${cleanTitle}` : `${type}: ${cleanTitle}`;
  const slug = cleanTitle.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").substring(0, 40);

  const escapeBash = (str) => String(str).replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/`/g, "\\`").replace(/\$/g, "\\$");

  fs.writeFileSync(varsPath, `TYPE="${escapeBash(type)}"\nSCOPE="${escapeBash(scope)}"\nPARENT="${escapeBash(parent)}"\nMILESTONE="${escapeBash(milestone)}"\nPRIORITY="${escapeBash(priority)}"\nSIZE="${escapeBash(size)}"\nESTIMATE="${escapeBash(estimate)}"\nFORMATTED_TITLE="${escapeBash(formattedTitle)}"\nSLUG="${escapeBash(slug)}"\n`, "utf8");

  let body = content.replace(/^---\s*\n[\s\S]*?\n---\s*\n/, "");
  body = body.split("\n").filter(line => {
    if (/^>\s*\*\*Parent Epic\*\*/i.test(line)) return false;
    if (/^>\s*\*\*Sprint\*\*/i.test(line)) return false;
    if (/^>\s*\*\*Milestone\*\*/i.test(line)) return false;
    return true;
  }).join("\n");
  body = body.replace(/##\s*🧭\s*Native Metadata Triad[\s\S]*?(?=\n##|\n---|$)/i, "");
  fs.writeFileSync(bodyPath, body.trim() + "\n", "utf8");
' "$TARGET_PLAN" "$TEMP_VARS" "$TEMP_BODY"

# shellcheck disable=SC1090
source "$TEMP_VARS"
rm -f "$TEMP_VARS"

echo "📌 Resolved Metadata:"
echo "   • Title:     $FORMATTED_TITLE"
echo "   • Type:      $TYPE"
echo "   • Scope:     $SCOPE"
echo "   • Priority:  $PRIORITY"
echo "   • Size:      $SIZE"
echo "   • Estimate:  $ESTIMATE"
echo "   • Milestone: ${MILESTONE:-'(none)'}"
echo "   • Parent:    ${PARENT:-'(none)'}"

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "🔍 [Dry-Run] Issue Body Preview:"
    head -n 8 "$TEMP_BODY"
    echo "..."
    echo "✅ [Dry-Run] Simulation complete. Zero remote mutations."
    rm -f "$TEMP_BODY"
    exit 0
fi

LABEL_TYPE="$TYPE"
case "$TYPE" in
    feat) LABEL_TYPE="feature" ;;
    fix) LABEL_TYPE="bug" ;;
    docs) LABEL_TYPE="documentation" ;;
esac

echo "🚀 Sealing Issue on GitHub via CLI..."
GH_ARGS=(
    issue create
    --title "$FORMATTED_TITLE"
    --body-file "$TEMP_BODY"
    --assignee "@me"
    --label "${LABEL_TYPE},source:internal"
)
if [ -n "$MILESTONE" ]; then GH_ARGS+=(--milestone "$MILESTONE"); fi
if [ -n "$PARENT" ]; then GH_ARGS+=(--parent "$PARENT"); fi

ISSUE_URL=$(gh "${GH_ARGS[@]}")
rm -f "$TEMP_BODY"

if [ -z "$ISSUE_URL" ]; then
    echo "❌ Error: Failed to create issue."
    exit 1
fi

ISSUE_ID=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
echo "✅ Sealed Issue #$ISSUE_ID: $ISSUE_URL"

SYNC_SCRIPT="$SCRIPT_DIR/sync-project-metadata.mjs"
if [ -f "$SYNC_SCRIPT" ]; then
    echo "📊 Synchronizing Project v2 fields..."
    node "$SYNC_SCRIPT" "$ISSUE_ID" \
        --priority "$PRIORITY" \
        --size "$SIZE" \
        --estimate "$ESTIMATE" \
        --status "Ready" || true
fi

BRANCH_NAME="${TYPE}/issue-${ISSUE_ID}-${SLUG}"
if [ "$TYPE" = "epic" ] || [ "$SIZE" = "L" ] || [ "$SIZE" = "XL" ]; then
    BRANCH_NAME="epic/issue-${ISSUE_ID}-${SLUG}"
    echo "🏛️ Creating Epic Branch: $BRANCH_NAME..."
    git checkout -b "$BRANCH_NAME" origin/main
    git push -u origin "$BRANCH_NAME" || true
fi

node -e '
  const fs = require("fs");
  const p = process.argv[1], id = process.argv[2], b = process.argv[3];
  let c = fs.readFileSync(p, "utf8");
  c = c.replace(/issue:\s*(null|[0-9]+)/, "issue: " + id);
  c = c.replace(/branch:\s*(null|["\x27]?[^"\x27\n\r]+)/, "branch: " + b);
  c = c.replace(/status:\s*proposed/, "status: approved");
  c = c.replace(/gate:\s*Gate 1\.4 \(Inception Halt\)/, "gate: Gate 1.4 (Inception Halt - APPROVED)");
  fs.writeFileSync(p, c, "utf8");
' "$TARGET_PLAN" "$ISSUE_ID" "$BRANCH_NAME"

echo "=================================================="
echo "🎉 Issue #$ISSUE_ID successfully sealed and synced!"
echo "   Branch: $BRANCH_NAME"
echo "   URL:    $ISSUE_URL"
echo "=================================================="
