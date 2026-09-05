# KanjiJourney Bugs

## Failure Mode Categories

KanjiJourney bugs are categorized for systematic troubleshooting. Classify first, then run the probes.

### Cat-A: Auth & Account
Symptoms: can't log in, OAuth loop, token expired, quota/429, wrong user identity
Probes: (1) curl Supabase `/auth/v1/settings` — verify anon key not revoked (2) list `auth.users` via Admin API for the email (3) check `flowType: 'implicit'` in client config (4) verify Stripe subscription status if feature-gated
History: 2026-07-30 — AUTH_SUPABASE_URL pointed at decommissioned cloud host (NXDOMAIN), broke login + premium gate. Fixed: repointed to self-hosted TutoringJay portal Kong, verified live.

### Cat-B: Study/SRS
Symptoms: wrong kanji shown, SRS intervals off, mastery badge not awarded, placement test broken, game mode crashes mid-session
Probes: (1) query SQLDelight `study_progress` table for the kanji/user (2) check `item_level` XP thresholds vs actual XP (3) verify Kuromoji tokenizer loaded (no silent init failure) (4) check adaptive difficulty parameters in shared-core
History: (none yet)

### Cat-C: JCoin/Shop
Symptoms: J Coins not earned/spent, shop purchase fails, booster not applied, leaderboard stale
Probes: (1) curl j-coin.jworks-ai.com `/rest/v1/j_coin_balances?user_id=eq.<id>` (2) check Stripe webhook delivery for subscription events (3) verify `coin_config` table values (earn rates, caps) (4) check offline queue for pending JCoin transactions
History: 2026-07-27 — jcoin backend anon/service_role keys rotated for leaked-secret remediation; baked SUPABASE_ANON_KEY went dead for rest-v1 calls (ForceUpgradeChecker only — functions-v1 unaffected, not Kong-gated). Fixed 2026-07-30: refreshed to rotated key, verified live. Also repointed SUPABASE_URL from the retired unhyphenated jcoin hostname to j-coin.jworks-ai.com (hyphenated is canonical per Jay ruling).

### Cat-D: Sync (SQLDelight ↔ Supabase offline queue)
Symptoms: data lost after offline session, progress not syncing, duplicate entries, state drift between local and server
Probes: (1) check SQLDelight local DB row count vs Supabase remote count for user (2) inspect offline queue pending items (3) verify Supabase URL + anon key in build config (4) check network reachability + retry backoff state
History: (none yet)

### Cat-E: Render (Glass UI / Calligraphy)
Symptoms: Glass UI broken/transparent, calligraphy strokes not drawing, cross guide lines missing, Gemini AI feedback not returned, writing canvas blank
Probes: (1) check Material3 theme applied (GlassTheme composables) (2) verify canvas touch events registering (Android: DrawingCanvas.kt, iOS: CalligraphyCanvasUIView) (3) curl Gemini API with test stroke data (4) check `@Composable` recomposition count for canvas — excessive = perf bug
History: BUG-002 (camera preview), BUG-003 (iPhone calligraphy)

### Cat-F: Platform (Android / iOS / iPad)
Symptoms: works on one platform not another, build failure platform-specific, KMP shared module compile error, SKIE bridge issue
Probes: (1) `./gradlew :android-app:assembleDebug` — Android build check (2) Xcode build log for iOS/iPad (3) check `#if IPAD_TARGET` or `@available` gates not excluding functionality (4) verify ML Kit / AVFoundation camera lifecycle per platform (5) check KMP expect/actual declarations match (6) FoundationModels `@available(iOS 26, *)` gating — ensure fallback path exists for iOS <26
History: BUG-003 (iPhone calligraphy excluded by iPad-only gate)

### Cat-G: Deploy
Symptoms: old version live, APK not installable, build-arg mismatch, Play Store rejection
Probes: (1) check VERSION file vs APK `versionName` in build.gradle.kts (2) verify keystore password in local.properties (3) `adb install` output for signature mismatch (4) check `.github/workflows/android-build.yml` for CI failures
History: BUG-001 (APK size)

---

## Open

- [ ] [BUG-001] APK size — debug 67MB, release estimated ~40-45MB (was 123MB)
  - **Severity**: Low (likely under 50MB target)
  - **Progress**: v1.2.5 — deleted db.bak (24MB), PNG→WebP (49MB→460KB), ABI filter, resource shrinking
  - **Estimate**: Release intermediates: DEX 9.6MB + resources 0.8MB + native libs 19.4MB (2 ABIs) + assets 24.5MB = ~54MB pre-compression → ~40-45MB in APK
  - **Correction (2026-07-30, jworks:44)**: the "blocked on keystore password" note here was stale — verified live via `gh run view` on 2026-07-23 that CI's build-release job (keystore decode + signing) passes. Removing the blocker; APK-size figure itself not re-measured this pass.

- [x] [BUG-004] Premium subscription check silently returns empty for every user (app_id namespace mismatch) — REPORTED FIXED 2026-07-30, not independently confirmed
  - **Severity**: High — the entire premium/free gate is non-functional until this lands
  - **Cat**: A (Auth & Account)
  - **Found**: 2026-07-30, jworks:44 + jayhub-mac:110 cross-verification
  - **Detail**: `AuthRepositoryImpl.kt:114` queries `app_subscriptions` with `eq("app_id", "kanjijourney")` — confirmed every app_id reference in the codebase (Subscription.kt default, ForceUpgradeChecker.APP_ID, FeedbackViewModel.APP_ID) is the literal string `kanjijourney`. jayhub-mac:110 confirmed live on the portal stack that the only `app_id` present in `app_subscriptions` was `kanjiquest` (55 rows, zero `kanjijourney` rows) — a pre-rename namespace that was never data-migrated when the app renamed KanjiQuest→KanjiJourney (jworks:35: their migration 024 added the `kanjijourney` constraint but didn't migrate existing rows). Net effect: `checkSubscription()` could never match a row, so every user's premium status silently evaluated to free/false regardless of actual subscription state.
  - **Fix**: jayhub-mac:110 reports the portal-side data migration is done live — `app_id` now `kanjijourney` for all 55 rows (53 free / 2 student). NOT independently verified by jworks:44: attempted a curl check against `app_subscriptions` via anon key, got empty results (content-range */0) for both app_ids — almost certainly RLS correctly blocking anon-only reads (no user session), not evidence either way. Treating as reported-but-unconfirmed until seen working end-to-end through the app.

- [x] [BUG-005] shared-core unit tests fail to compile (RESOLVED 2026-07-30 — revealed BUG-007)
  - **Severity**: Medium — blocked running the JCoin/game-engine test suite at all
  - **Cat**: F (Platform)
  - **Found**: 2026-07-30, jworks:44, while verifying an unrelated fix (BUG-006) didn't break tests
  - **Detail**: `./gradlew :shared-core:testDebugUnitTest` failed at `compileDebugUnitTestKotlinAndroid`. Two independent causes: (1) `CompleteSessionCoinTest.kt` + `JCoinRepositoryTest.kt` reference `JdbcSqliteDriver`, which is JVM-only — they lived in `commonTest` (compiled for iOS too, where that class can't exist), so they were unresolved on the Android unit-test target. (2) `GameEngineTest.kt` + `WritingModeEngineTest.kt` have `Fake*Repository` test doubles (`FakeKanjiRepository`, `FakeSrsRepository`, `WritingTestKanjiRepository`, `WritingTestSrsRepository`) that didn't implement ~15-20 newer `KanjiRepository`/`SrsRepository` interface methods (Kanken level, vocabulary-by-offset, mode-stats, etc.) added by later features.
  - **Fix**: (1) moved the two JDBC-driver tests from `commonTest` to `androidUnitTest` (correct KMP scoping — they're JVM-only tests) + added the driver dependency to `androidUnitTest.dependencies`. (2) Implemented the missing interface methods on all 4 fakes, matching each file's existing style (derive from in-memory state where natural, trivial empty/null/0 default otherwise).
  - **Verified**: `:shared-core:testDebugUnitTest` now compiles and runs — 94 tests execute (previously 0 could even compile). `JCoinRepositoryTest` (the suite covering the code actually touched by BUG-006) passes 10/10. 27 of the 94 fail — see BUG-007, confirmed pre-existing/unrelated via `git diff --stat`, not caused by this fix.

- [ ] [BUG-007] 27 pre-existing test failures newly exposed by the BUG-005 compile fix
  - **Severity**: Medium-High — some failures look like real production bugs, not test bugs
  - **Cat**: F (Platform)
  - **Found**: 2026-07-30, jworks:44, immediately after fixing BUG-005
  - **Detail**: 94 tests now run (previously 0 could compile); 27 fail across `GameEngineTest`, `WritingModeEngineTest`, `Sm2AlgorithmTest`, `SvgPathParserTest`, and `CompleteSessionCoinTest` (5/7). Confirmed unrelated to the 2026-07-30 changeset via `git diff --stat` — `JCoinRepositoryTest`, the suite covering what was actually touched, passes 10/10. Notable individual findings worth prioritizing: `SvgPathParserTest.parseSvgPath_simpleMoveAndCubic` expects 2 path segments, gets 9 (stroke-path parsing — feeds calligraphy rendering); `CompleteSessionCoinTest.session20Cards_earns10Coins` expects 10 coins, gets 0; `multipleSessionsAccumulate` hits a SQLite `UNIQUE` constraint violation on `study_session(started_at, game_mode)` (possible real bug if a user starts two same-mode sessions within the same second — worth checking if this can happen for real, not just in a fixed-clock test).
  - **Not triaged this pass** — this pass was verifying BUG-005/006 didn't regress anything, not auditing the whole suite. Real investigation needed per-file.

- [x] [BUG-006] Double-mint risk in guest→auth migration (RESOLVED 2026-07-30)
  - **Severity**: High — real economic/ledger correctness bug, live in shipped v1.3.0
  - **Cat**: C (JCoin/Shop)
  - **Found**: jworks:35, during Phase 4 auth-integration design discussion
  - **Detail**: `MigrateLocalDataUseCase.execute()` called both `migrateBalanceUserId` (moves the aggregate local balance to the auth user id) AND `migrateSyncQueueUserId` (re-stamps the queued earn-EVENTS that produced that balance onto the same auth user id). Since `jcoin-unified-earn` has zero idempotency/dedupe (confirmed by jworks:35 reading the function source — plain read-modify-write), those re-stamped events would later drain via `CoinSyncWorker` and double-credit the same activity server-side.
  - **First fix attempt (superseded)**: replaced `migrateSyncQueueUserId` with `deleteSyncQueueForUser`, deleting the guest's queue outright. jworks:35 caught the flaw: this stranded the coins on-device only — the server never learns about them, so a reinstall/device-change/data-clear loses them, breaking the "coins never expire" promise by a different route.
  - **Final fix**: added `JCoinRepository.reconcileMigratedBalance(userId, amount, eventId)` — sends ONE aggregate earn event (`source_type=guest_migration`, deterministic `client_event_id="migration:{authUserId}"`) before the local queue is deleted, so the server learns about the pre-login coins exactly once. `MigrateLocalDataUseCase` is now `suspend`; if the reconcile call fails, the entire migration aborts without touching any local data, retrying cleanly on the next sign-in instead of losing or duplicating coins.
  - **Verified**: `assembleDebug` BUILD SUCCESSFUL after each change; confirmed `client_event_id`/`guest_migration`/`migration:` strings present in the compiled `classes.dex`.

## Resolved

- [x] [BUG-002] Camera Challenge AVFoundation preview — live camera + Vision OCR (v0.2.0, 2026-04-24, jworks:47)
- [x] [BUG-003] iPhone calligraphy mode excluded (Apple Pencil only) — fixed v0.2.0 (2026-04-24, jworks:47)
  - Velocity-based pressure simulation for finger input
  - Removed #if IPAD_TARGET compile gates from 5 files
