# KanjiJourney Mistakes

Log of agent decision/reasoning errors. BUGS = code broke, MISTAKES = agent chose wrong.

## Log

### M-001: Used `bodyAsText()` instead of `body<String>()` (2026-05-19)
**What:** In LeaderboardRepositoryImpl, used Ktor's `bodyAsText()` without checking how sibling files (DevChatRepositoryImpl, FeedbackRepositoryImpl) read Supabase function responses.
**Why wrong:** `bodyAsText()` requires a different import chain that isn't available in the KMP commonMain context. The codebase pattern is `response.body<String>()` with `import io.ktor.client.call.body`.
**Lesson:** Before choosing an API pattern, grep the codebase for existing usage in sibling files. Follow the established pattern.
