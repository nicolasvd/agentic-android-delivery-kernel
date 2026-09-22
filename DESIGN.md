---
name: Serene Intellectual v1.0.0
colors:
  surface: '#ffffff'
  surface-dim: '#eff3f0'
  surface-bright: '#ffffff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ffffff'
  surface-container: '#eff3f0'
  surface-container-high: '#eff3f0'
  surface-container-highest: '#e6ece6'
  on-surface: '#1c2b24'
  on-surface-variant: '#5c6f65'
  inverse-surface: '#1a2420'
  inverse-on-surface: '#e6ede8'
  outline: '#c8d3cb'
  outline-variant: '#e6ece6'
  surface-tint: '#2d4a3e'
  primary: '#2d4a3e'
  on-primary: '#ffffff'
  primary-container: '#e2ede3'
  on-primary-container: '#2d4a3e'
  inverse-primary: '#8fb899'
  secondary: '#5c6f65'
  on-secondary: '#ffffff'
  secondary-container: '#eff3f0'
  on-secondary-container: '#1c2b24'
  tertiary: '#5e4b66'
  on-tertiary: '#ffffff'
  tertiary-container: '#ede4f5'
  on-tertiary-container: '#5e4b66'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#410002'
  primary-fixed: '#e2ede3'
  primary-fixed-dim: '#c8d3cb'
  on-primary-fixed: '#1c2b24'
  on-primary-fixed-variant: '#2d4a3e'
  secondary-fixed: '#eff3f0'
  secondary-fixed-dim: '#c8d3cb'
  on-secondary-fixed: '#1c2b24'
  on-secondary-fixed-variant: '#5c6f65'
  tertiary-fixed: '#ede4f5'
  tertiary-fixed-dim: '#c7b5d8'
  on-tertiary-fixed: '#25152d'
  on-tertiary-fixed-variant: '#5e4b66'
  background: '#f8faf8'
  on-background: '#1c2b24'
  surface-variant: '#eff3f0'
typography:
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  title-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.15px
  title-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01px
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 1.2px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.875rem
  lg: 1rem
  xl: 1.25rem
  2xl: 1.5rem
  3xl: 1.75rem
  full: 9999px
spacing:
  base: 4px
  micro: 4px
  tight: 8px
  compact: 12px
  standard: 16px
  inset: 20px
  loose: 24px
  modal: 28px
  sheet: 32px
  cta: 48px
  fab: 56px
  nav-offset: 90px
---

## Brand & Style
The design system focuses on cognitive ease and intentionality, tailored for a "Agentic Android Delivery Kernel" experience where mental decompression and clarity are paramount. It utilizes a refined **Modern Corporate** style infused with **Minimalist** and **Organic Geometry** sensibilities, moving away from high-density data views toward spacious, calm information architecture.

The aesthetic is characterized by a "Serene Material" approach: taking the functional logic of Material 3 and softening it through a nature-inspired botanical palette, gentle tonal layering, and rounded touch targets. The emotional response is one of quiet confidence and mental order—reducing digital friction to facilitate deep work, personal wellness, and equitable couple collaboration across 3 distinct access states (**Guest**, **Solo Connected**, **Duo Synced**).

## Colors
The palette is rooted in botanical and mineral tones with full Light and Dark mode parity:

- **Primary Dark Green (`#2D4A3E` Light / `#8FB899` Dark):** Provides an authoritative anchor for navigation, primary action buttons (CTA), and selected focus states.
- **Primary Container (`#E2EDE3` Light / `#20362B` Dark):** Soft sage container used for top-voted daily focus tasks and active category highlights.
- **Secondary Slate (`#5C6F65` Light / `#A3B5AA` Dark):** Muted slate-green for subtitles and secondary content, paired with `#EFF3F0` containers for stats pills and inactive chips.
- **Tertiary Plum (`#5E4B66` Light / `#C7B5D8` Dark):** Functional accent for Work domain tasks, shared partner metrics, and couple energy balance.
- **Semantic Life Domain Accents:**
  - **Self:** Lavender accent (`#C2B2D6` / `#D0BCFF`) with container (`#F4EEF9` / `#2E2436`).
  - **Home / Household:** Sage accent (`#7E9F85` / `#8FB899`) with container (`#E2EDE3` / `#20362B`).
  - **Work:** Plum accent (`#5E4B66` / `#C7B5D8`) with container (`#EDE4F5` / `#36273D`).
  - **Delegate:** Warm amber accent (`#D97706` / `#F59E0B`) with container (`#FEF3C7` / `#3D2C1E`).
  - **Zen Gold:** Festive gold (`#E9B96E` / `#FCD34D`) for mindful streak and completion celebrations.
- **Background & Surfaces:** Global screen background uses soft calming off-white (`#F8FAF8` Light / `#141C18` Dark), while cards (`SoftCard`) use pure white (`#FFFFFF` Light / `#1A2420` Dark).
- **Accessibility:** Strictly compliant with WCAG 2.1 AA/AAA standards (contrast ratio ≥ 14.2:1 for primary text in Light mode).

## Typography
The design system utilizes **Manrope** for its balanced, modern geometric qualities that remain highly legible across both compact mobile lists and long-form note views.

- **Headlines:** `headline-lg` (32px Bold / -0.02em letter spacing) for hero greeting screens; `headline-md` (24px SemiBold) for view titles (`Trends`, `Settings`).
- **Titles:** `title-md` (16px SemiBold / 0.15px tracking) for task list cards; `title-sm` (14px Bold) for 2x2 statistics tiles and Eisenhower matrix quadrants.
- **Body Text:** `body-lg` (18px Regular / 28px line height) and `body-md` (16px Regular / 24px line height) with generous line heights to promote reading endurance and cognitive breathability.
- **Labels:** `label-sm` (11px Bold / 1.2px letter spacing uppercase) for section overlines and category badges.

## Layout & Spacing
The layout follows a fluid 4-column grid for mobile, emphasizing vertical flow and generous whitespace.

- **Margins:** Standard mobile side margins are set to **20px** (`padding(horizontal = 20.dp)`), expanding to **24px** for forms.
- **Rhythm:** Built on a 8px/4px baseline grid. Content cards are separated by a **16px** vertical gutter.
- **Grid Layouts:** Fluid vertical list for daily focus, alongside a fixed 2x2 grid for stats tiles and the 4 Eisenhower Clarity Matrix quadrants (*Do Today*, *Schedule*, *Delegate*, *Park*).
- **Touch Targets & Clearances:** CTA buttons feature **48px** height, Floating Action Button (FAB) uses **56px**, and views include a **90px** bottom padding clearance for the floating navigation bar.

## Elevation & Depth
Elevation is communicated through **Tonal Layering** and subtle hairline borders rather than heavy drop shadows.

- **Level 0 (Background):** Base canvas layer (`#F8FAF8` Light / `#141C18` Dark).
- **Level 1 (Cards):** Standard content containers (`#FFFFFF` Light / `#1A2420` Dark) with a 1px border (`#E6ECE6` Light / `#2A3832` Dark).
- **Level 2 (Active/Floating):** Elevated cards apply minimal diffused ambient shadows (`0.03`–`0.04` alpha).
- **Interaction:** On press, cards subtly apply a primary/sage container tint or shrink slightly (98%) to signify tactile feedback.

## Shapes
The shape language is defined by organic roundedness to evoke softness and accessibility.

- **Standard Cards (`SoftCard`):** **20px** corner radius for standard cards and matrix quadrant containers; **24dp** for Hero greeting cards.
- **Modals & BottomSheets:** **28px** top corner radius (`RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)`) for bottom sheets (`EditMentalLoadSheet`, `CoupleViewSheet`) and primary dialogs (`BreathingExerciseDialog`, `PartnerLinkDialog`, `AuthRequiredDialog`).
- **Interactive Elements & Pills:** Full pill-shape (**9999px / CircleShape**) for CTA buttons, quick capture floating bar, category badges, voting action buttons, and filter chips.
- **Inputs & List Items:** **14px** to **16px** corner radius.

## Components
- **Buttons:** Primary buttons use `primary` (`#2D4A3E`) background with `onPrimary` (`#FFFFFF`) text. Secondary buttons use `secondaryContainer` (`#EFF3F0`) or ghost style with a 1px border.
- **Cards (`SoftCard`):** Main content containers feature a 20px/24px radius, `#FFFFFF` background, `#E6ECE6` border, and 20px internal padding.
- **Category Badges (`CategoryBadge`):** Pill-shaped chips (`CircleShape`) with semantic domain colors (Self-first order: Self, Home, Work, Delegate).
- **Floating Quick Thought Bar:** Anchored pill-shaped input bar (`32px` radius) floating above the bottom navigation for instant capture.
- **Input Fields:** Styled with a 16px corner radius and `#EFF3F0` background for a clean distinction between input and viewing states.
- **Bottom Sheets & Soft-Gating Dialogs:** 28px top-rounded sheets with centered drag handles, fully integrated with the 3 access state rules.
