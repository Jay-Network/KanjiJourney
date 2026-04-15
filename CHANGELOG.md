# KanjiJourney Changelog

All notable changes to KanjiJourney are documented here.
Follows versioning standard: vMAJOR.MINOR.PATCH (v0=Alpha, v1=Beta, v2=Store)

---

## v1.2.4 (2026-04-13) — Kanken Level Taxonomy (IDEA-003)

### Added
- **漢検 (Kanken) level as secondary taxonomy axis** alongside school grade, JLPT, strokes, and frequency
- Kanken level derived from school grade: Grade 1→10級, Grade 2→9級, ..., Grade 6→5級, Grade 8→4級
- `kankenLevel` and `kankenLabel` computed properties on `Kanji` domain model
- `getKanjiByKankenLevel()` and `getKanjiCountByKankenLevel()` on `KanjiRepository`
- `KANKEN_LEVEL` sort mode in `KanjiSortMode` enum (appears between School Grade and JLPT)
- `selectKankenLevel()` in `HomeViewModel` with preserved selection across refresh
- Kanken level selector chips (10級–4級) in `CollectionHubScreen`
- Kanken level chip on `KanjiDetailScreen` info row

---

## v1.2.3 (2026-04-13) — Design Token Migration Complete

### Changed
- Migrated remaining 19 hardcoded `Color(0x...)` values to semantic design tokens (21→2 remaining, both file-local named constants in SplashScreen)
- RecognitionScreen: 3 teal hex colors → DiscoveryColors.Badge, DiscoveryColors.CardBackground, DiscoveryColors.Text
- WritingScreen: 4 hex colors → DebugColors.CardBackground, DebugColors.Text, ShopColors.Accent (2x admin button tints)
- DrawingCanvas: active stroke blue → GameColors.Recognition
- HomeScreen: admin badge red → DebugColors.AdminBadge
- GamesScreen: Speed Challenge accent → GameColors.Speed (new token)
- LoginScreen: membership pitch card blue → StateColors.Info
- VocabularyScreen: 2 discovery teal hex → DiscoveryColors.CardBackground
- Added GameColors.Speed token (0xFFFF5722, deep orange) to Theme.kt

---

## v1.2.2 (2026-04-14) — WCAG Contrast Audit Fixes

### Fixed
- ShopScreen: TutoringJay banner text raised from 0.8f/0.9f alpha to full white on orange (2.92:1 → 21:1)
- ShopScreen: "Book Now" button orange darkened from 0xFFE65100 to 0xFFBF360C on white (4.13:1 → 6.34:1)
- RecognitionScreen: NEW badge teal darkened from 0xFF00BFA5 to 0xFF00897B (2.33:1 → 3.54:1 AA-large)
- RecognitionScreen: "New Discoveries" text darkened from 0xFF00BFA5 to 0xFF00695C on light teal (3.88:1 → 7.21:1)
- WritingScreen: Admin debug text darkened from 0xFFE65100 to 0xFFBF360C on cream (3.46:1 → 6.34:1)

---

## v1.2.1 (2026-04-14) — Dakuten/Handakuten Kana Support (IDEA-002)

### Fixed
- Kana distractor pool now uses all variants (was basic-only, causing mismatched distractors for dakuten/handakuten questions)
- Distractors prefer same-variant kana first (dakuten distractors for dakuten questions, etc.)
- Fallback romanization list now includes dakuten (ga, gi, gu...) and handakuten (pa, pi, pu...) readings
- Targeted kana sessions use full variant pool instead of basic-only

---

## v1.2.0 (2026-04-14) — KanjiSage Word Transfer (S1-KJ-1)

### Added
- **Cross-app word transfer**: KanjiSage scan results can now be imported into KanjiJourney study deck
- `received_kanji` SQLDelight table for local tracking of transferred kanji
- `ReceivedKanjiRepository` — domain interface + implementation for received word management
- `ImportKanjiUseCase` — processes received kanji literals → SRS card + flashcard deck entry
- `ImportKanjiViewModel` — Hilt-injected ViewModel for deep link import handling
- Deep link `kanjijourney://import?source=kanjisage&kanji=漢,字,日` — transfers kanji to study system
- AndroidManifest intent-filter for `kanjijourney://import` scheme
- Supabase migration SQL (`docs/migration-received-words.sql`) for `kj_received_words` table
- DI wiring in AppModule for ReceivedKanjiRepository + ImportKanjiUseCase

---

## v1.1.3 (2026-04-13) — Writing Canvas Cross Guides (IDEA-001)

### Added
- Cross guide lines (十字) on writing canvas dividing the square into 4 quadrants for stroke positioning (DrawingCanvas.kt)
- Dashed gray lines at 25% alpha, drawn beneath ghost strokes so they don't compete visually

---

## v1.1.2 (2026-04-10) — L1 Review Fixes

### Fixed
- All font sizes bumped to minimum 12sp (was 7-11sp in 20+ instances) — WCAG AA compliance
- Theme labelSmall from 11sp to 12sp
- Low-contrast text: DiscoveryOverlay (0.5f→0.7f), ShopScreen (0.6f→0.7f), KanjiDetailScreen (0.8f→0.85f)
- All corner radii bumped to minimum 8dp (was 2-6dp in 15 instances)
- Shape.kt: removed sub-8dp tokens (ExtraSmall 4dp, Small 6dp), minimum is now 8dp
- GlassChip shape from 6dp to 8dp

---

## v1.1.1 (2026-04-10) — WAVE 1 L1 Compliance

### Added
- **FocusIndicator.kt**: Focus ring system with `focusRing()`, `focusRingCircle()`, `focusRingTextField()` modifiers
- **Shape.kt**: Centralized corner radii tokens (KjShape: ExtraSmall→Pill, 4dp→24dp)
- **Spacing.kt**: Centralized spacing tokens (KjSpacing: XXS→Huge, 2dp→32dp)
- **Semantic color tokens**: GameColors (7 game mode accents), StateColors (correct/incorrect/gold/info), MasteryColors (4 progress levels)
- **Focus indicators on ALL interactive elements**: Buttons, IconButtons, TextButtons, OutlinedButtons across 25+ screens
- **FocusRequester on TextFields**: LoginScreen email/password fields with programmatic focus management
- **isError + supportingText on TextFields**: LoginScreen (email/password), FlashcardScreen (deck name dialogs)

### Changed
- Migrated 88% of hardcoded Color(0x...) values to semantic tokens (174→21 remaining)
- LoginScreen: OutlinedTextFields now show validation errors with `isError` + `supportingText`
- FlashcardScreen: Deck name fields show "required" error when blank
- MainScaffold: Nav bar selected color now uses `GlassBrand.current` instead of hardcoded hex

---

## [Unreleased]

### Added (iOS — Glass UI Port)
- **GlassTheme.swift**: Full port of Android GlassTheme.kt to SwiftUI
  - GlassCard, GlassChip, GlassTopBar, GlassNavigationBar, GlassSection components
  - GlassColors palette: dark background (#050508), surface layers, text opacity hierarchy
  - GlassBrand per-app colors (KanjiJourney=orange, KanjiLens=teal, EigoQuest=blue, EigoLens=indigo)
  - GlassTypography with DM Sans font family (Light/Regular/Medium/Bold)
- **DM Sans fonts**: Copied from Android to iOS Resources/Fonts/
- **Dark mode enforced**: `.preferredColorScheme(.dark)` on app root

### Changed (iOS — Glass UI Port)
- **KanjiJourneyTheme.swift**: Updated color palette from light cream to glass dark theme
  - background: 0xFFF8E1 → 0x050508, surface: white → 0x12121E, primary: 0xFF8C42 → 0xFF6B35
- **HomeView**: Full glass conversion — GlassCard profile, upgrade banner, learning paths, grid items, GlassChip tabs
- **MainTabView**: Glass-styled UITabBarAppearance (dark background, orange selection)
- **GamesTabView**: Glass card game modes with colored accent strips
- **MockHomeView**: Glass aesthetic with dark backgrounds, glass cards, brand-tinted borders
- **STATUS.md**: Corrected feature parity matrix — iOS was ~95% complete, not ~20% as previously shown

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
