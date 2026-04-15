# KanjiJourney — Gemini Development Log

Tracking Gemini integration experiments, prompt iterations, and Claude vs Gemini comparisons.

**Directive**: jworks:42 cascade from jworks:104 — Dual Agent Architecture.

---

## Feature Candidates for Gemini

| Feature | Current (Claude) | Gemini Opportunity | Priority |
|---------|------------------|--------------------|----------|
| Handwriting Evaluation | Gemini 2.0 Flash via HandwritingChecker.kt | Already Gemini — optimize prompts | High |
| AI Study Recommendations | Rule-based SRS (SM-2) | Gemini could personalize beyond SM-2 (learning pace, time-of-day patterns) | Medium |
| Word Context Sentences | Static examples from JMDict | Gemini generates contextual example sentences at user's level | High |
| Kanji Mnemonics | Hardcoded | Gemini generates personalized mnemonics from radical components | Medium |
| Writing Feedback Voice | Text-only feedback | Gemini Live API for real-time voice coaching during writing practice | High |
| Camera OCR Enhancement | ML Kit OCR → lookup | Gemini Vision for richer scene context (signs, menus, documents) | Low |
| Placement Test Adaptive | Fixed question pool | Gemini selects questions dynamically based on response patterns | Medium |

## Shared Assets with Competition Agents

Already shared with jworks:96 (KanjiWrite Coach, Gemini Live Agent Challenge):
- KanjiVG stroke extraction script (Python)
- 3-axis evaluation prompt (balance / stroke order / endings)
- Radical decomposition from kradfile-utf8
- All integrated in KanjiWrite Coach v0.4.0

## Prompt Iterations

### Handwriting Evaluation (HandwritingChecker.kt)
- **Current**: Gemini 2.0 Flash, 3-axis scoring (balance 1-5, stroke order 1-5, endings 1-5)
- **v1 prompt**: Basic "evaluate this handwriting" — vague feedback
- **v2 prompt (current)**: Structured JSON response with specific stroke-order rules (文部科学省 standard), ending classification (止め/はね/はらい), overall assessment
- **Next iteration**: Add user proficiency level to prompt context so feedback scales with ability

## Claude vs Gemini Comparison

| Task | Claude | Gemini | Winner | Notes |
|------|--------|--------|--------|-------|
| Handwriting evaluation | Not used | 2.0 Flash | Gemini | Vision + structured output, good cost/speed |
| Code generation (app dev) | Opus 4.6 | — | Claude | Complex multi-file architecture |
| Prompt optimization | Good | — | TBD | Need to compare for study recommendation prompts |
| Real-time voice | N/A | Live API | Gemini | Only option for simultaneous vision+voice |

---

*Log started: 2026-03-17 | Version: 1.0.0*
