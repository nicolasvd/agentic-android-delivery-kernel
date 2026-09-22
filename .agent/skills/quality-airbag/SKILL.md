---
name: quality-airbag
description: Native Antigravity validation skill activated when asked to inspect code, run tests, verify lint, or validate documentation. Orchestrates Gradle codeSanityCheck, Firestore security rules tests, and documentation contract validation.
triggers:
  - "quality check"
  - "run tests"
  - "verify lint"
  - "code check"
  - "quality airbag"
  - "inspect code"
  - "/quality-check"
owner: Persona 6 (Release Manager)
consumers: [P5, P6]
version: 2.0.0
---

# Skill: `quality-airbag` (Delivery Consortium)

Standardizes continuous validation and quality control across **Agentic Android Kernel**. Acts as the pre-commit, pre-push, and pre-PR quality airbag.

> **Governance References**:
> - [`.agent/rules/agent-lifecycle.md`](../../rules/agent-lifecycle.md) — *Phase 2: Quality Airbag*
> - [`.agent/rules/git-workflow.md`](../../rules/git-workflow.md) — *Section 2 (Core Principles)*
> - Hook: [`.agent/hooks/pre-commit-airbag.sh`](../../hooks/pre-commit-airbag.sh)

---

## 🎯 Sequential Execution Recipe

### Step 1: Java Environment Configuration
Verify compatible Java runtime (JDK 17 or JDK 21):
```bash
if [ -z "${JAVA_HOME:-}" ] && [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
fi
```

### Step 2: Documentation & Governance Validation
Verify contractual integrity across rules, personas, templates, playbooks, and skills:
```bash
./scripts/validate-docs.sh
```

### Step 3: Android Code Inspection & Tests (Gradle)
Run the compiled inspection suite:
```bash
./scripts/quality-check.sh
# or directly via Gradle
./gradlew codeSanityCheck --stacktrace
```
Orchestrates:
1. **Kotlin/Java Compilation**: Strict typing, progressive checks, `@OptIn` flags.
2. **Android Lint (Debug & Release)**: Compose, security, accessibility, and i18n checks.
3. **Unit & Robolectric Tests**: 100% of unit and UI Robolectric tests.
4. **Jetifier & AndroidX Compatibility**.

### Step 4: Firestore Security Rules Validation
Validate least-privilege security and 3-State isolation:
```bash
node scripts/test-firestore-rules.mjs
```

### Step 5: Acceptance Criteria Verification
All indicators must be green:
- ✅ **0 compilation errors** (Kotlin / Java).
- ✅ **0 blocking errors / warnings** (Android Lint).
- ✅ **100% unit & Robolectric tests passing**.
- ✅ **100% Firestore security assertions valid**.
- ✅ **100% documentation contracts passed**.

### Step 6: Diagnostic Reports (On Failure)
- 📄 **Lint Debug**: `app/build/reports/lint-results-debug.html`
- 📄 **Lint Release**: `app/build/reports/lint-results-release.html`
- 📄 **Unit Tests**: `app/build/reports/tests/testDebugUnitTest/index.html`
- 📄 **Roborazzi Diffs**: `app/build/outputs/roborazzi/`
