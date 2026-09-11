# KanjiJourney Mistakes

Log of agent decision/reasoning errors. BUGS = code broke, MISTAKES = agent chose wrong.

## Log

### M-001: Used `bodyAsText()` instead of `body<String>()` (2026-05-19)
**What:** In LeaderboardRepositoryImpl, used Ktor's `bodyAsText()` without checking how sibling files (DevChatRepositoryImpl, FeedbackRepositoryImpl) read Supabase function responses.
**Why wrong:** `bodyAsText()` requires a different import chain that isn't available in the KMP commonMain context. The codebase pattern is `response.body<String>()` with `import io.ktor.client.call.body`.
**Lesson:** Before choosing an API pattern, grep the codebase for existing usage in sibling files. Follow the established pattern.

### M-002: First BUG-006 fix closed the double-mint window but opened a coin-loss window (2026-07-30)
**What:** To fix the double-mint risk in guest→auth migration, the first attempt replaced `migrateSyncQueueUserId` (re-stamp the queue) with `deleteSyncQueueForUser` (delete it outright).
**Why wrong:** Deleting the guest's sync queue stops the double-credit, but the server never learns about those pre-login coins at all — a reinstall/device-change/data-clear before the next real sync would lose them, breaking the "coins never expire" promise via a different route than the one being fixed.
**Lesson:** When a fix for "duplicate/double-X" is "just delete the thing that would duplicate," check whether that thing was also the only record of something that must not be lost. The safe shape here was reconcile-then-delete with an idempotent event (deterministic `client_event_id`) and an abort-on-failure path — not delete-then-hope. Caught by jworks:35 in review before shipping further.

### M-003: Claimed BUG-007 was "confirmed unrelated" based on a diff, not a run (2026-07-30, corrected 2026-09-04)
**What:** After fixing BUG-005 (test-compile breakage), noted the 27 resulting BUG-007 test failures as "confirmed pre-existing/unrelated via `git diff --stat`."
**Why wrong:** `git diff --stat` shows which files changed, not whether anything *inside* those files' changes caused the failures — and it can't, because the suite never compiled before BUG-005, so there was no prior green run to diff against in the first place. "Pre-existing" was an unverifiable claim dressed as a verified one. On 2026-09-04 triage, 15 of the 27 failures turned out to have nothing to do with either explanation on file — a separate, real `LevelProgression` gap (level-1 players have zero unlocked grades) that just happened to become visible at the same time.
**Lesson:** "The diff doesn't touch that file" is not the same claim as "that file's behavior is unchanged," and neither is the same claim as "this test passed before." State only what was actually run and observed — if there's no prior baseline to compare against, say so instead of writing "confirmed."

### M-004: Closed a fleet_tasks zombie by citing my own TODO.md line without checking the claim matched (2026-09-05, corrected 2026-09-11)
**What:** During a /tasks audit, closed the fleet_tasks row "Auth integration: replace LOCAL_USER_ID" citing my own TODO.md's "Phase 4 auth integration + double-mint (BUG-006) — fully closed out with jworks:35" as evidence of completion.
**Why wrong:** BUG-006 was a narrow migration bug fix (double-mint risk in guest→auth JCoin sync) — not the broader "replace LOCAL_USER_ID with real auth" epic the fleet_tasks row actually described. The two subjects share the word "auth" and a date, nothing more. jworks:35 confirmed 2026-09-11 the real epic is still unbuilt/unspecced on their side. I treated my own prior summary line as corroborating evidence for a different, broader claim instead of checking whether the cited evidence actually matched the specific thing being closed.
**Lesson:** A "done" line in TODO.md closes exactly the work it describes — it is not free evidence for every fleet_tasks row that shares a keyword with it. Before closing a zombie row by citation, re-read the row's actual subject against the cited evidence's actual scope, not just their topical overlap. This is Verification Rule 6 ("agreement is not corroboration") wearing a different disguise: the "agreement" here was between two of my own claims, not two independent sources, and that's just as capable of being correlated error.
