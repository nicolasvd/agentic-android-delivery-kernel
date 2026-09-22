#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Delivery Kernel — Local Git Hooks Installation & Binding Script
# ==============================================================================
# Binds git hooks to .agent/hooks and ensures all hooks are executable.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================================="
echo "⚓ Agentic Android Kernel — Local Git Hooks Installation"
echo "=================================================="

# 1. Ensure all scripts in .agent/hooks/ have executable permissions
echo "🔧 Setting executable permissions on .agent/hooks/..."
chmod +x "$ROOT_DIR/.agent/hooks"/*.sh 2>/dev/null || true
chmod +x "$ROOT_DIR/.agent/hooks"/*.mjs 2>/dev/null || true
if [ -f "$ROOT_DIR/.agent/hooks/post-checkout" ]; then
    chmod +x "$ROOT_DIR/.agent/hooks/post-checkout"
fi

# 2. Link pre-commit standard hook name to pre-commit-airbag.sh
if [ ! -e "$ROOT_DIR/.agent/hooks/pre-commit" ]; then
    echo "🔗 Creating symlink: .agent/hooks/pre-commit -> pre-commit-airbag.sh..."
    ln -sf "pre-commit-airbag.sh" "$ROOT_DIR/.agent/hooks/pre-commit"
fi
chmod +x "$ROOT_DIR/.agent/hooks/pre-commit"

# 3. Configure Git core.hooksPath locally
echo "⚙️  Configuring Git core.hooksPath to .agent/hooks..."
git -C "$ROOT_DIR" config core.hooksPath .agent/hooks

CURRENT_HOOKS_PATH=$(git -C "$ROOT_DIR" config core.hooksPath || true)
echo "✅ Git core.hooksPath is set to: $CURRENT_HOOKS_PATH"

echo "=================================================="
echo "🎉 Hooks installed successfully! Pre-commit airbag is now active."
echo "=================================================="
