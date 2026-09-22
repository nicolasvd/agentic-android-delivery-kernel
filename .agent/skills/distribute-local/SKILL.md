---
name: distribute-local
description: Native Antigravity distribution skill to build and deploy development or release APKs to Firebase App Distribution with automated release notes and tester group dispatch.
triggers:
  - "distribute local"
  - "deploy app distribution"
  - "distribute firebase"
  - "deploy build"
  - "/distribute-local"
owner: Persona 6 (Release Manager)
consumers: [P6]
version: 2.0.0
---

# Skill: `distribute-local` (Delivery Consortium — Persona 6)

Standardizes local builds and deployment to **Firebase App Distribution** without manual APK manipulation or web console uploads.

> **Governance References**:
> - [`.agent/rules/agent-lifecycle.md`](../../rules/agent-lifecycle.md) — *Phase 3: Delivery & Release*
> - [`scripts/deploy-app-distribution.sh`](../../../scripts/deploy-app-distribution.sh) — *Deployment Script*

---

## 🎯 Sequential Execution Recipe

### Step 1: Pre-Build Quality Airbag
Run local checks before building the binary:
```bash
./scripts/quality-check.sh
```

### Step 2: Environment & Credential Check
Ensure Firebase CLI and credentials are available:
```bash
npx -y firebase-tools@latest --version
```
Verify `FIREBASE_APP_ID` (or `google-services.json`) and `GOOGLE_APPLICATION_CREDENTIALS`.

### Step 3: Build & Deploy via Distribution Script
Execute the deployment script:
```bash
./scripts/deploy-app-distribution.sh --build-type release --groups "internal-testers"
```
Or for debug builds:
```bash
./scripts/deploy-app-distribution.sh --build-type debug --groups "internal-testers"
```

### Step 4: Verification & Release Notification
Confirm upload success in terminal output:
- Firebase Console Release URL.
- Notification sent to target tester groups.
- Release notes containing commit SHA and changelog summary.
