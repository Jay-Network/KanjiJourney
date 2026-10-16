# KanjiJourney Changelog

All notable changes to KanjiJourney are documented here.
Follows versioning standard: vMAJOR.MINOR.PATCH (v0=Alpha, v1=Beta, v2=Store)

---

## v1.4.18 (2026-10-16) — J Coin sync no longer stores request headers (tokens) in the local database, BUG-015 (jworks:44)

### Fixed
- `syncPendingEvents` saved the whole exception message in `coin_sync_queue.error_message`. For a supabase-kt `RestException` that includes the request headers: the user's Bearer access token and the apikey. Only the text before `URL:` is stored now, at most 500 characters (`storedErrorMessage()`).

### Verification
- `StoredErrorMessageTest` 3/3 and `AnonymousSignupBodyTest` 3/3 pass (`:shared-core:testDebugUnitTest`, log `agent-text/jworks-44/kj-test-stored-error.log`).
- v1.4.17 device result (Z Flip 7, 2026-10-16): the anonymous signup works (session saved, `user_metadata.country` = "US"). The earn reaches `jcoin-unified-earn` with the user token (no 401), and the server refuses it: "Premium subscription required". J Coin credits only premium bought through its own checkout. How players earn is with Jay (task #41).

## v1.4.17 (2026-10-16) — J Coin: anonymous sign-in so Android calls carry a user token (task #41, pending Jay's decision) — UNVERIFIED

### Fixed
- Android J Coin calls were refused 401 by the function's auth layer, which needs a user token. The J Coin client now installs Auth. `SupabaseClientFactory.ensureAnonymousSession()` signs the install in anonymously on the J Coin project once, and Functions then sends that access token as Bearer. The earn sync and the guest-balance reconcile both ensure the session first. If sign-in fails, the queued earns stay queued. (BUG-010)
- `syncPendingEvents` no longer posts spend rows to `jcoin-unified-earn`, where each purchase would have been credited as an earn once calls succeed. Only `event_type = 'earn'` rows are sent; spends stay queued. Found by jworks:72. (BUG-011)
- WorkManager could not create `CoinSyncWorker` or `LearningSyncWorker` (`NoSuchMethodException`), so neither background sync ever ran on Android. The AndroidX Hilt compiler (`androidx.hilt:hilt-compiler` 1.2.0) now generates the `@HiltWorker` factories; it replaces a duplicate Dagger compiler line. (BUG-012)

### Added
- The anonymous J Coin signup sends the device country as `data.country` (uppercase ISO alpha-2 from `Locale.getDefault().country`; omitted when empty or not two letters). It lands in the J Coin project's `auth.users.raw_user_meta_data.country`; copying it into `customers.country` is J Coin backend work (jworks:35). Requested by jworks-vm:35, S-337 option A, dlg-4012ef0b6c4245d2a820d1d5. Unit test: `AnonymousSignupBodyTest`.

### Docs
- Release gate (task #42, jworks:0): `STATUS.md` and `BETA_LAUNCH_READY.md` now require an app-restricted Gemini key before the APK goes past the current testers. The APK carries a Gemini key that is not restricted to the app (jayhub:67).

### Known limits (anonymous accounts are NOT yet approved by Jay; desk card open, so this must not ship to players before his answer)
- Coins follow the install's anonymous session. Clearing app data or reinstalling loses them until accounts are linked (task #31).
- The guest-balance reconcile on sign-in now runs under the anonymous session. Whether it credits the signed-in account is not verified.
- Session persistence uses supabase-kt's default session manager on Android. Confirm on a device.

### Verification
- Unit tests: `AnonymousSignupBodyTest` 3/3 pass (`:shared-core:testDebugUnitTest`).
- Pixel 10 Pro, debug APK sha256 4fb37f28 installed over a fresh test install: `CoinSyncWorker` now starts (BUG-012 verified). The signup request reaches `https://j-coin.jworks-ai.com/auth/v1/signup`.
- NOT verified: the earn round trip. The 09:33Z signup got a server-side 504 (GoTrue 10.2 s timeout, Mac overloaded, per jayhub-mac:110), and the Pixel was then needed for eBay runs. One queued test earn (5 coins, tagged `[e2e test jworks:44]`) waits on the device for the app's next retry.
- Session persistence across restarts and the country field on a real signup are not yet observed on a device.

## v1.4.16 (2026-10-15) — Docs: service-role key retired from the certificate guide (jworks:47)

### Docs
- `docs/APPLE_CERTIFICATE_GUIDE.md` no longer tells the reader to add `SUPABASE_SERVICE_ROLE_KEY` as GitHub secret 3. Secret 3 is marked retired, with the reason. It was also dropped from the Part 5 table. Found in jworks:72's review of `6a1d4af`.
- v1.4.15 follow-up corrected: the GitHub secret does not exist (jayhub:67, names only, 2026-10-15).

### Shipping history (adds to v1.4.15)
- The deleted legacy workflows `kanjiquest-ipad.yml` and `kanjiquest-iphone.yml` had the same xcconfig step. 23 of their runs succeeded between 2026-02-22 and 2026-02-27. The two run logs that survive (2026-02-23 and 2026-02-24) show the secret empty; the rest have expired. J_Coin rotated its service-role key in July. No rotation is needed (jworks:72).

### Review
- jworks:72 reviewed `6a1d4af`: PASS on the build path. A fresh clone grep found no service-role reference in Swift, Info.plist, the xcodegen specs, the xcconfig template or any workflow.

## v1.4.15 (2026-10-15) — iOS: Supabase service-role key removed from the app build (jworks:47) — UNVERIFIED on Mac

### Security
- The iOS build no longer carries `SUPABASE_SERVICE_ROLE_KEY`. A service-role key bypasses row-level security, so it must never be inside a client app. Found by jworks:72 (dlg-afc8c867fb224dfc8b14b4ee). Removal agreed with jayhub:0.
- Removed from both TestFlight workflows (`kanjijourney-ipad.yml`, `kanjijourney-iphone.yml`), `Info.plist`, `project.yml`, `project-iphone.yml`, `Configuration.swift` and `KanjiJourney.xcconfig.template`. Also removed from the CI-SETUP, CI-SECRETS-TEMPLATE and README docs, which now list 10 CI secrets. No Swift code read the value.

### Shipping history
- GitHub Actions: all 26 runs of the two TestFlight workflows (2026-03-01 to 2026-10-15) failed at certificate import or earlier. The xcconfig step that wrote the key was skipped every time, so no CI build carried it. The App Store Connect TestFlight history was not checked; that needs App Store Connect access.

### Follow-up
- The GitHub secret `SUPABASE_SERVICE_ROLE_KEY` does not exist (checked names only by jayhub:67, 2026-10-15). Nothing to delete.

### Verification
- Source: grep for `SERVICE_ROLE` over `ios-app/` (build, DerivedData and Frameworks excluded). Mac build on both targets: pending.

## v1.4.14 (2026-10-15) — iPhone build: remaining calligraphy references guarded to iPad (jworks:47) — UNVERIFIED on iPhone

### Fixed
- The iPhone target still failed after v1.4.13. Two more references to iPad-only calligraphy code, which the iPhone target excludes, are now inside `#if IPAD_TARGET`:
  - `AppNavigation.swift`: the `.calligraphySession` route. The iPhone build gets an `EmptyView` so the switch stays exhaustive.
  - `KanjiJourneyApp.swift`: the calligraphy card and its full-screen cover in the debug mock home. Without this, iPhone shows a dead button.
- Found by jworks-mac:90 on `f61452b`. Its trial build with these guards succeeded with zero errors.

### Verification
- **iPhone: not yet verified.** It needs a KanjiJourneyPhone simulator build of this commit plus one top-bar screenshot.

## v1.4.13 (2026-10-15) — iPhone build fix: calligraphy feedback factory is iPad-only (jworks:47) — UNVERIFIED on iPhone

### Fixed
- **The iPhone target did not compile.** `AppContainer.makeCalligraphyFeedbackService()` names `CalligraphyFeedbackService`, which lives in `Calligraphy/`, and `project-iphone.yml` excludes that folder. The factory is now wrapped in `#if IPAD_TARGET`, which only the iPad target sets. This predates v1.4.12: every iPhone CI run since 03a051d has failed, and the Mac's iPhone build of `aa10293` failed on this one line.

### Verification
- iPad, `aa10293` (jworks-mac:90): simulator build succeeded with 0 errors. The envelope fix works: one "Send feedback" button in the top bar on Main, Study, Play and Collect, and it opens the dialog. XCUITest passed.
- **iPhone: not yet verified.** It needs a Mac iPhone simulator build of this commit.
- Cosmetic, not changed: in the feedback dialog the last category chip ("Other") sits at the right edge of a horizontal scroll row.

## v1.4.12 (2026-10-15) — iPad: Feedback top bar moved to the TabView (jworks:47) — UNVERIFIED

### Fixed
- **The Feedback button never appeared on iPad.** The Mac build (jworks-mac:90, `fbf23ed`) showed the Main/Study/Play/Collect tab bar with no envelope icon, and since the FAB was removed in v1.4.10 iPad users had no feedback entry point. A `.toolbar` placed inside a tab does not reach the navigation bar on iPad. The same applies to Home's gear and J buttons, which jworks-mac:90 reported on 2026-10-11. The top bar now lives on the `TabView` in `MainTabView`, and the four per-tab calls are removed (so iPhone shows one button, not two).

### Verification
- Compile on `fbf23ed`: pass (jworks-mac:90, iPad simulator, zero errors).
- **Not yet verified for this change.** The Mac needs to confirm the envelope icon appears on all four tabs on iPad and iPhone.
- Open, not changed here: on iPad the Mac's accessibility tree has no Home gear (Settings) or J (Shop) element. Settings may be unreachable there. Same mechanism as this fix, but a separate change.

## v1.4.11 (2026-10-15) — Test: regression test for the getFeedbackUpdates query encoding, BUG-009 (jworks:44)

### Changed
- The query string for `getFeedbackUpdates` is built by `feedbackUpdatesQuery()` (internal, same file). Behavior is unchanged.

### Added
- `FeedbackUpdatesQueryTest` (shared-core commonTest). It round-trips the query through Ktor's `parseQueryString`, so a raw "+" in an email fails the test. Mutation check: with the encoding removed, 2 of 4 cases fail. The encoding was restored and the file matches the tested copy.

### Verification
- `./gradlew :shared-core:testDebugUnitTest --tests FeedbackUpdatesQueryTest --offline`: BUILD SUCCESSFUL, 4/4 pass (`agent-text/jworks-44/kj-test-feedback-query-android.log`). The JVM test task cannot resolve its supabase `-jvm` artifacts offline on this host; the Android unit-test target runs the same commonTest.
- iOS parity of the encoding is still unverified until a Mac build runs.

## v1.4.10 (2026-10-15) — Feedback parity with Android: top-bar entry, not a FAB; email refresh on open (jworks:47) — UNVERIFIED

### Changed
- **Feedback entry point moved to the top bar** of the four main tabs (Main, Study, Play, Collect), as Android has it. The floating feedback button is removed because Android renders none: `FeedbackFAB.kt` has zero call sites at origin/main 1723f55 (jworks:44's check). Source: `Components/FeedbackToolbarButton.swift` plus one `.mainTabToolbar()` per tab.
- The Study, Play and Collect tabs now get Home's dark top-bar style. Needs a screenshot check.
- Feedback dialog: text area 120 → 150 pt, history list a fixed 200 pt scroll area (jworks:44's spec, dlg-4d4d8b2f).

### Fixed
- `FeedbackViewModel.openDialog()` now refreshes the user email, as the spec requires. The email was read once at launch, so a session that launched logged out kept showing "User not authenticated" after login.

### Open (not changed here)
- Dialog width (spec: min 95%) and the submit button's disable check on untrimmed text, which is a one-line change if parity needs it.

### Verification
- **UNVERIFIED.** No Swift compiler on this host. `FeedbackFAB.swift` was deleted, and the check for leftover references was blocked by the session guard, so the Mac build is the check. Needs a Mac build plus screenshots of all four tabs' top bars.

## v1.4.9 (2026-10-15) — Feedback: URL-encode user_email and app_id in getFeedbackUpdates (jworks:44)

### Fixed
- `FeedbackRepositoryImpl.getFeedbackUpdates` put `user_email` and `app_id` into the query string unencoded. The server reads a "+" in an email as a space, so a user whose address contains "+" would look up the wrong account, and the error was swallowed to an empty list. Both values now go through `encodeURLParameter()`. Found by jworks:47's parity check of the Feedback port (dlg-4d4d8b2fdf034f67b1bacad8). iOS inherits this shared-core code.

## v1.4.8 (2026-10-10) — Docs: correct ambiguous "CI run green" wording (jworks:47)

### Fixed
- v1.4.5's CHANGELOG entry and BUGS.md's BUG-008 both said "CI run 38019842453 green," which jworks:44 correctly read as claiming the whole iOS CI run passed. It didn't: only the "Build KMP XCFrameworks" job succeeded — the same run still fails later at the unrelated, already-tracked cert-signing step. Corrected both.

## v1.4.7 (2026-10-10) — Writing mode: smooth-curve strokes parsed; BUG-007 clusters 2-4 (jworks:44)

### Fixed
- **Writing mode graded ~900 kanji against distorted reference strokes**: `SvgPathParser` ignored the SVG `s`/`S` (smooth cubic) commands. In the bundled DB, 816 of 6,413 kanji use `s` and 87 use `S`. Those segments were dropped and every later relative segment in the stroke started from the wrong point. `WritingViewModel.submitDrawing()` grades the drawing against these parsed strokes. `s`/`S` are now parsed per the SVG spec, with regression tests including a real KanjiVG stroke (繦).
- **BUG-007 clusters 2-4 (9 failing tests) were stale tests, now updated**: the parser samples 8 points per curve (tests expected endpoints only); SM-2 has a 10-minute learning step (test expected 1 day); J Coin earning is premium-only (coin tests ran as a free user), and three identical sessions in one second hit `UNIQUE(started_at, game_mode)`. Added `freeUser_earns0Coins` to pin the premium gate. Details in BUGS.md.

## v1.4.6 (2026-10-10) — Android CI debug APK gets its config; versionName aligned (jworks:44)

### Fixed
- **CI debug APK shipped with empty Supabase/auth/Gemini config**: the `build-debug` job never wrote `local.properties`, so every `BuildConfig` URL and key was `""` and J-Coin, sign-in and handwriting scoring could not work in a CI-built APK. The job now writes it from repo secrets, and both jobs now also pass `AUTH_SUPABASE_URL`, `AUTH_SUPABASE_ANON_KEY` and `GEMINI_API_KEY`. A secret that is not set still expands to empty, as before. The `SUPABASE_*` secrets date from 2026-02-21 and jworks:35 says they are stale, and the two `AUTH_*` secrets do not exist yet, so a CI APK is still not tester-ready until those are set.
- **Android versionName 1.4.4 → 1.4.6** (versionCode 16 → 17) so the APK label matches VERSION.

## v1.4.5 (2026-10-09) — BUG-008 confirmed fixed; 3 more findings from real screenshots (jworks:47)

### Fixed
- **BUG-008 CONFIRMED WORKING** (jworks-mac:90, CI run 38019842453's "Build KMP XCFrameworks" job + a local iPad sim build): the app now reaches a real screen end to end — DB opens, `AppContainer.init()` completes, zero crashes in light or dark launches. First real screenshots exist (Shop screen). That CI run's *overall* status is still `failure` (unrelated cert-signing step, already tracked) — corrected 2026-10-10 after jworks:44 caught the ambiguous original wording here. See BUGS.md.
- **Dark Mode's Light option was a dead end**: `GlassColors` has no light variants, so picking "Light" in Settings only flipped the status bar, leaving it nearly unreadable against the still-dark background — reachable by any user now that the switch actually works. Removed "Light" from the Settings picker (Dark/System Default only) and clamped `KanjiJourneyApp.swift` to treat a persisted `.light` as `.dark` too. Real light-mode support needs a GlassColors light palette — a design decision, not made here.
- **Shop category chip order was non-deterministic**: `ShopViewModel.categories` went through a `Set`, which has no guaranteed iteration order in Swift. Changed to an order-preserving dedup.
- **`coin_sync_queue` missing `client_event_id`** (regression from v1.3.2/2650fa2, Android-only ALTER, caught by jworks:44): mirrored Android's exact try/catch `ALTER TABLE ... ADD COLUMN` pattern into iOS's `ensureNewTables()`. Would have crashed the first iOS J-Coin earn once BUG-008 was fixed.

None of the last 3 are independently rebuilt/screenshotted by me — no Xcode on this host. See BUGS.md for full evidence and what's still unverified.

## v1.4.4 (2026-10-09) — BUG-008 fix, round 3: remove the SELECT-via-execute() crash (jworks:47)

### Fixed (still UNVERIFIED — needs a Mac rebuild to confirm)
- v1.4.3's path fix WORKS (confirmed by jworks-mac:90: CI compiles green, DB opens with correct 24.7MB size, no more path-separator error). New crash, same file, next line: `driver.execute(null, "SELECT COUNT(*) FROM kanji", 0)` — sqliter's `execute()` refuses a `SELECT` (`SQLiteException: Queries can be performed using query or rawQuery methods only`). That line was a log-only diagnostic (kanji-count sanity check, not used for control flow) — removed it rather than swap in `executeQuery()`, since nothing downstream depends on its result. `ensureNewTables`'s own `execute()` calls (CREATE TABLE/INDEX, all non-query DDL) are untouched — they're exactly what `execute()` is for.

## v1.4.3 (2026-10-09) — BUG-008 fix, round 2: compiler-verified parameter name (jworks:47)

### Fixed (still UNVERIFIED — needs a Mac/CI rebuild to confirm it now compiles)
- v1.4.2's fix didn't compile: `NativeSqliteDriver`'s configuration-override parameter is named `onConfiguration`, not `onConfigurationChange` (confirmed from the real compiler error via jworks-mac:90's CI run 38018056551, not guessed). Corrected the parameter name and preserved other `DatabaseConfiguration.Extended` fields via `config.extendedConfig.copy(basePath = docsDir)` instead of constructing a fresh `Extended(...)`. Same underlying fix as v1.4.2 (BUG-008): bare filename as `name`, Documents dir as `basePath`.

## v1.4.2 (2026-10-09) — BUG-008 fix attempt: iOS DB open crash (jworks:47)

### Fixed (UNVERIFIED — needs a Mac rebuild to confirm) — superseded by v1.4.3, did not compile
- `shared-core/.../DatabaseDriverFactory.kt` (iosMain): `NativeSqliteDriver` was being given the full resolved Documents path as `name=`, which the installed sqliter version rejects (`IllegalArgumentException: ... contains a path separator`) — crashed the real app on launch, before reaching any real screen (Shop, Achievements, every game mode go through `AppContainer`, which triggers this). Found by jworks-mac:90 building+running main@1c44ba0 on an iPad simulator. Changed to the bare filename + `DatabaseConfiguration.Extended(basePath = docsDir)` via `onConfigurationChange`. Pre-existing bug (dates to the KanjiQuest→KanjiJourney rename, c8a90c1) — unrelated to v1.4.0/v1.4.1. See BUGS.md BUG-008. Not independently compiled by me (no Xcode on this host); asked jworks-mac:90 to rebuild and confirm. **Did not compile — wrong parameter name, see v1.4.3.**

## v1.4.1 (2026-10-09) — WCAG 1.4.1 fix: non-color answer-tile labels (jworks:47)

### Fixed
- 5 game screens (`KanaRecognitionView`, `RadicalBuilderView`, `RadicalRecognitionView`, `VocabularyView`, `PlacementTestView`) signaled correct/wrong multiple-choice answers by tile color alone. Ported `RecognitionView.swift`'s existing `answerAccessibilityLabel` helper into all 5, so VoiceOver now announces "correct answer" / "your answer, incorrect" instead of relying on color. Closes the second WCAG L1 audit finding from v1.4.0; see BUGS.md.

## v1.4.0 (2026-10-09) — iOS Glass UI completion, Dark Mode wiring, WCAG accessibility labels (jworks:47)

### Added — UNVERIFIED, no build or render has happened (jworks:0 caught this 2026-10-09; see BUGS.md)
- **Glass UI applied to remaining iOS screens**: `GlassTheme.swift` gained a reusable `.glassCard()` ViewModifier; applied across Achievements, Collection (Hub + grid), Settings, Shop, Study, Subscription, and the Recognition game screen, replacing flat `KanjiJourneyTheme.background`/`.cornerRadius` card styling with the glass surface treatment already used elsewhere. **Not yet build- or screen-verified** — no Xcode build has run and no screen has been looked at.
- **Dark mode ViewModifier wired up**: `KanjiJourneyApp.swift` now reads the existing `AppTheme` setting via `@AppStorage("theme")` and switches `.preferredColorScheme` between light/dark/system, replacing the previous hardcoded `.preferredColorScheme(.dark)`. **Not yet build- or screen-verified.**
- **WCAG L1 accessibility fix**: added `.accessibilityLabel()` to the 6 icon-only buttons found by the 2026-10-09 audit (feedback envelope, 2x refresh, flashcard star-toggle, settings gear, back chevron) — see BUGS.md. Lower risk (string-only additions matching an identical pattern already shipped elsewhere in the codebase) but also not compile-verified.

### Note
This source tree has been uncommitted, in-progress work (Glass UI + Dark Mode) sitting across several September/October sessions, authorship not git-attributable since it was never committed — almost certainly jworks:47's own prior work given exclusive scope over `ios-app/`, but not confirmed. Landed together with this session's accessibility pass; I read every diff before committing (no android-app changes included) but did NOT compile or render any of it — no macOS/Xcode available on this host. A Mac build + screenshots is the actual verification step, requested from jayhub-mac:110 (2026-10-09).

## v1.3.3 (2026-10-09) — One transport retry on keyed J-Coin earns

### Added
- **One automatic retry on a transport failure** (timeout or connect failure) for J-Coin earn calls, via `withOneTransportRetry` in `JCoinRepositoryImpl.kt`. The J-Coin backend sleeps when idle and cold-wakes in ~10 s, so the first call after idle can time out while the retry lands on the warm stack. Enabled after jworks:35 confirmed their server-side `client_event_id` dedup is live (2026-10-09 ~05:30Z): a repeated key returns the original award instead of crediting twice.
- Applied only where a dedup key is present: queued earns carrying the v1.3.2 `client_event_id`, and the guest-migration reconcile (`migration:{authUserId}`). Legacy queued rows without a key, and spend events (purchases, boosters), get no retry — without a key a repeated request would credit twice.
- Never retries when the server answered (`RestException`); only Ktor `HttpRequestTimeoutException` and supabase-kt `HttpRequestException`, confirmed from the resolved supabase-kt 2.1.5 bytecode.
- 3 regression tests: timeout-then-success returns the second attempt, retries exactly once, non-transport errors are not retried. `JCoinRepositoryTest` 16/16.

---

## v1.3.2 (2026-09-27) — J-Coin Earn Dedup Key

### Added
- **`client_event_id` on the regular earn path**: `coin_sync_queue` gets a new `client_event_id` column (idempotent `ALTER TABLE` for existing installs, in `DatabaseDriverFactory.ensureNewTables()`). Generated once as a UUID when an earn is queued (`earnCoins` → `insertSyncEvent`), persisted with the row, and sent as a stable key on every retry of that same queued sync — never regenerated per send attempt. Requested by jworks:35 (J-Coin): their upcoming atomic-ledger deploy will dedupe earns on this key server-side (`earn:<key>` prefix), returning the original award instead of double-crediting on a retried request. Spend events (purchases, booster activations) are unaffected — they pass `client_event_id = null`, unchanged from before.
- Regression tests: `JCoinRepositoryTest` — key is non-blank, two distinct earns get distinct keys, and the same queued row's key is stable across repeated reads (13/13 tests pass).

### Context
- Audited during a routine jworks:35 sync (BUG-cutover-audit): found the migration-reconcile earn path already sent a per-user dedup key (`migration:{authUserId}`, safe by design), but the far more common regular-earn path sent none at all — meaning the client-side retry jayhub:110 recommended for J-Coin cold-start timeouts would have been unsafe to enable until this shipped.

---

## v1.3.1 (2026-07-30) — J-Coin Double-Mint Fix + Test Suite Compile Repair

### Fixed
- **BUG-006 (double-mint risk in guest→auth migration)**: `MigrateLocalDataUseCase` no longer re-stamps the guest's queued earn-events onto the auth user id (would have double-credited on next sync, since `jcoin-unified-earn` has no idempotency). Added `JCoinRepository.reconcileMigratedBalance(userId, amount, eventId)` — sends one aggregate earn event with a deterministic `client_event_id` before the local sync queue is deleted; the use case is now `suspend` and aborts the whole migration (touching no local data) if the reconcile call fails, so a failure retries cleanly on next sign-in instead of losing or duplicating coins.
- **BUG-005 (shared-core unit test suite failed to compile)**: `CompleteSessionCoinTest` and `JCoinRepositoryTest` used `JdbcSqliteDriver` (JVM-only) from `commonTest`, which also compiles for iOS — moved both to `androidUnitTest` with the driver dependency added there. `GameEngineTest`/`WritingModeEngineTest`'s fake repositories were missing ~15-20 newer `KanjiRepository`/`SrsRepository` interface methods — implemented on all 4 fakes. `:shared-core:testDebugUnitTest` now compiles and runs (94 tests, previously 0 could compile); `JCoinRepositoryTest` (covering the BUG-006 change) passes 10/10.
- **Auth/J-Coin backend URLs** (`local.properties`, not committed — see STATUS.md): repointed off two decommissioned hosts (cloud Supabase auth project, unhyphenated jcoin hostname) to the live self-hosted endpoints, with rotated anon keys.

### Known issue
- **BUG-007**: 27 of the 94 shared-core tests fail — pre-existing, confirmed unrelated to this changeset via `git diff --stat`, previously masked because the suite couldn't compile at all. Not yet triaged. See BUGS.md for the individual failures.

---

## v1.3.0 (2026-05-31) — Force-Upgrade Gate for Cloud Decommission

### Added
- **Force-upgrade version check**: On launch, queries `app_config` table on self-hosted Supabase for minimum required version. If current version is below minimum, a blocking "Update Required" screen prevents app usage and directs users to the Play Store.
- **ForceUpgradeChecker**: Postgrest query against `app_config` table with graceful fallback (network errors allow app to continue).
- **ForceUpgradeScreen**: Full-screen blocking UI with branded design (dark slate background, teal accent, store link button).
- kotlinx-serialization plugin added to android-app module for Supabase response decoding.

### Changed
- Android system splash screen stays on-screen during version check (seamless transition).
- versionCode: 14 → 15, versionName: 1.0.0 → 1.3.0 (aligned with VERSION file).

---

## v1.2.8 (2026-05-19) — J Coin Supabase URL Migration + Build Fix

### Changed
- **J Coin backend URL** migrated from cloud Supabase (`inygcrdhfmoerborxehq.supabase.co`) to self-hosted (`jcoin.jworks-ai.com`) per jworks:35 migration notice
- Keys unchanged (same JWT secret, anon key, service role key)

### Fixed
- **LeaderboardRepositoryImpl build error**: Added missing `import io.ktor.client.call.body` and reverted `bodyAsText()` → `body<String>()` to match codebase pattern (DevChatRepositoryImpl, FeedbackRepositoryImpl)

---

## v1.2.7 (2026-04-16) — Housekeeping: MISTAKES.md + Release APK Estimate

### Added
- **MISTAKES.md** — required by version control standards, was missing

### Changed
- Updated BUG-001 with release APK size estimate (~40-45MB) from intermediate build artifacts
- Release build blocked on keystore password in local.properties — needs Jay to fix

---

## v1.2.6 (2026-04-15) — Accessibility: Back Button Content Descriptions

### Fixed
- **Replaced 14 text-arrow back buttons** with proper `Icon(ArrowBack)` + `contentDescription = "Back"` for TalkBack/screen reader support
- Added missing `focusRingCircle()` modifier on FlashcardScreen back button
- Screens fixed: KanjiDetail, RadicalDetail, CameraChallenge, FieldJournal, Recognition, Writing, KanaRecognition, Vocabulary, WordDetail, Shop, Flashcard, FlashcardStudy, RadicalRecognition, RadicalBuilder

---

## v1.2.5 (2026-04-15) — APK Size Reduction (BUG-001)

### Fixed
- **Deleted stale `kanjijourney.db.bak`** from assets — 24MB savings
- **Converted all 34 PNG images to WebP** at 512px/q80 — 49MB down to 460KB
- Updated all `.png` references to `.webp` across 10 screen files (ShopScreen, StudyScreen, FlashcardScreen, ProgressScreen, AchievementsScreen, FieldJournalScreen, HomeScreen, GamesScreen, LoginScreen, AssetImage docstring)

### Changed
- Enabled `isShrinkResources = true` in release build (pairs with existing R8 minification)
- Added ABI filter for release builds: `arm64-v8a` + `armeabi-v7a` only (drops x86/x86_64 native libs ~21MB)
- Debug APK: 123MB → 67MB; release APK expected significantly smaller with R8 + ABI filtering

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
