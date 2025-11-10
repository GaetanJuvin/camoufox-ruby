# Camoufox Ruby

Camoufox Ruby is a work-in-progress native port of the
[Camoufox](https://github.com/daijro/camoufox) toolkit. The project is undergoing a full rewrite to
mirror the package layout of the reference Python implementation (`pythonlib/camoufox`) while keeping
all logic inside the Ruby gem.

> **Status:** Everything is stubbed. The gem exposes the same module/file structure as the Python
> package, but most methods simply return placeholder data or emit warnings. Real fingerprint
> generation, binary management, networking, and Web API spoofing are still to come.

## Installation

Add the gem directly from the repository while the native rewrite is underway:

```ruby
gem "camoufox"
```

### Prerequisites

- Ruby ≥ 3.0 (development targets 3.4.2)
- Node.js and `npm` (required by Playwright)

### Install steps

```bash
git clone https://github.com/GaetanJuvin/camoufox-ruby.git
cd camoufox-ruby
bundle install
rake compile
npx install playwright
npx playwright install firefox
```

## Quick start

```ruby
require "camoufox"

driver_dir = ENV.fetch("CAMOUFOX_PLAYWRIGHT_DRIVER_DIR", File.expand_path("node_modules/playwright", __dir__))

Camoufox.configure do |config|
  config.playwright_driver_dir = driver_dir
  config.node_path = ENV["CAMOUFOX_NODE_PATH"] if ENV["CAMOUFOX_NODE_PATH"]
end

Camoufox::SyncAPI::Camoufox.open(headless: true) do |browser|
  page = browser.new_page
  page.goto("https://example.com")
  page.wait_for_selector('h1')
  puts page.title
  puts page.content.include?('Example Domain')
end
```

Behind the scenes the Ruby port encodes the Camoufox launch options, hands them to a small Node.js
bridge, and lets Playwright do the heavy lifting. You must supply a Playwright driver bundle or
installation so the Node script can `require('playwright')`.

The synchronous helper keeps a Firefox page alive for the lifetime of the Ruby object, so follow-up
calls like `wait_for_selector`, `content`, or `title` reuse the same DOM state without re-launching
the browser for every method.

### Launching the Playwright server (experimental)

To mirror the Python helper that spins up a Playwright websocket endpoint, the Ruby port can invoke
Playwright's Node driver directly (no `playwright-ruby-client` dependency). You must provide the
location of a Playwright driver bundle that contains `lib/browserServerImpl.js`.

```bash
export CAMOUFOX_PLAYWRIGHT_DRIVER_DIR=/path/to/playwright/driver/package
export CAMOUFOX_NODE_PATH=/path/to/node   # optional, defaults to `node`
bundle exec ruby run.rb server
```

The command prints the websocket endpoint and keeps the process alive, matching the Python
behaviour. Until the native mapper is complete, the underlying launch options remain stubbed.

## Module layout

The Ruby sources now mirror the structure of `pythonlib/camoufox`:

```
lib/camoufox/
├── __init__ (lib/camoufox.rb)
├── __main__.rb
├── __version__.rb
├── addons.rb
├── async_api.rb
├── browserforge.yml
├── exceptions.rb
├── fingerprints.rb
├── fonts.json
├── ip.rb
├── locale.rb
├── pkgman.rb
├── server.rb
├── sync_api.rb
├── utils.rb
├── virtdisplay.rb
├── warnings.rb
└── webgl/
```

Each file defines the corresponding Ruby module, currently implemented as lightweight stubs so that
call sites can be wired up without crashing.

## CLI

The `bin/camoufox` executable is available, but commands only return informative placeholder
messages until the native implementation lands.

```bash
camoufox version  # => "Camoufox native stub v0.0.1"
```

The repository also includes a helper script, `run.rb`, with convenience commands:

```bash
bundle exec ruby run.rb                     # show stub details and launch options
bundle exec ruby run.rb launch-options --locale en-US --headful
bundle exec ruby run.rb browse --url https://example.com
bundle exec ruby run.rb server

# or run the sample script directly
bundle exec ruby examples/sync_playwright.rb
```

## Configuration

`Camoufox.configure` exposes a tiny configuration object that is growing alongside the native port.
Today it supports the basic directories and the Playwright driver configuration:

```ruby
Camoufox.configure do |config|
  config.data_dir = "/tmp/camoufox-data"
  config.node_path = "/usr/local/bin/node"
  config.playwright_driver_dir = "/opt/playwright-driver/package"
end
```

Environment overrides:

- `CAMOUFOX_DATA_DIR` – override where Camoufox assets are stored (planned use)
- `CAMOUFOX_CACHE_DIR` – override the cache directory (planned use)
- `CAMOUFOX_EXECUTABLE_PATH` – path to the Camoufox Firefox binary returned by the native stub (defaults to `File.join(Camoufox::Pkgman.install_dir, "camoufox")`, but override it if you place the browser elsewhere)
- `CAMOUFOX_NODE_PATH` – path to the Node.js binary used when spawning the Playwright server (defaults to `node`)
- `CAMOUFOX_PLAYWRIGHT_DRIVER_DIR` – directory containing `lib/browserServerImpl.js` (defaults to `node_modules/playwright` if present)
- `CAMOUFOX_PLAYWRIGHT_JS_REQUIRE` – optional module identifier passed to Node's `require()` when
  running the synchronous Playwright bridge (defaults to `playwright`)

## Testing

Specs intentionally exercise only the pieces that exist today. Run them after compiling the native
extension:

```bash
~/.rbenv/versions/3.4.2/bin/ruby -S bundle exec rspec
```

## Contributing

See `docs/native_port.md` for the roadmap toward feature parity with the Python Camoufox package.

## License

MIT – see `LICENSE` for details.
