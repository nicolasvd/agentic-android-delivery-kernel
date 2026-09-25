#!/usr/bin/env bash
# ==============================================================================
# Agentic Android Kernel — Generate Roborazzi Screenshots
# ==============================================================================
# Runs Robolectric/Roborazzi UI tests to generate or update
# local application screenshots (in build/outputs/roborazzi).
# ==============================================================================

set -euo pipefail

echo "=================================================="
echo "📸 Agentic Android Kernel — Generating Roborazzi Screenshots"
echo "=================================================="

# Execute the standard Gradle task to record Roborazzi screenshots.
./gradlew recordRoborazziDebug --stacktrace

echo "=================================================="
echo "✨ Screenshots generated successfully in build/outputs/roborazzi!"
echo "=================================================="
