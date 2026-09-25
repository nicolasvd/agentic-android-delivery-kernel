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
{"injectSteps":[{"ephemeralMessage":"[SYSTEM CONTEXT: Active branch: '$BRANCH' | State: Code / PR Review Loop. Apply all fixes or test feedback directly on this branch. Do NOT create a new issue or branch.]"}]}
EOF
else
    echo '{"injectSteps":[]}'
fi
