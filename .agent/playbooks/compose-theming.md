---
id: compose-theming
consumers: [P2, P5]
version: 1.0.0
triggers: Any UI component change, new screen, token update in DESIGN.md or Color.kt
---

# Skill: Compose Theming & 4-State UI Matrix

> Extracted from `Theme.kt`, `Color.kt`, `Type.kt`, `design-system.md` (Material 3 token table), and project `AgenticAndroidStarterTheme` / `SereneCustomColors` implementations.

---

## 1. Theme Entry Point

```kotlin
// Always wrap the root content in AgenticAndroidStarterTheme (never AppTheme in new code)
AgenticAndroidStarterTheme(
    darkTheme = isSystemInDarkTheme(),
    dynamicColor = false   // DISABLED project-wide — Serene palette is locked
) {
    // content
}
```

**`dynamicColor = false`** is a project-wide invariant. Never enable dynamic color — it overrides the Serene Intellectual palette.

---

## 2. Token Resolution — Two-Layer System

### Layer 1: Material 3 Standard Roles (`MaterialTheme.colorScheme.*`)
Use for standard Material components (Button, Card, TopAppBar, etc.):
```kotlin
// ✅ Correct
color = MaterialTheme.colorScheme.primary          // #2D4A3E light / #8FB899 dark
backgroundColor = MaterialTheme.colorScheme.surface
textColor = MaterialTheme.colorScheme.onSurface
errorColor = MaterialTheme.colorScheme.error       // #BA1A1A light / #FFB4AB dark
```

### Layer 2: Serene Custom Semantic Tokens (`sereneColors.*`)
Use for Serene-specific surfaces and decorative elements not covered by Material 3:
```kotlin
val colors = sereneColors   // LocalSereneColors.current

colors.cardNestedBg         // nested card background
colors.pillBg               // stats pill, subtle card
colors.border               // card border hairline
colors.textPrimary          // deep slate-green text
colors.textSecondary        // muted subtitle text
colors.sage / colors.sageLight
colors.purple / colors.purpleLight
colors.amber / colors.amberLight
```

### Forbidden Patterns
```kotlin
// ❌ Never hardcode hex values in Composables
color = Color(0xFF2D4A3E)               // use MaterialTheme.colorScheme.primary
fontSize = 16.sp                        // use MaterialTheme.typography.bodyMedium
padding = 13.dp                         // use 8dp grid: 8.dp, 16.dp, 24.dp
shape = RoundedCornerShape(7.dp)        // use MaterialTheme.shapes.medium
```

---

## 3. Typography Scale

```kotlin
// All text uses MaterialTheme.typography.*
MaterialTheme.typography.displayLarge    // 57sp — hero section
MaterialTheme.typography.headlineLarge   // 32sp — screen title
MaterialTheme.typography.headlineMedium  // 28sp — section header
MaterialTheme.typography.titleMedium     // 16sp, SemiBold — card title
MaterialTheme.typography.bodyLarge       // 16sp — primary body
MaterialTheme.typography.bodyMedium      // 14sp — secondary body
MaterialTheme.typography.labelMedium     // 12sp — pills, chips, captions
```

---

## 4. The 4-State UI Matrix

Every data-driven screen MUST implement all 4 states via a sealed `UiState`:

```kotlin
sealed class YourUiState {
    object Loading : YourUiState()
    object Empty : YourUiState()
    data class Error(val message: String) : YourUiState()
    data class Content(val items: List<Item>) : YourUiState()
}
```

```kotlin
@Composable
fun YourScreen(uiState: YourUiState) {
    when (uiState) {
        is YourUiState.Loading -> LoadingState()
        is YourUiState.Empty   -> EmptyState()
        is YourUiState.Error   -> ErrorState(message = uiState.message)
        is YourUiState.Content -> ContentState(items = uiState.items)
    }
}
```

### Loading State — Shimmer Pattern
```kotlin
@Composable
fun LoadingState() {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        repeat(5) {
            ShimmerBox(modifier = Modifier.fillMaxWidth().height(72.dp).padding(bottom = 8.dp))
        }
    }
}

@Composable
fun ShimmerBox(modifier: Modifier = Modifier) {
    val shimmerColors = listOf(
        MaterialTheme.colorScheme.surfaceVariant,
        MaterialTheme.colorScheme.surface,
        MaterialTheme.colorScheme.surfaceVariant
    )
    val infiniteTransition = rememberInfiniteTransition()
    val translateX by infiniteTransition.animateFloat(
        initialValue = -300f, targetValue = 300f,
        animationSpec = infiniteRepeatable(tween(1000, easing = LinearEasing))
    )
    Box(modifier.background(Brush.linearGradient(shimmerColors), MaterialTheme.shapes.medium))
}
```

### Empty State Pattern
```kotlin
@Composable
fun EmptyState(onAction: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, ...) {
        Image(painter = painterResource(R.drawable.ic_empty_state), contentDescription = null)
        Text(stringResource(R.string.empty_state_title), style = MaterialTheme.typography.titleMedium)
        Text(stringResource(R.string.empty_state_subtitle), style = MaterialTheme.typography.bodyMedium)
        Button(onClick = onAction) {
            Text(stringResource(R.string.empty_state_cta))
        }
    }
}
```

### Error State Pattern
```kotlin
@Composable
fun ErrorState(message: String, onRetry: () -> Unit) {
    // Surface via Snackbar (preferred) or inline error card
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(Icons.Default.ErrorOutline, contentDescription = null,
             tint = MaterialTheme.colorScheme.error)
        Text(message, color = MaterialTheme.colorScheme.onErrorContainer)
        OutlinedButton(onClick = onRetry) {
            Text(stringResource(R.string.error_retry_cta))
        }
    }
}
```

---

## 5. Motion & Transition Specs

```kotlin
// Screen enter — standard
fadeIn(animationSpec = tween(300, easing = EaseOut)) +
slideInVertically(tween(300, easing = EaseOut)) { it / 8 }  // +24dp lift

// Item list appearance — staggered
LazyColumn {
    itemsIndexed(items) { index, item ->
        AnimatedVisibility(
            visible = true,
            enter = fadeIn(tween(200, delayMillis = index * 40))
        ) { ItemCard(item) }
    }
}

// FAB morph / size change
Modifier.animateContentSize(animationSpec = spring(stiffness = Spring.StiffnessMediumLow))

// Bottom sheet / dialog — Material 3 handles automatically via ModalBottomSheet / AlertDialog
```

---

## 6. Life Domain Accents & Semantic Domains

Use `MaterialTheme.sereneColors` for semantic life domain categorization:
* `Self`: `#C2B2D6` (Light) / `#F4EEF9` (Dark)
* `Home`: `#7E9F85` (Light) / `#E2EDE3` (Dark)
* `Work`: `#5E4B66` (Light) / `#EDE4F5` (Dark)
* `Delegate`: `#D97706` (Light) / `#FEF3C7` (Dark)
* `Zen Gold`: `#E9B96E` (Light) / `#FCD34D` (Dark)

---

## 7. Shapes, Card Elevations & Margins

* **Cards (`SoftCard`)**: `RoundedCornerShape(20.dp)` (or `24.dp` for Hero cards) with `1.dp` border `MaterialTheme.colorScheme.outlineVariant`. Zero raw drop shadows.
* **Modals & BottomSheets**: `RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)`.
* **Buttons, Pills, FAB**: `CircleShape` (`9999.dp`).
* **Margins & Gutters**: `20.dp` mobile horizontal margin, `16.dp` vertical gutter between cards.

---

## 8. Google Stitch MCP Integration & Invariants

When synchronizing screens or design systems with Google Stitch:
* **Primary Project ID**: `<stitch-project-id>` (*Agentic Android Kernel - Serene Intellectual*)
* **Design System Asset**: `<stitch-asset-path>`
* **Deterministic PNG Upload**: Visual synchronization operates exclusively via Roborazzi PNG uploads (`scripts/upload-screenshots.py`). Zero text-based UI generation in Stitch.
* **Build Isolation**: Network sync calls to Stitch are strictly forbidden during automated Gradle builds (`testDebugUnitTest`, `assembleDebug`).

---

## Checklist — Before Any UI Change

- [ ] All colors reference `MaterialTheme.colorScheme.*` or `sereneColors.*`.
- [ ] All typography uses `MaterialTheme.typography.*`.
- [ ] All spacing uses `8.dp` grid multiples.
- [ ] All shapes reference `MaterialTheme.shapes.*` or Serene card radii (`20.dp`).
- [ ] All 4 UiState branches implemented (Loading, Empty, Error, Content).
- [ ] Strings comply with `android-standards.md` (Zero hardcoded literals in Compose).
- [ ] Roborazzi snapshots updated for all changed Composables (see `roborazzi-export.md`).
