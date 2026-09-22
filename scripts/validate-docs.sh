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
# - Compétences Sémantiques (.agent/skills/)
# - Sidecars (.agent/sidecars/)
# - MCP Catalog (.agent/mcp-catalog.md)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================================================="
echo "📑 Agentic Android Kernel — Validation Complète de l'Architecture Multi-Agent"
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
            echo "  ❌ [DÉPASSEMENT] $file ($size octets > budget max $max_size octets)"
            FAILED=$((FAILED + 1))
        else
            echo "  ✅ [OK] $file ($desc — $size octets)"
        fi
    else
        echo "  ❌ [MANQUANT] $file ($desc)"
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
                echo "  ❌ [DÉPASSEMENT] $file ($size octets > budget max $max_size octets)"
                FAILED=$((FAILED + 1))
            else
                echo "  ✅ [OK] $file (exécutable — $size octets)"
            fi
        else
            echo "  ❌ [NON EXÉCUTABLE] $file ($desc — chmod +x requis)"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "  ❌ [MANQUANT] $file ($desc)"
        FAILED=$((FAILED + 1))
    fi
}

echo ""
echo "📦 1. Contrats Centraux de Design, Architecture & Configuration :"
check_file "DESIGN.md" "Spécification Design Tokens YAML"
check_file "design-system.md" "Référentiel Technique & Contrat Persona P2"
check_file "AGENTS.md" "Micro-Kernel Agent & Gouvernance Racine (< 10 000 octets)" 10000
check_file "agent.md" "Lien symbolique rétrocompatible agent.md -> AGENTS.md" 10000
check_file "README.md" "Vitrine Principale d'Ingénierie"
check_file "ARCHITECTURE.md" "Spécification Formelle de l'Architecture"
check_file "kernel.config.json" "Configuration Déclarative du Projet"
check_file "kernel.config.schema.json" "Schéma JSON Formel de Configuration"

echo ""
echo "📚 2. Documentation Technique de Gouvernance (docs/) :"
check_file "docs/analytics-taxonomy.md" "Contrat P3 : Taxonomie Zero-PII"
check_file "docs/qa-classification-test-guide.md" "Contrat P6 : Guide QA & Classification"
check_file "docs/scripts-reference.md" "Documentation de Référence des Scripts"

echo ""
echo "🤖 3. Manifestes Déclaratifs des Personas (.agent/personas/ — max 4 500 octets) :"
check_file ".agent/personas/p1-product-planner.md" "Persona 1 (Product Planner)" 4500
check_file ".agent/personas/p2-design-lead.md" "Persona 2 (Design Lead)" 4500
check_file ".agent/personas/p3-privacy-data.md" "Persona 3 (Privacy & Data Lead)" 4500
check_file ".agent/personas/p4-system-architect.md" "Persona 4 (System Architect)" 4500
check_file ".agent/personas/p5-software-engineer.md" "Persona 5 (Software Engineer)" 4500
check_file ".agent/personas/p6-release-manager.md" "Persona 6 (Release Manager)" 4500

echo ""
echo "📝 4. Gabarits Déterministes & Catalogue MCP (.agent/templates/ & .agent/) :"
check_file ".agent/mcp-catalog.md" "Catalogue des Interfaces MCP" 4000
check_file ".agent/skills.json" "Déclaration Native des Compétences Antigravity" 1000
check_file ".agent/templates/4-pillar-spec.md" "Template Cadrage 4 Piliers" 4500
check_file ".agent/templates/epic-spec.md" "Template Cadrage Epic" 4500
check_file ".agent/templates/pr-walkthrough.md" "Template Walkthrough PR" 4500
check_file ".agent/templates/crashlytics-triage-issue.md" "Template Triage Crashlytics" 4500

echo ""
echo "🐙 5. Alignement des Gabarits GitHub (.github/) :"
check_file ".github/PULL_REQUEST_TEMPLATE.md" "GitHub PR Template" 4500
check_file ".github/ISSUE_TEMPLATE/bug_report.yml" "GitHub Issue Form Bug Report" 5000
check_file ".github/ISSUE_TEMPLATE/crashlytics_triage.yml" "GitHub Issue Form Crashlytics" 5000
check_file ".github/ISSUE_TEMPLATE/feature_idea.yml" "GitHub Issue Form Feature Idea" 5000
check_file ".github/ISSUE_TEMPLATE/config.yml" "GitHub Issue Config" 2000
check_file ".github/workflows/delivery-pipeline.yml" "GitHub Actions Workflow Delivery Pipeline & Quality Gate"

echo ""
echo "🧠 6. Playbooks Techniques Modulaires (.agent/playbooks/ — max 8 500 octets) :"
check_file ".agent/playbooks/room-migrations.md" "Playbook Room Migrations" 8500
check_file ".agent/playbooks/roborazzi-export.md" "Playbook Roborazzi Export" 8500
check_file ".agent/playbooks/compose-theming.md" "Playbook Compose Theming" 8500
check_file ".agent/playbooks/android-standards.md" "Playbook Android Standards" 8500

echo ""
echo "🛡️ 7. Règles Maîtresses de Gouvernance (.agent/rules/ — max 9 500 octets) :"
check_file ".agent/rules/agent-lifecycle.md" "Cycle de Vie en 3 Phases" 9500
check_file ".agent/rules/backlog-planner.md" "Planification Autonome & 4 Piliers" 9500
check_file ".agent/rules/git-workflow.md" "Stratégie Git & Convention Commits" 9500
check_file ".agent/rules/firebase-standards.md" "Standards Firebase & Sécurité" 9500

echo ""
echo "⚙️ 8. Hooks Locaux & Scripts d'Installation :"
check_executable "scripts/install-hooks.sh" "Script d'Installation des Hooks"
check_executable ".agent/hooks/pre-commit-airbag.sh" "Hook Pré-Commit Airbag"
check_executable ".agent/hooks/post-merge-dual-sync.sh" "Hook Post-Merge Dual-Sync"
check_file ".agent/hooks.json" "Déclaration Native des Hooks Antigravity" 1000
check_executable ".agent/hooks/branch-guard.mjs" "Hook Branch-Guard PreToolUse" 3000
check_executable ".agent/hooks/pre-invocation-anchor.sh" "Hook Context-Anchor PreInvocation" 1000
check_executable ".agent/hooks/post-checkout" "Hook Post-Checkout Issue Progress Sync" 2000

echo ""
echo "🛸 9. Sidecars Déterministes (.agent/sidecars/ — max 4 500 octets) :"
check_executable ".agent/sidecars/sync-issue-progress.mjs" "Sidecar Sync Issue Progress" 4500

echo ""
echo "⚡ 10. Compétences Sémantiques Natives (.agent/skills/ — max 4 500 octets) :"
check_file ".agent/skills/plan-issue/SKILL.md" "Skill plan-issue (Inception & Cadrage)" 4500
check_file ".agent/skills/open-pr/SKILL.md" "Skill open-pr (Release & Walkthrough)" 4500
check_file ".agent/skills/quality-airbag/SKILL.md" "Skill quality-airbag (Inspection Qualité)" 4500
check_file ".agent/skills/sync-stitch/SKILL.md" "Skill sync-stitch (Synchro Stitch MCP)" 4500

echo ""
echo "🔍 11. Vérification du Frontmatter YAML dans DESIGN.md :"
if grep -q "name:.*Serene Intellectual" "$ROOT_DIR/DESIGN.md"; then
    echo "  ✅ [OK] YAML Frontmatter 'Serene Intellectual' détecté dans DESIGN.md"
else
    echo "  ❌ [INVALIDE] Frontmatter YAML invalide ou manquant dans DESIGN.md"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "=================================================================="
if [ "$FAILED" -eq 0 ]; then
    echo "🎉 Tous les contrats documentaires, personas, templates, skills, hooks, sidecars et règles sont validés !"
    echo "=================================================================="
    exit 0
else
    echo "🚨 ÉCHEC : $FAILED anomalie(s) détectée(s) dans l'architecture multi-agent !"
    echo "=================================================================="
    exit 1
fi
