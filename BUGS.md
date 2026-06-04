# KanjiJourney Bugs

## Open

- [ ] [BUG-001] APK size — debug 67MB, release estimated ~40-45MB (was 123MB)
  - **Severity**: Low (likely under 50MB target)
  - **Progress**: v1.2.5 — deleted db.bak (24MB), PNG→WebP (49MB→460KB), ABI filter, resource shrinking
  - **Estimate**: Release intermediates: DEX 9.6MB + resources 0.8MB + native libs 19.4MB (2 ABIs) + assets 24.5MB = ~54MB pre-compression → ~40-45MB in APK
  - **Blocked**: Release build fails on keystore password — Jay needs to fix local.properties signing config
## Resolved

- [x] [BUG-002] Camera Challenge AVFoundation preview — live camera + Vision OCR (v0.2.0, 2026-04-24, jworks:47)
- [x] [BUG-003] iPhone calligraphy mode excluded (Apple Pencil only) — fixed v0.2.0 (2026-04-24, jworks:47)
  - Velocity-based pressure simulation for finger input
  - Removed #if IPAD_TARGET compile gates from 5 files
