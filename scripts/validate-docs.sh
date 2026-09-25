#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Kernel — Documentation & Multi-Agent Architecture Validation Suite
# ==============================================================================
# Verifies presence, structural integrity, and character budgeting across:
# - Core contracts (DESIGN.md, design-system.md, AGENTS.md, agent.md, README.md, ARCHITECTURE.md)
# - Declarative configuration (kernel.config.json & schema)
# - Technical docs (docs/analytics-taxonomy.md, qa-classification-test-guide.md, scripts-reference.md)
# - Personas (.agent/personas/)
# - Templates (.agent/templates/ & .github/)
# - Playbooks (.agent/playbooks/)
# - Rules (.agent/rules/)
# - Hooks (.agent/hooks/ & scripts/install-hooks.sh)
# - Semantic Skills (.agent/skills/)
# - Sidecars (.agent/sidecars/)
# - MCP Catalog (.agent/mcp-catalog.md)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================================================="
echo "📑 Agentic Android Kernel — Full Multi-Agent Architecture Validation"
echo "=================================================================="

FAILED=0

check_file() {
    local file="$1"
    local desc="$2"
    local max_size="${3:-0}"
    
    if [ -f "$ROOT_DIR/$file" ]; then
        local size
        size=$(wc -c < "$ROOT_DIR/$file" | tr -d ' ')
        if [ "$max_size" -gt 0 ] && [ "$size" -gt "$max_size" ]; then
            echo "  ❌ [OVER BUDGET] $file ($size bytes > max budget $max_size bytes)"
            FAILED=$((FAILED + 1))
        else
            echo "  ✅ [OK] $file ($desc — $size bytes)"
        fi
    else
        echo "  ❌ [MISSING] $file ($desc)"
        FAILED=$((FAILED + 1))
    fi
}

check_executable() {
    local file="$1"
    local desc="$2"
    local max_size="${3:-0}"
    
    if [ -f "$ROOT_DIR/$file" ]; then
        if [ -x "$ROOT_DIR/$file" ]; then
            local size
            size=$(wc -c < "$ROOT_DIR/$file" | tr -d ' ')
            if [ "$max_size" -gt 0 ] && [ "$size" -gt "$max_size" ]; then
                echo "  ❌ [OVER BUDGET] $file ($size bytes > max budget $max_size bytes)"
                FAILED=$((FAILED + 1))
            else
                echo "  ✅ [OK] $file (executable — $size bytes)"
            fi
        else
            echo "  ❌ [NOT EXECUTABLE] $file ($desc — chmod +x required)"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "  ❌ [MISSING] $file ($desc)"
        FAILED=$((FAILED + 1))
    fi
}

echo ""
echo "📦 1. Core Contracts: Design, Architecture & Configuration:"
check_file "DESIGN.md" "YAML Design Tokens Specification"
check_file "design-system.md" "Technical Reference & Persona P2 Contract"
check_file "AGENTS.md" "Agent Micro-Kernel & Root Governance (< 10,000 bytes)" 10000
check_file "agent.md" "Backward-compatible symlink agent.md -> AGENTS.md" 10000
check_file "README.md" "Main Engineering Showcase"
check_file "ARCHITECTURE.md" "Formal Architecture Specification"
check_file "kernel.config.json" "Declarative Project Configuration"
check_file "kernel.config.schema.json" "Formal JSON Schema Configuration"

echo ""
echo "📚 2. Governance Technical Documentation (docs/):"
check_file "docs/analytics-taxonomy.md" "P3 Contract: Zero-PII Taxonomy"
check_file "docs/qa-classification-test-guide.md" "P6 Contract: QA & Classification Guide"
check_file "docs/scripts-reference.md" "Scripts Reference Documentation"

echo ""
echo "🤖 3. Declarative Persona Manifests (.agent/personas/ — max 4,500 bytes):"
check_file ".agent/personas/p1-product-planner.md" "Persona 1 (Product Planner)" 4500
check_file ".agent/personas/p2-design-lead.md" "Persona 2 (Design Lead)" 4500
check_file ".agent/personas/p3-privacy-data.md" "Persona 3 (Privacy & Data Lead)" 4500
check_file ".agent/personas/p4-system-architect.md" "Persona 4 (System Architect)" 4500
check_file ".agent/personas/p5-software-engineer.md" "Persona 5 (Software Engineer)" 4500
check_file ".agent/personas/p6-release-manager.md" "Persona 6 (Release Manager)" 4500

echo ""
echo "📝 4. Deterministic Templates & MCP Catalog (.agent/templates/ & .agent/):"
check_file ".agent/mcp-catalog.md" "MCP Interface Catalog" 4000
check_file ".agent/skills.json" "Native Antigravity Skills Declaration" 1000
check_file ".agent/templates/4-pillar-spec.md" "4-Pillar Spec Template" 4500
check_file ".agent/templates/epic-spec.md" "Epic Spec Template" 4500
check_file ".agent/templates/pr-walkthrough.md" "PR Walkthrough Template" 4500
check_file ".agent/templates/crashlytics-triage-issue.md" "Crashlytics Triage Template" 4500

echo ""
echo "🐙 5. GitHub Template Alignment (.github/):"
check_file ".github/PULL_REQUEST_TEMPLATE.md" "GitHub PR Template" 4500
check_file ".github/ISSUE_TEMPLATE/bug_report.yml" "GitHub Issue Form Bug Report" 5000
check_file ".github/ISSUE_TEMPLATE/crashlytics_triage.yml" "GitHub Issue Form Crashlytics" 5000
check_file ".github/ISSUE_TEMPLATE/feature_idea.yml" "GitHub Issue Form Feature Idea" 5000
check_file ".github/ISSUE_TEMPLATE/config.yml" "GitHub Issue Config" 2000
check_file ".github/workflows/delivery-pipeline.yml" "GitHub Actions Workflow Delivery Pipeline & Quality Gate"

echo ""
echo "🧠 6. Modular Technical Playbooks (.agent/playbooks/ — max 8,500 bytes):"
check_file ".agent/playbooks/room-migrations.md" "Playbook Room Migrations" 8500
check_file ".agent/playbooks/roborazzi-export.md" "Playbook Roborazzi Export" 8500
check_file ".agent/playbooks/compose-theming.md" "Playbook Compose Theming" 8500
check_file ".agent/playbooks/android-standards.md" "Playbook Android Standards" 8500

echo ""
echo "🛡️ 7. Master Governance Rules (.agent/rules/ — max 9,500 bytes):"
check_file ".agent/rules/agent-lifecycle.md" "3-Phase Lifecycle" 9500
check_file ".agent/rules/backlog-planner.md" "Autonomous Planning & 4 Pillars" 9500
check_file ".agent/rules/git-workflow.md" "Git Strategy & Conventional Commits" 9500
check_file ".agent/rules/firebase-standards.md" "Firebase Standards & Security" 9500

echo ""
echo "⚙️ 8. Local Hooks & Installation Scripts:"
check_executable "scripts/install-hooks.sh" "Hooks Installation Script"
check_executable ".agent/hooks/pre-commit-airbag.sh" "Pre-Commit Airbag Hook"
check_executable ".agent/hooks/post-merge-dual-sync.sh" "Post-Merge Dual-Sync Hook"
check_file ".agent/hooks.json" "Native Antigravity Hooks Declaration" 1000
check_executable ".agent/hooks/branch-guard.mjs" "Branch-Guard PreToolUse Hook" 3000
check_executable ".agent/hooks/plan-guard.mjs" "Plan-Guard PreToolUse Hook" 5500
check_executable ".agent/hooks/pre-invocation-anchor.sh" "Context-Anchor PreInvocation Hook" 1000
check_executable ".agent/hooks/post-checkout" "Post-Checkout Issue Progress Sync Hook" 2000

echo ""
echo "🛸 9. Deterministic Sidecars (.agent/sidecars/ — max 4,500 bytes):"
check_executable ".agent/sidecars/sync-issue-progress.mjs" "Sidecar Sync Issue Progress" 4500

echo ""
echo "⚡ 10. Native Semantic Skills (.agent/skills/ — max 4,500 bytes):"
check_file ".agent/skills/plan-issue/SKILL.md" "Skill plan-issue (Inception & Scoping)" 4500
check_file ".agent/skills/open-pr/SKILL.md" "Skill open-pr (Release & Walkthrough)" 4500
check_file ".agent/skills/quality-airbag/SKILL.md" "Skill quality-airbag (Quality Inspection)" 4500
check_file ".agent/skills/sync-stitch/SKILL.md" "Skill sync-stitch (Stitch MCP Sync)" 4500

echo ""
echo "🔍 11. YAML Frontmatter Verification in DESIGN.md:"
if grep -q "name:.*Serene Intellectual" "$ROOT_DIR/DESIGN.md"; then
    echo "  ✅ [OK] YAML Frontmatter 'Serene Intellectual' detected in DESIGN.md"
else
    echo "  ❌ [INVALID] Invalid or missing YAML Frontmatter in DESIGN.md"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "=================================================================="
if [ "$FAILED" -eq 0 ]; then
    echo "🎉 All documentation contracts, personas, templates, skills, hooks, sidecars, and rules validated!"
    echo "=================================================================="
    exit 0
else
    echo "🚨 FAILURE: $FAILED defect(s) detected in multi-agent architecture!"
    echo "=================================================================="
    exit 1
fi
