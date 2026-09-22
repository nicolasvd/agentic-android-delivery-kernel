#!/usr/bin/env bash
# PreInvocation Context Anchor Hook
set -euo pipefail

BRANCH=$(git branch --show-current 2>/dev/null || true)
DEF="main"
if [ -f "kernel.config.json" ]; then
    DEF=$(node -e 'try{console.log(require("./kernel.config.json").git.defaultBranch||"main");}catch{console.log("main");}' 2>/dev/null || echo "main")
fi

if [ -n "$BRANCH" ] && [ "$BRANCH" != "$DEF" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
    cat <<EOF
{"injectSteps":[{"ephemeralMessage":"[SYSTEM CONTEXT: Branche active: '$BRANCH' | État: Code / PR Review Loop. Applique toute correction ou retour de test directement sur cette branche. Ne PAS créer de nouvelle issue ni de nouvelle branche.]"}]}
EOF
else
    echo '{"injectSteps":[]}'
fi
