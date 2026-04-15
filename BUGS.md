# KanjiJourney Bugs

## Open

- [ ] [BUG-001] APK size — debug 67MB (was 123MB), release untested
  - **Severity**: Low (significantly reduced; release build with R8+ABI filter expected under 50MB)
  - **Progress**: v1.2.5 — deleted db.bak (24MB), PNG→WebP (49MB→460KB), ABI filter, resource shrinking
  - **Remaining**: Release build measurement needed to confirm under 50MB target
- [ ] [BUG-002] Camera Challenge: AVFoundation camera preview is a placeholder
  - **Severity**: Low (game logic works, just no live camera feed)
  - **Platform**: iOS only
- [ ] [BUG-003] iPhone calligraphy mode excluded (Apple Pencil only)
  - **Severity**: Medium (iPhone users can't access writing mode)
  - **Fix**: Implement finger drawing mode for iPhone

## Resolved

(None yet)
