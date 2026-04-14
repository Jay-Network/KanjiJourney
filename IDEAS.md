# KanjiJourney Ideas

Track improvement ideas. Version at log time from `VERSION` file.

| Status | Meaning |
|--------|---------|
| proposed | Idea logged, not yet reviewed |
| accepted | Jay approved for implementation |
| rejected | Not pursuing |
| implemented | Done (version noted) |

---

## Implemented
- ~~Glass UI port to iPad/iPhone~~ (GlassTheme.swift, v1.1.0, 2026-03-30)
- ~~More game modes on iPad~~ (Vocabulary, Kana, Radical, Writing, Flashcard all DONE)
- ~~Discovery overlay animation on iPad~~ (already implemented)

## IDEA-001: Cross Guide Lines for Writing Practice
- **Version at log**: 1.0.0
- **Status**: implemented (v1.1.3, 2026-04-13, Android)
- **Severity**: minor
- **Source**: Jay via jworks:9 (2026-03-06) — reference tweet by @kenichiota0711
- **Description**: Add cross guide lines (十字) to the writing canvas for stroke positioning. Simple cross dividing the square into 4 quadrants.
- **Implementation**: `drawCrossGuides()` in DrawingCanvas.kt — dashed gray at 25% alpha, under ghost strokes. iOS port still pending.

## IDEA-002: Dakuten/Handakuten Kana Variants in Kana Writing Mode
- **Version at log**: 1.0.0
- **Status**: implemented (v1.2.1, 2026-04-14, Android)
- **Severity**: minor
- **Source**: Jay via jworks:9 (2026-03-06) — UX feedback from @kenichiota0711's son
- **Description**: Include dakuten (が、ざ、だ、ば), handakuten (ぱ), and small kana (ゃゅょっ) in kana practice.
- **Implementation**: Data already existed (208 chars incl. 20 dakuten + 5 handakuten + 33 combos per type). Fixed KanaQuestionGenerator to use all-variant distractor pool and prefer same-variant distractors.

## IDEA-003: Grade + Kanken Dual Taxonomy
- **Version at log**: 1.0.0
- **Status**: proposed
- **Severity**: minor
- **Source**: Jay via jworks:9 (2026-03-06) — reference by @mocchicc (CPO at StudyPocket.ai)
- **Description**: Add 漢検 (Kanken) level as secondary axis alongside school grade.

## IDEA-004: Full 常用漢字 Coverage (2,136 kanji)
- **Version at log**: 1.0.0
- **Status**: proposed
- **Severity**: major
- **Source**: Jay via jworks:9 (2026-03-06) — inspired by @mocchicc's app
- **Description**: Cover all 2,136 常用漢字, not just Grade 1-6 (~1,026).

## IDEA-005: iPhone Finger Calligraphy
- **Version at log**: 1.1.0
- **Status**: proposed
- **Severity**: medium
- **Description**: Port calligraphy mode to iPhone with finger drawing (no Apple Pencil required).

## IDEA-006: Additional Candidates
- Cross-app deep link from KanjiSage scan results
- Leaderboard system for beta students
- JLPT-specific study plans (N5-N1)
- Offline mode improvements
- Gemini multi-turn AI conversation about stroke quality
- iPad split-view calligraphy (reference left, canvas right)
- Daily challenges with J Coin rewards
- Streak system UI with milestone animations
- Share progress cards (glass-styled social images)
- Sentence builder mode
- Custom flashcard deck creation/import (Anki format)
