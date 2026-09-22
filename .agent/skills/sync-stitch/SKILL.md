---
name: sync-stitch
description: Native Antigravity design synchronization skill to upload Roborazzi screenshots and align Material 3 design tokens with Google Stitch MCP.
triggers:
  - "sync stitch"
  - "stitch sync"
  - "upload screenshots"
  - "update design system"
  - "roborazzi stitch"
  - "/sync-stitch"
owner: Persona 2 (Design Lead)
consumers: [P2, P5]
version: 2.0.0
---

# Skill: `sync-stitch` (Inception Consortium — Persona 2)

Standardizes deterministic synchronization between Android code (Jetpack Compose, themes, Roborazzi captures) and the **Google Stitch MCP** project.

> **Governance References**:
> - [`agent.md`](../../../agent.md) — *Stitch MCP Integration & Guardrails*
> - [`design-system.md`](../../../design-system.md) — *Screen Registry & Roborazzi Screenshot Inventory*
> - [`DESIGN.md`](../../../DESIGN.md) — *Canonical Specification (Serene Intellectual)*
> - [`.agent/playbooks/roborazzi-export.md`](../../playbooks/roborazzi-export.md) — *Roborazzi Export Playbook*

---

## 🎯 Sequential Execution Recipe

### Step 1: Record Roborazzi Snapshot Suite
Generate the full Roborazzi capture suite for Light and Dark themes (393x852 dp xxhdpi):
```bash
./gradlew recordRoborazziDebug
```

### Step 2: Specification Integrity Check
Verify presence and conformity of core design contracts:
- `DESIGN.md`: YAML frontmatter (`Serene Intellectual v1.0.0`) and M3 palettes.
- `design-system.md`: Screen registry matrix, tokens, and contrast audits.
- `agent.md`: Stitch Target Project ID `<stitch-project-id>`.

### Step 3: In-Place Visual Synchronization
Launch deterministic sync targeting Stitch Project `<stitch-project-id>`:
```bash
./scripts/generate-screenshots.sh
python3 scripts/upload-screenshots.py
```

### Step 4: Verification via StitchMCP
Audit updated screens using read-only MCP queries:
```json
StitchMCP:list_screens { "project_id": "<stitch-project-id>" }
StitchMCP:get_screen { "screen_id": "<screen_id>" }
```

> [!IMPORTANT]
> **Zero Text Generation Rule**: Visual sync with Stitch operates **strictly** via direct PNG upload onto existing `screen_id` entries. Generating textual layouts or UI prompts inside Stitch is strictly prohibited.
