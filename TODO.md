# KanjiJourney TODO

## Active Tasks
- [ ] [P0] S2-KJ-1: Leaderboards + achievements (J Coin integration) — target v1.3.0
  - [ ] Design: leaderboard architecture (Supabase Edge Function + local UI)
  - [ ] Design: wire 5 achievements to earn triggers in CompleteSessionUseCase
  - [ ] Implement: leaderboard Supabase Edge Function (top 10 by J Coin balance)
  - [ ] Implement: LeaderboardScreen (Glass UI, top 10 list)
  - [ ] Implement: achievement trigger logic in CompleteSessionUseCase
  - [ ] Build verification + commit as v1.3.0

## Backlog
- Release APK size measurement — estimated ~40-45MB, blocked on keystore password (BUG-001)
- Supabase pull sync for word transfer (cloud complement to deep link)
- Supabase DB migration (CHECK constraints for new app names)
- Repo directory rename (KanjiQuest → KanjiJourney on GitHub, blocked: Jay)
- IDEA-004: Full 常用漢字 coverage (2,136 kanji)
- IDEA-001 iOS port: cross guide lines on iOS writing canvas
- iPhone calligraphy mode (finger drawing, no Apple Pencil, IDEA-005 / BUG-003)
- Camera Challenge: AVFoundation + Vision OCR camera preview (BUG-002, iOS)
- Apply Glass UI to remaining iOS screens (jworks:47 scope)
- KanjiSage deep link integration (iPad)
- Polish from beta student feedback (4 students testing)

## Completed
- [x] Accessibility: 14 back buttons Text("←")→Icon(ArrowBack) + contentDescription (v1.2.6, 2026-04-15)
- [x] APK size reduction: 123MB→67MB debug — db.bak, PNG→WebP, ABI filter, shrinkResources (v1.2.5, 2026-04-15)
- [x] IDEA-003: Add Kanken level as secondary taxonomy axis (v1.2.4, 2026-04-13)
- [x] Remaining 21 hardcoded hex colors → design tokens (v1.2.3, 2026-04-13)
- [x] Contrast audit — 6 violations fixed across ShopScreen, RecognitionScreen, WritingScreen (v1.2.2, 2026-04-14)
- [x] S1-KJ-1: Sage → Journey word transfer — deep link E2E (v1.2.0, 2026-04-14)
- [x] IDEA-002: Dakuten/handakuten variant-aware kana distractors (v1.2.1, 2026-04-14)
- [x] IDEA-001: Cross guide lines (十字) on Android writing canvas — v1.1.3 (2026-04-13)
- [x] L1 review fixes: min 12sp fonts (20+ instances), low-contrast text (3 files), min 8dp corners (15 instances) (2026-04-10)
- [x] WAVE 1 L1: Focus indicators on ALL interactive elements — 25+ screens, FocusIndicator.kt (2026-04-10)
- [x] WAVE 1 L1: isError + supportingText on all TextFields — LoginScreen, FlashcardScreen dialogs (2026-04-10)
- [x] WAVE 1 L1: Shape.kt — centralized corner radii tokens (2026-04-10)
- [x] WAVE 1 L1: Spacing.kt — centralized spacing tokens (2026-04-10)
- [x] WAVE 1 L1: Hardcoded color migration — 88% reduction (174→21), GameColors/StateColors/MasteryColors (2026-04-10)
- [x] Glass UI theme ported to iOS — GlassTheme.swift + KanjiJourneyTheme palette updated (2026-03-30)
- [x] STATUS.md corrected — iOS was 95% feature-complete, not 20% (2026-03-30)
- [x] DM Sans fonts added to iOS project (2026-03-30)
- [x] docs/gemini-development-log.md — 7 Gemini feature candidates (2026-03-17)
- [x] ACK'd Dual Agent Architecture directive from jworks:42 (2026-03-17)
- [x] Rename KanjiQuest → KanjiJourney (codebase, 415 files, 12 dirs) (2026-03-01)
- [x] iPad calligraphy mode with Gemini AI feedback (2026-03-01)
- [x] iPhone build target added (build 11) (2026-03-01)

## Archived
(None yet)
