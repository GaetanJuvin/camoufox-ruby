# Changelog

## 0.5.0
- Add `user_data_dir` support to the synchronous Playwright bridge so Firefox can reuse persistent
  profiles via `launchPersistentContext`.

## 0.4.2
- Default the native stub's `executable_path` to `File.join(Camoufox::Pkgman.install_dir, "camoufox")`
  while still honoring kwargs or `CAMOUFOX_EXECUTABLE_PATH`, so Playwright can launch whichever
  Camoufox binary the gem installed.

## 0.4.0
- Rework the synchronous Playwright bridge to keep a persistent Firefox page session so multiple
  commands run against the same browser instance.
- Add `Camoufox::SyncAPI::Page#wait_for_selector` and expose live `title`/`content` reads through
  the new bridge.
- Allow the native stub to honor `executable_path` kwargs or `CAMOUFOX_EXECUTABLE_PATH` so the
  Playwright bridge can launch real binaries without patching the extension.

## 0.3.0
- Improve Playwright bridge: unwrap driver bundles that only expose `createPlaywright`/`default`
  exports so `Camoufox::SyncAPI` can always reach `playwright.firefox`.

## 0.2.0
- Fix native launch options so the provided `headless` flag is respected by Playwright.

## 0.1.0
- Initial Ruby bridge around the Camoufox Python package (legacy).
- Native rewrite in progress: mirror `pythonlib/camoufox` structure, remove the Ruby Playwright
  client dependency, provide stubbed launch options via C++, add an experimental server launcher, and
  reintroduce a `SyncAPI` helper that drives Playwright through a Node bridge.
