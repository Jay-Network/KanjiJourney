# KanjiJourney Changelog

All notable changes to KanjiJourney are documented here.
Follows versioning standard: vMAJOR.MINOR.PATCH (v0=Alpha, v1=Beta, v2=Store)

---

## [Unreleased]

---

## v1.0.0 (2026-03-01)

### Changed
- **Renamed KanjiQuest → KanjiJourney** across entire codebase (415 files, 12 directories)
  - Package: `com.jworks.kanjiquest` → `com.jworks.kanjijourney`
  - DB file: `kanjiquest.db` → `kanjijourney.db`
  - J Coin business ID: `kanjiquests` → `kanjijourney`
  - Deep link scheme: `kanjijourney://`
  - All class names, string resources, ProGuard rules, CI/CD workflows
  - iOS: directories, files, xcconfig, bundle IDs, error domains, workflow files
- **Applied versioning standard** (vMAJOR.MINOR.PATCH)
- **Glass UI Phase 2** (Android): Frosted glass top bar and bottom nav with orange brand glow
- **StudyScreen** (Android): Full glass aesthetic conversion (glass chips, gradient mode cards, brand colors)
- Version bump from 0.1.0-beta13 → v1.0.0 (Beta stage)

### Added (iOS — iPad builds 23-25, iPhone builds 9-11)
- **Standalone Calligraphy Mode** (iPad build 23): 8 hardcoded kanji (一二三十大山川日), CalligraphyCanvasView (UIKit), Apple Pencil support, Gemini AI stroke feedback, ghost stroke overlay
- **Mock Home Screen**: Writing card tappable with green "READY" badge, other modes dimmed at 0.6 opacity
- **iOS Rename**: KanjiQuest → KanjiJourney (directories, files, configs, bundle IDs, CI workflows)

### Fixed (iOS)
- **Auto-submit removed** (iPad build 24): Drawing no longer auto-submits after matching stroke count — user presses Submit when ready
- **Undo button fixed** (iPad build 25): Added undoVersion binding to CalligraphyCanvasView, calls UIView.undo() to properly remove last stroke from canvas

---

## v0.5.0 (2026-02-21)

### Added (Android)
- **Collection Gameplay System**: "Gotta Catch 'Em All" mechanic — kanji, kana, and radicals are discovered through gameplay with probability-based encounters and a pity system
- **Rarity System**: 5 tiers (Common/Uncommon/Rare/Epic/Legendary) based on grade, frequency, and stroke count; color-coded borders on collected items
- **Encounter Engine**: Per-answer encounter rolls (40%→2% by rarity), pity counters guarantee discoveries after N correct answers
- **Item Level Engine**: Collected items earn XP per practice (+10 correct, +2 wrong); max level 10 with quadratic scaling
- **Discovery Overlay**: Pokémon-catch-style animation when a new item is discovered during gameplay (all game modes)
- **Collection Screen**: Full browser with tabs per type, rarity filters, stats, and grid with rarity borders + level badges
- **JWorks Splash Screen**: Branded splash matching KanjiLens (black bg, logo shimmer, teal title, fade out)
- **KanjiLens Deep Link Integration**: `kanjijourney://collect?kanji_id=XXX&source=kanjilens` adds kanji to collection from KanjiLens
- **Starter Pack**: New players receive 5 hiragana + 5 katakana + 3 Grade 1 kanji on first launch
- **Radical Detail Screen**: View radical info, related kanji, and practice buttons
- **Field Journal**: Camera challenge scan history with photo entries
- **Flashcard Deck Groups**: Organize flashcard decks into folders
- **Kana Game Modes**: Hiragana/Katakana recognition and writing practice screens
- **Radical Game Modes**: Radical recognition quiz and radical builder (compose kanji from radicals)

### Changed
- **Home Screen Panel Tabs**: 3-layer tab system — Layer 1: Hiragana/Katakana/部首/Kanji; Layer 2 (Kanji): School Grade/JLPT/Strokes/Frequency; Layer 3: level selectors (G1-G8+, N1-N5, etc.)
- **Home Screen Selection Persistence**: Tab, sort mode, and grade/level selections now persist when navigating back from detail pages
- **All Grades Visible**: School Grade shows G1-G8+ with grayed-out tabs for grades with no collected kanji
- **Hidden Uncollected Kanji**: Uncollected items are blank placeholders (no character, not clickable) maintaining sort order (虫食い pattern)
- **Home Grid**: Shows collection-aware items with rarity borders and level badges for kanji, kana, and radicals
- **Collection Counter**: Shows "N/Total Kanji Collected" on home screen
- **Game Engine**: Integrated encounter rolls and item XP on correct/wrong answers
- **Question Generator**: Collection-aware — mixes collected items for review with uncollected for exploration encounters
- **Navigation**: Added routes for Splash, Collection, Radical Detail, Field Journal, Kana Recognition/Writing, Radical Recognition/Builder
- **Database**: New `collection` and `field_journal` tables with migration for existing SRS data → collection
- **Data Pipeline**: Enhanced radical parser with image generation

### Added (iOS — iPad builds 13-22, iPhone builds 1-8)
- **Complete iOS Rebuild** (build 13-16): Full Android-to-SwiftUI port (Phases 1-6), 12 rounds of KMP bridging fixes (KotlinLong, KotlinInt, KotlinBoolean conversions)
- **Bottom Navigation Tabs** (build 18): Home, Games, Study, Collection tabs ported from Android
- **Mock Home Screen** (build 19-20): Pure mock UI — zero KMP on launch, crash-safe deferred init
- **ObjC Exception Catcher**: Wraps all KMP calls to prevent Kotlin exceptions from crashing Swift
- **Crash-safe KMP Init**: discoveredItems sync, sync_version table, deferred loading
- **Brush Test App**: Standalone calligraphy canvas prototype (builds 10-12, bristle texture + ink physics)
- **iPhone Target** (build 1-8): Separate project.yml, CI workflow, DB bundling, icon sizes
- **Bridging Header**: Proper ObjC↔Swift bridge for exception handling

### Fixed (iOS)
- KMP bridging: 12 rounds of type conversion fixes (KotlinLong, KotlinInt, KotlinBoolean, IntRange)
- iPhone launch crash (deferred initialization, crash breadcrumb system)
- DB bundling (version-based copy, pre-built DB with user_version=1)
- Linker errors (xcframework search paths, libsqlite3, swiftXPC)
- onChange iOS 17 syntax compatibility

### Fixed
- Smart cast errors across modules for `discoveredItem` in game result screens

---

## v0.4.0 (2026-02-13)

### Added
- **Placement Test**: First-time user assessment across Grade 1-6 kanji (5 questions per grade) with automatic level assignment
- **Flashcard & SRS System**: Spaced repetition flashcard decks with self-rating (Again/Hard/Good/Easy), interval scheduling, and SQLDelight persistence
- **Feedback System**: In-app feedback dialog with category chips (Bug, Feature Request, UI/UX, Performance, Content, Other), character counter, rate limiting (5/day), feedback history with status tracking, and 15s polling for updates
- **Feedback FAB**: Floating action button on all screens (except Login) for quick feedback submission
- **FCM Push Notifications**: Firebase Cloud Messaging service for feedback status updates (pending Firebase registration)
- **Developer Chat**: In-app chat for registered developers, routed through Supabase Edge Functions to Discord via n8n
- **AI Feedback Reporter**: Dedicated reporter for writing mode AI feedback results
- **KanjiText Theme Component**: Reusable Compose component for consistent kanji text rendering
- **Notification Icon**: Vector drawable for push notification display
- **KanjiModeStats SQLDelight**: Per-mode statistics tracking in local database

### Changed
- **Home Screen**: Major UI overhaul — game mode cards, tier card with XP progress, J Coin balance, Word of the Day, premium upgrade banner, free user trial indicators
- **Writing Mode**: Enhanced drawing canvas with improved touch handling, upgraded stroke renderer with better visual feedback, expanded handwriting checker with AI integration, session management improvements
- **Kanji Detail Screen**: Added practice launch buttons (Recognition, Writing, Camera), example words section, enhanced layout (+152 lines)
- **Navigation**: Added routes for Placement Test, Flashcards, Flashcard Study, Dev Chat, Kanji Detail, Word Detail; updated nav host with full route handling
- **Settings Screen**: Added Developer section (visible only for registered devs), enhanced admin controls
- **Recognition Mode**: Refined screen layout and view model session handling
- **Camera Challenge**: Enhanced view model with improved scan result processing
- **Vocabulary Mode**: Refined screen and view model
- **AppModule (DI)**: Registered DevChatRepository, FeedbackRepository, FlashcardRepository, and associated ViewModels
- **AndroidManifest**: Added FCM service, notification permissions, internet permission declarations
- **build.gradle.kts**: Added Firebase Messaging dependency
- **Game Engine**: Improved session flow and state transitions
- **Question Generator**: Enhanced question selection with adaptive difficulty support
- **GameState**: Updated state model for new game modes
- **CompleteSessionUseCase**: Enhanced with J Coin earning integration, XP accuracy bonuses, and earning cap awareness
- **WordOfTheDayUseCase**: Improved word selection logic
- **SrsRepository**: Added mode-specific stats tracking methods
- **DatabaseDriverFactory**: Added Android-specific schema migration support

### Fixed
- **getUserEmail() always returning null**: `UserSessionProvider` now correctly collects from auth state flow via `firstOrNull()` instead of creating a flow and never collecting
- **Feedback history race condition**: `FeedbackViewModel.openDialog()` now resolves email before loading history (sequential in same coroutine)
- **"Note: null" in feedback history**: `FeedbackRepositoryImpl` now handles `JsonNull` properly with `contentOrNull`

---

## v0.3.0 (2026-02-08)

### Added
- Adaptive difficulty system with grade mastery badges (Beginning/Developing/Proficient/Advanced)
- Adaptive grade mixing based on mastery level
- XP accuracy bonus (+25% for 90%+ with 10+ cards, +15% for 85%+ with 5+ cards)
- Full project structure reorganization

### Fixed
- XP display overflow (level-1 to level format)
- Tier card effective level with admin override

---

## v0.2.0 (2026-02-07)

### Added
- J Coin Shop with TutoringJay Featured Banner
- Settings screen moved to top banner navigation
- Word of the Day randomization on launch

### Fixed
- Home screen bleed-through in game mode screens

---

## v0.1.0 (2026-02-06)

### Added
- Ollama AI handwriting feedback in Writing Mode
- Vocabulary Mode (Game Mode 2) with 4 question types
- SRS-aware difficulty scaling in Writing Mode
- Word of the Day feature

---

## v0.0.1 (2026-02-05)

### Added (Android)
- Recognition Mode (Game Mode 1) — core kanji quiz gameplay
- Writing Mode (Game Mode 1b) — stroke-based kanji writing practice
- Camera Challenge Mode — ML Kit OCR kanji detection
- TutoringJay authentication (dual Supabase)
- User progression system (levels, XP, streaks)
- Achievement system
- Progress & Stats tracking
- Stripe subscription integration ($4.99/mo premium)
- Free user preview mode (daily trial limits)
- Admin detection for Jay's emails

### Added (iOS)
- iPad project foundation (SwiftUI + KMP bridge)
- GitHub Actions CI/CD for iOS builds (iPad + iPhone workflows)
- XCFramework builder for KMP modules
