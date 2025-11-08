# Changelog

## 0.2.0
- Fix native launch options so the provided `headless` flag is respected by Playwright.

## 0.1.0
- Initial Ruby bridge around the Camoufox Python package (legacy).
- Native rewrite in progress: mirror `pythonlib/camoufox` structure, remove the Ruby Playwright
  client dependency, provide stubbed launch options via C++, add an experimental server launcher, and
  reintroduce a `SyncAPI` helper that drives Playwright through a Node bridge.
