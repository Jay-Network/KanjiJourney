# KanjiJourney Roadmap

Versioning: vMAJOR.MINOR.PATCH (v0=Alpha, v1=Beta, v2=Store)
Current: v1.0.0 (Beta)

---

## v1.1.0 — Glass UI Polish (Target: 2026-03-08)
### Android
- Glass theme across all remaining screens (game modes, settings, detail pages)
- DM Sans typography applied globally
- Animated transitions between screens (fade/slide with glass blur)
- Haptic feedback on glass card interactions
- Dark mode refinement (true OLED black backgrounds)
### iOS (iPad + iPhone)
- Port glass aesthetic to SwiftUI (frosted glass cards, dark backgrounds, orange accents)
- Calligraphy mode: add more kanji sets (Grade 1-2 full set, ~160 kanji)
- iPhone calligraphy support (finger drawing mode, no Apple Pencil)
- Mock home screen → real game mode cards with glass styling

## v1.2.0 — AI Dialog Vision (Target: 2026-03-22)
### Both Platforms
- **KanjiSage → KanjiJourney word transfer** (cross-app: scan in Sage, study in Journey)
  - *Depends on: jworks:43 (KanjiSage) implementing send-to-journey API*
- AI-powered study recommendations ("You're weak on Grade 3 radicals")
- Gemini-driven hint system in Recognition Mode (contextual clues)
- Writing Mode: AI explains stroke order mistakes conversationally
### iOS
- Calligraphy: multi-turn AI conversation about stroke quality (not just single feedback)
- iPad: split-view calligraphy (kanji reference left, canvas right)
- iOS feature parity: Vocabulary Mode, Kana modes, Radical modes

## v1.3.0 — Social & Engagement (Target: 2026-04-05)
- Daily challenges with J Coin rewards
- Streak system UI (7/30/90 day milestones with animations)
- Leaderboard (opt-in, anonymous by default)
- Share progress cards (glass-styled social images)
- Push notification reminders (configurable schedule)

## v1.4.0 — Advanced Study Tools (Target: 2026-04-19)
- Sentence builder mode (compose sentences using learned kanji)
- Kanji composition breakdown (radical → kanji → compound → sentence)
- JLPT-specific study tracks (N5 → N1 progression paths)
- Custom flashcard deck creation
- Import/export decks (CSV, Anki format)

## v1.5.0 — Professional Features (Target: 2026-05-03)
- Medical kanji module (common medical terms for interpreters)
- Legal kanji module (contract/court terminology)
- Business keigo practice mode
- Custom vocabulary lists by profession
- *Depends on: shared-japanese module updates (coordinate with jworks:47)*

## v2.0.0 — Store Release (Target: 2026-05-17)
### Android
- Google Play Store submission
- App Store screenshots and listing optimization
- Performance audit (startup time < 2s, smooth 60fps)
- Accessibility audit (TalkBack, font scaling, contrast)
### iOS
- App Store submission (iPad + iPhone as universal app)
- App Store screenshots (iPad Pro, iPhone 16 Pro)
- StoreKit 2 subscription integration (replace Stripe on iOS)
- App Review guidelines compliance
### Both Platforms
- Onboarding flow (placement test → personalized study plan)
- Privacy policy and terms of service
- Analytics integration (anonymized usage patterns)
- Crash reporting (Firebase Crashlytics or Sentry)

## v2.1.0 — Post-Launch (Target: 2026-06-01)
- Tablet layout optimization (foldable Z Flip, larger iPads)
- Widget for home screen (daily kanji, streak counter) — Android + iOS WidgetKit
- Offline-first sync improvements
- Community features (shared decks, user-contributed mnemonics)
- iPad: Sidecar / Stage Manager multitasking support
- iPad: Apple Pencil hover preview for kanji detail

---

## Cross-App Dependencies

| Feature | Depends On | Agent |
|---------|-----------|-------|
| Word transfer (Sage→Journey) | KanjiSage send-to-journey API | jworks:43 |
| Shared glass theme tokens | GlassBrand in shared design system | jworks:42 |
| J Coin cross-app earning | Unified API + DB migration | jworks:53 |
| iOS feature parity | KMP shared module changes | jworks:47 |
| iOS calligraphy → Android port | Calligraphy canvas abstraction | jworks:44 |
| EigoJourney word sharing | eq_received_words table | jworks:45 |
| iPad KanjiSage integration | Universal links / deep links | jworks:43 + jworks:62 |

---

## Brand Identity: Journey

KanjiJourney embodies the **mastery through exploration** concept:
- Home = base camp (progress overview)
- Games = training grounds (practice modes)
- Study = expedition planning (session configuration)
- Collection = trophy room (discovered kanji, achievements)

The glass aesthetic reinforces the premium, modern feel — dark backgrounds with warm orange accents suggesting adventure and discovery.
