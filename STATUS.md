# KanjiJourney Development Tracker

> **Updated by**: jworks:44 (Android) + jworks:47 (iOS)
> **Last updated**: 2026-03-30

---

## Current Status

- **Version**: v1.0.0 (Android: v1.0.0, iPad: build 25, iPhone: build 11)
- **Platforms**: Android (Kotlin) + iOS/iPad (SwiftUI via KMP + SKIE)
- **Build**: Passing (all 3 targets: Android, iPad, iPhone)
- **Branch**: main
- **Stage**: Beta testing (4 students)
- **Rename**: KanjiQuest → KanjiJourney complete (codebase + infrastructure)

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
- **Current work**: Beta monitoring, bug fixes from student feedback
- **Next**: Polish based on beta feedback
- **Blockers**: Supabase storage decision (APK 66MB > free tier 50MB)

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
