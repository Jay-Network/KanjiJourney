# KanjiJourney Ideas

Track improvement ideas. Version at log time from `VERSION` file.

| Status | Meaning |
|--------|---------|
| proposed | Idea logged, not yet reviewed |
| accepted | Jay approved for implementation |
| rejected | Not pursuing |
| implemented | Done (version noted) |

---

## IDEA-001: Cross Guide Lines for Writing Practice
- **Version at log**: 1.0.0
- **Status**: proposed
- **Severity**: minor
- **Source**: Jay via jworks:9 (2026-03-06) — reference tweet by @kenichiota0711
- **Description**: Add cross guide lines (十字) to the writing canvas for stroke positioning. The UX insight from @kenichiota0711's hiragana app: users only need a simple cross dividing the square into 4 quadrants so instructions like "draw dot in upper-right square" make sense. This is simpler than full grid lines.
- **Current state**: KanjiJourney's DrawingCanvas has no guide lines — just a blank canvas.
- **Reference**: https://x.com/kenichiota0711/status/2026619137636569286

## IDEA-002: Dakuten/Handakuten Kana Variants in Kana Writing Mode
- **Version at log**: 1.0.0
- **Status**: proposed
- **Severity**: minor
- **Source**: Jay via jworks:9 (2026-03-06) — UX feedback from @kenichiota0711's son
- **Description**: KanaWritingScreen should include dakuten (が、ざ、だ、ば) and handakuten (ぱ) variants, not just base kana. Also small kana (ゃゅょっ). Real users (kids) expect these as part of complete kana practice.
- **Current state**: Need to audit KanaWritingScreen for which kana sets are included.

## IDEA-003: Grade + Kanken Dual Taxonomy for Content Organization
- **Version at log**: 1.0.0
- **Status**: proposed
- **Severity**: minor
- **Source**: Jay via jworks:9 (2026-03-06) — reference by @mocchicc (CPO at StudyPocket.ai)
- **Description**: Organize kanji by both school grade (1-6年生) AND 漢検 (Kanken) level. @mocchicc's app covers all 2,136 常用漢字 with this dual taxonomy. KanjiJourney already has grade-based organization — adding Kanken level as a secondary axis could appeal to test-prep users.
- **Reference**: https://x.com/mocchicc/status/2028974872765055217
- **Current state**: KanjiJourney uses grade-level organization. Kanken mapping would need a data source.

## IDEA-004: Full 常用漢字 Coverage (2,136 kanji)
- **Version at log**: 1.0.0
- **Status**: proposed
- **Severity**: major
- **Source**: Jay via jworks:9 (2026-03-06) — inspired by @mocchicc's app
- **Description**: Ensure KanjiJourney covers all 2,136 常用漢字, not just Grade 1-6 (~1,026). The remaining ~1,110 are secondary school kanji used in daily life. @mocchicc's app covers the full set.
- **Current state**: Need to audit shared-japanese kanji data for total coverage.
