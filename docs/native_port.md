# Camoufox Native Port Plan

This document tracks the work needed to replace the Python bridge with a native C++ implementation
that exposes the same surface area to the Ruby gem. The goal is to eventually match the behaviour of
the original Python package (`camoufox`) without shelling out to Python.

## Target surface area

The Ruby gem currently relies on the Python package for the following capabilities:

1. **Launch options** – `camoufox.launch_options` assembles the configuration blob passed to the
   Camoufox Firefox binary. This touches nearly every helper in `pythonlib/camoufox/utils.py`.
2. **Binary management** – `camoufox fetch/remove/path/version` download the Firefox bundle from
   GitHub releases, manage add-ons, fonts, and GeoIP data (`pkgman.py`, `addons.py`, `locale.py`).
3. **Warnings & validation** – type checking, config validation, leak warnings, logging.
4. **Virtual display and Playwright helpers** – optional Xvfb integration (Linux), environment
   variable setup for the executable, proxy/geolocation interactions.

## Major components to port

| Python module | Responsibility | Native port considerations |
| ------------- | -------------- | --------------------------- |
| `utils.py` | Fingerprint generation, fonts, WebGL spoofing, config assembly, env var packing | Requires BrowserForge fingerprints DB, WebGL dataset, numpy-like utilities, UA parsing |
| `fingerprints.py` | Integrates BrowserForge logic | Need a native fingerprint generator and data loader |
| `pkgman.py` | Download/validate Camoufox binaries from GitHub, version constraints | Re-implement HTTP client, ZIP handling, progress reporting |
| `addons.py` | Default addon management, path validation | Port addon discovery + download logic |
| `locale.py` | GeoIP integration, locale selection | Needs MMDB parsing or a replacement library |
| `webgl/` | Pre-generated WebGL fingerprints | Convert dataset to native-friendly format |
| `virtdisplay.py` | Manages Xvfb | Detect platform, spawn background process |
| `cli` commands | fetch/remove/test/version | Recreate CLI front-end in Ruby or C++ |

## Architectural direction

1. **C++ shared library (`libcamoufox_native`)**
   - Exposes a minimal API surface to Ruby (initially stubbed, later feature-complete).
   - Organised into modules mirroring the Python package (fingerprint, config, pkgman, addons, geo).
   - Uses modern C++ (C++20) with libraries for HTTP (e.g., libcurl), JSON (nlohmann/json), YAML
     (yaml-cpp), ZIP handling (libzip/minizip), and MMDB (libmaxminddb).

2. **Ruby extension**
   - Built via `extconf.rb` / `mkmf` (or CMake + rake) compiling against the shared library.
   - Provides Ruby-friendly wrappers around the C++ API (converts to/from `VALUE`).

3. **Data assets**
   - Ship fingerprint/WebGL datasets as JSON/YAML alongside the gem.
   - Provide tooling to update assets from upstream Camoufox/BrowserForge releases.

4. **CLI integration**
   - Re-implement the `camoufox` CLI commands purely in Ruby, calling into the native library for
     heavy work.
   - Provide an optional Node.js bridge for Playwright interactions while retaining the ability to
     talk directly to the Playwright driver (no Ruby gem dependency).

## Milestones

1. **Bootstrap**
   - Scaffold `ext/camoufox_native` with a shared library exposing `launch_options` (stubbed).
   - Replace `Camoufox::PythonBridge` with `Camoufox::NativeBridge` calling the extension.
   - Ensure existing specs pass using stubbed data.

2. **Binary manager parity**
   - Port GitHub release fetching + ZIP extraction.
   - Implement `fetch/remove/path/version` in C++.

3. **Fingerprint generation**
   - Port BrowserForge fingerprint logic (initially with static samples, then full generator).
   - Implement WebGL + fonts spoofing pipeline.

4. **Advanced features**
   - GeoIP integration, proxy warnings, virtual display support, leak warnings.

5. **Testing & QA**
   - Build parity test suite comparing native output with Python reference data.
   - Automate cross-platform builds.

## Immediate next steps

- Define the data model for fingerprints and decide how to ingest BrowserForge datasets natively.
- Choose third-party libraries (if any) for HTTP, ZIP, MMDB, JSON, and YAML handling; prototype
  minimal integrations.
- Design a stable C API surface for the C++ library so Ruby (and potentially other languages) can
  interact with it without tight coupling to implementation details.
- Expand the Node bridge to support more Playwright commands (multi-page workflows, screenshotting,
  etc.) once the native mapper delivers real launch data.

## Open questions

- How closely do we need to match BrowserForge’s fingerprint distribution? Reuse the dataset or
  re-implement the generation algorithm?
- Should the native component expose a stable C API (for reuse in other languages) or remain
  Ruby-specific for now?
- Packaging strategy for large assets (fonts, WebGL datasets) in a gem-friendly way.
- Publishing pipeline for https://github.com/GaetanJuvin/camoufox-ruby (tests, builds, release
  artifacts).

This document will evolve as the native implementation grows. Contributions welcome.
