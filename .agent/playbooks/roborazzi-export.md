---
id: roborazzi-export
consumers: [P2, P5, P6]
version: 1.0.0
triggers: Any Composable UI change, new screen, or Stitch sync cycle
---

# Skill: Roborazzi Snapshot Testing & Export

> Extracted from `scripts/generate-screenshots.sh`, `scripts/upload-screenshots.py`, `StitchScreenshotCaptureTest.kt`, `GreetingScreenshotTest.kt`, and the Stitch screen mapping in `upload-screenshots.py`.

---

## 1. Gradle Commands

| Command | Purpose |
|---|---|
| `./gradlew recordRoborazziDebug` | **Generate / update** reference PNGs (golden images). Run after intentional UI changes. |
| `./gradlew verifyRoborazziDebug` | **Verify** current render against stored golden images. Run in CI and pre-PR. |
| `./gradlew compareRoborazziDebug` | Generate diff images showing pixel-level changes. Useful during review. |

**Script alias** (uses `recordRoborazziDebug` internally):
```bash
./scripts/generate-screenshots.sh
# Output: build/outputs/roborazzi/<TestClass>_<method>.png
```

---

## 2. Writing a Roborazzi Snapshot Test

```kotlin
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [33], qualifiers = "w411dp-h891dp-mdpi-night")   // specify density + dark mode
class YourScreenSnapshotTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun snapshot_YourScreen_Default_Light() {
        composeTestRule.setContent {
            SecondBrainTheme(darkTheme = false) {
                YourScreen(uiState = YourUiState.Content(items = fakeItems))
            }
        }
        composeTestRule.onRoot()
            .captureRoboImage(
                filePath = "screenshots/01_your_screen_light.png"
            )
    }

    @Test
    fun snapshot_YourScreen_Loading_Dark() {
        composeTestRule.setContent {
            SecondBrainTheme(darkTheme = true) {
                YourScreen(uiState = YourUiState.Loading)
            }
        }
        composeTestRule.onRoot()
            .captureRoboImage("screenshots/01_your_screen_dark_loading.png")
    }
}
```

**Required combinations per screen** (minimum):
- Light / Default (populated content)
- Dark / Default
- Light / Loading (shimmer)
- Light / Empty (empty state)
- Light / Error (retry state)

---

## 3. Screenshot Cataloging Conventions

Output path convention: `screenshots/<index>_<screen_slug>_<theme>.png`

| Index | Screen | Stitch Screen ID |
|---|---|---|
| `01` | Home Dashboard | `e36680a818ec4afaa0fde7e69511445b` |
| `02` | Daily Prioritization | `3efabd19844440a68ad1ba9c798c8828` |
| `03` | Clarity Matrix | `93665bc223bd43baa8eb549dd469129d` |
| `04` | Add Mental Load | _(see `upload-screenshots.py` SCREEN_MAPPING)_ |

Rules:
- Index is 2-digit, zero-padded. Never reuse an index for a different screen.
- `_light` suffix for default theme; `_dark` suffix for dark mode.
- `_loading`, `_empty`, `_error` suffixes for non-default states.

---

## 4. Visual Sync with Stitch (P2 workflow)

Sync is deterministic and in-place — screenshots are uploaded to **existing Stitch screen IDs only**.

```bash
# Sync all light screenshots to Stitch
python3 scripts/upload-screenshots.py

# Sync a specific screenshot
python3 scripts/upload-screenshots.py --screen-id e36680a818ec4afaa0fde7e69511445b \
  --file screenshots/01_home_dashboard_light.png

# Env var required
export STITCH_API_KEY="<injected by host, never committed>"
```

**Guardrails enforced by `upload-screenshots.py`**:
- Mapping is canonical — only screens in `SCREEN_MAPPING` are touched.
- Zero orphan screen creation (`upload_design_md` / screen generation is forbidden here).
- Zero textual prompt generation or hallucination from the PNG content.

**P2 incremental design policy**: after upload, call `StitchMCP:get_screen` to verify the visual update before posting the Pillar 1 Design Spec comment.

---

## 5. Managing Snapshot Diffs on UI Changes

### Intentional UI change workflow (P5 + P2)
1. Make UI changes on dedicated branch.
2. `./gradlew recordRoborazziDebug` — regenerate golden images.
3. Commit updated PNGs alongside source changes.
4. `./gradlew verifyRoborazziDebug` — must exit 0 before PR.
5. Include Roborazzi diff screenshot links in PR Walkthrough (P6).

### Unintentional diff detected in CI
```
> Task :app:verifyRoborazziDebug FAILED
Pixel difference detected: screenshots/01_home_dashboard_light.png
```
1. Inspect diff image in `build/outputs/roborazzi/`.
2. If change is intentional: run `recordRoborazziDebug` and commit updated goldens.
3. If change is a regression: fix the Composable, do NOT update the golden.

### Checklist — Before committing UI changes

- [ ] `./gradlew recordRoborazziDebug` run and updated PNGs committed.
- [ ] `./gradlew verifyRoborazziDebug` exits 0.
- [ ] All 5 states captured per screen (Default, Loading, Empty, Error — Light + Dark minimum).
- [ ] `python3 scripts/upload-screenshots.py` synced to Stitch (P2 confirms).
- [ ] PR Walkthrough includes snapshot diff links.
