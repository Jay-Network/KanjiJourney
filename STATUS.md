# KanjiJourney Development Tracker

> **Updated by**: jworks:44 (Android) — this pass covers Android only; iOS section below not independently re-verified, owner jworks:47
> **Last updated**: 2026-07-30

---

## Current Status

- **Version**: v1.3.0 (Android versionCode 15 / versionName 1.3.0, per VERSION file + build.gradle.kts, verified). iPad build 25 / iPhone build 11 figures below are UNVERIFIED this pass — carried over from 2026-03-30, ask jworks:47 for current numbers.
- **Platforms**: Android (Kotlin) + iOS/iPad (SwiftUI via KMP + SKIE)
- **CI Build**: android-build.yml — verified green as of 2026-07-23 (all 3 jobs: debug, unit tests, release AAB w/ keystore)
- **Branch**: main
- **Stage**: Beta, sideload-only (Play Console not registered). Tester count: **UNVERIFIED — do not treat any number as fact until confirmed by the TutoringJay-portal owner.** The prior "4 students" figure is dated 2026-03-30 and became load-bearing on a 2026-07-27 J-Coin hostname cutover before anyone could confirm it; flagged to Jay, tracked as jworks:44 task #19.
- **Rename**: KanjiQuest → KanjiJourney complete (codebase + infrastructure)

### ⚠️ Live incident — J-Coin/Auth backend cutover (2026-07-27 → in progress)
Two production breaks found + fixed this pass (Android `local.properties`, not yet rebuilt/shipped as of this doc update):
1. **J-Coin backend URL** — was pointing at the abolished `jcoin.jworks-ai.com` (unhyphenated hostname is a closed/retired topic per Jay directive). Repointed to `j-coin.jworks-ai.com`, anon key refreshed to the 2026-07-27 rotated value. Both independently verified live (Kong 200 w/ new key, edge functions reachable, unexposed tables correctly 404).
2. **Auth backend URL** — was pointing at a decommissioned cloud Supabase project (`sitmlszxevzczfydemok.supabase.co`, NXDOMAIN) for login + the premium subscription gate. Repointed to the self-hosted TutoringJay portal Kong (`https://jayboard.tutoringjay.com/supabase`), verified live (401 = Kong alive, auth required — correct unauthenticated response). Existing `AUTH_SUPABASE_ANON_KEY` still valid against the new URL (verified, no rotation needed).
- Full detail: jworks:44 task #18. Next: rebuild, verify the compiled APK reaches the live surface, then redistribute to confirmed testers.

---

## Feature Parity Matrix

| Feature | Android | iPad | iPhone |
|---------|:-------:|:----:|:------:|
| **Core Gameplay** | | | |
| Recognition Mode (kanji quiz) | DONE | DONE | DONE |
| Writing/Calligraphy + AI (Gemini) | DONE | DONE | - |
| Vocabulary Mode (4 question types) | DONE | DONE | DONE |
| Camera Challenge (OCR scanning) | DONE | 90% | 90% |
| Kana Recognition & Writing | DONE | DONE | DONE |
| Radical Recognition & Builder | DONE | DONE | DONE |
| Placement Test | DONE | DONE | DONE |
| **Collection System** | | | |
| Catch mechanic (probability + pity) | DONE | DONE | DONE |
| 5-tier rarity system | DONE | DONE | DONE |
| Item level engine (1-10, XP) | DONE | DONE | DONE |
| Discovery overlay animation | DONE | DONE | DONE |
| Collection screen (grid, filters) | DONE | DONE | DONE |
| **Progression** | | | |
| Flashcard SRS (Again/Hard/Good/Easy) | DONE | DONE | DONE |
| Spaced repetition scheduling | DONE | DONE | DONE |
| XP + J Coin system | DONE | DONE | DONE |
| Level progression (N²×50 XP) | DONE | DONE | DONE |
| **Features** | | | |
| Home screen (mode cards, tier, coins) | DONE | DONE | DONE |
| Field Journal (camera history) | DONE | DONE | DONE |
| Adaptive difficulty + mastery badges | DONE | DONE | DONE |
| Feedback system | DONE | DONE | DONE |
| Developer chat (Discord via n8n) | DONE | DONE | DONE |
| KanjiSage deep link integration | DONE | - | N/A |
| **Premium** | | | |
| Stripe subscription ($4.99/mo) | DONE | DONE | DONE |
| J Coin shop (boosters) | DONE | DONE | DONE |
| Admin level switcher | DONE | DONE | DONE |
| **Navigation** | | | |
| Bottom navigation tabs | DONE | DONE | DONE |
| Study screen | DONE | DONE | DONE |
| Games screen | DONE | DONE | DONE |
| Test Mode screen | DONE | DONE | DONE |
| **Platform-Specific** | | | |
| Apple Pencil calligraphy | N/A | DONE | N/A |
| Glass UI aesthetic | DONE | DONE | DONE |

**Legend**: DONE | 90% (mostly done, minor gap) | - (not started) | N/A

**Notes**:
- Camera Challenge: AVFoundation+Vision OCR camera preview is a placeholder; game logic is complete
- Glass UI: Ported from Android GlassTheme.kt to iOS GlassTheme.swift (2026-03-30)
- iPhone calligraphy: Finger drawing mode not yet ported (Apple Pencil only on iPad)

---

## Current Sprint

### Android
- **Current work**: J-Coin/Auth backend cutover (see live-incident note above) — local.properties fixed, rebuild + live verification in progress
- **Recent** (v1.2.4→v1.3.0, verified via CHANGELOG.md): Kanken dual-taxonomy axis, WCAG contrast fixes + design-token/L1 compliance, accessibility icon fixes, APK size 123MB→67MB debug (BUG-001, canonical BUGS.md still shows this as blocked/open — stale, see task #14), force-upgrade version-gate against `app_config`
- **Next**: Confirm real tester count (task #19), then redistribute rebuilt APK; pick up Phase 4 items (task #20) once auth integration lands
- **Blockers**: None on Android build itself — CI green; Supabase Storage bucket for APK hosting is now tracked under Phase 4 (jworks:35 coordination, jayhub:110 provisioning), superseding the old "66MB > 50MB free tier" framing

### iOS (iPad — build 25)
- **Current work**: Calligraphy mode live + working, rename complete
- **Recent**: Standalone calligraphy (Gemini AI feedback), auto-submit fix, undo fix
- **Next**: Glass UI port, vocabulary mode, more game modes
- **Blockers**: None currently (KMP bridging mostly resolved)

### iOS (iPhone — build 11)
- **Current work**: Same codebase as iPad minus calligraphy (excluded via project.yml)
- **Next**: Port calligraphy mode for iPhone (without Apple Pencil — finger drawing)
- **Blockers**: None

---

## Tech Stack

| Component | Android | iOS/iPad |
|-----------|---------|----------|
| Language | Kotlin | Swift + KMP bridge |
| UI | Jetpack Compose | SwiftUI + UIKit (canvas) |
| Shared code | KMP (shared-core, shared-japanese, shared-tokenizer) | Same via SKIE 0.10.10 |
| Database | SQLDelight | SQLDelight (via KMP) |
| Auth | Dual Supabase (TutoringJay + KanjiJourney) | Same |
| AI | Gemini 2.5 Flash | Same |
| Payment | Stripe | Stripe (planned) |
| DI | Hilt | Manual |

---

## Economy

| Parameter | Value |
|-----------|-------|
| XP per recognition | 15 base |
| XP per writing | 20 base (quality tiered) |
| Combo multiplier | 1.0x-2.0x (streaks 0-10+) |
| J Coins per session | 10 |
| Daily coin cap | 50 |
| Monthly bonus | 100 |
| Premium price | $4.99/mo |
