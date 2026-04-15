# KanjiJourney TODO

## Active Tasks
- [x] Contrast audit — 6 violations fixed across ShopScreen, RecognitionScreen, WritingScreen (v1.2.2, 2026-04-14)
- [x] IDEA-003: Add Kanken level as secondary taxonomy axis (v1.2.4, 2026-04-13)
- [x] Remaining 21 hardcoded hex colors → design tokens (v1.2.3, 2026-04-13)

## Backlog
- IDEA-001 iOS port: cross guide lines on iOS writing canvas
- APK size reduction (66MB → under 50MB for Supabase free tier, BUG-001)
- Polish from beta student feedback (4 students testing)
- iPhone calligraphy mode (finger drawing, no Apple Pencil, IDEA-005 / BUG-003)
- Camera Challenge: AVFoundation + Vision OCR camera preview (BUG-002, iOS)
- Supabase DB migration (CHECK constraints for new app names)
- Repo directory rename (KanjiQuest → KanjiJourney on GitHub, blocked: Jay)
- KanjiSage deep link integration (iPad)
- Apply Glass UI to remaining iOS screens (jworks:47 scope)
- IDEA-004: Full 常用漢字 coverage (2,136 kanji)
- Supabase pull sync for word transfer (cloud complement to deep link)

## Completed
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
