# Camoufox Ruby

Ruby port of the [Camoufox](https://github.com/daijro/camoufox) stealth browser toolkit. Launches a fingerprint-spoofed Firefox via Playwright with OS-aware screen, GPU, font, and header profiles.

## Installation

```ruby
gem "camoufox"
```

### Prerequisites

- Ruby >= 3.0
- Node.js and `npm`

### Setup

```bash
git clone https://github.com/GaetanJuvin/camoufox-ruby.git
cd camoufox-ruby
bundle install
rake compile
npx playwright install firefox
```

The Camoufox binary is downloaded automatically on first launch. To install it ahead of time:

```bash
bundle exec ruby -e 'require "camoufox"; Camoufox::Pkgman.install'
```

## Quick start

```ruby
require "camoufox"

Camoufox::SyncAPI::Camoufox.open(headless: false) do |browser|
  page = browser.new_page
  page.goto("https://example.com")
  puts page.title
end
```

### Launch options

```ruby
Camoufox::SyncAPI::Camoufox.open(
  headless: true,
  os: :windows,                # Spoof fingerprint for windows, linux, or macos
  locale: "fr-FR",             # Browser locale
  proxy: { server: "http://proxy:8080", username: "user", password: "pass" },
  geoip: true,                 # Match timezone/geolocation to proxy IP
  block_webrtc: true,          # Prevent WebRTC IP leaks
  block_webgl: true,           # Disable WebGL fingerprinting
  block_images: true,          # Block image loading
  enable_cache: true,          # Enable disk/memory cache
  user_data_dir: "/tmp/profile", # Persistent Firefox profile
  addons: ["/path/to/addon"],  # Load Firefox addons
  firefox_user_prefs: {        # Custom Firefox preferences
    "dom.webnotifications.enabled" => false,
  },
) do |browser|
  page = browser.new_page
  page.goto("https://browserleaks.com/javascript")
  puts page.evaluate("() => navigator.userAgent")
end
```

### Evaluate JavaScript

```ruby
page.evaluate("() => ({ href: window.location.href, title: document.title })")
page.evaluate("(a, b) => a + b", 1, 2)
```

### Persistent profiles

Pass `user_data_dir` to reuse cookies, history, and session data between runs:

```ruby
Camoufox::SyncAPI::Camoufox.open(user_data_dir: "/tmp/camoufox-profile") do |browser|
  page = browser.new_page
  page.goto("https://example.com")
end
```

## MCP server (Claude Code integration)

Camoufox ships with an MCP server that lets Claude Code control a stealth browser directly.

### Setup

Create a `.mcp.json` file in your project root:

```json
{
  "mcpServers": {
    "camoufox": {
      "command": "/path/to/camoufox-ruby/bin/camoufox-mcp-wrapper",
      "args": []
    }
  }
}
```

Or if you have the gem in your bundle, create a wrapper script:

```bash
#!/usr/bin/env bash
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
cd /path/to/camoufox-ruby
exec bundle exec ruby bin/camoufox-mcp
```

Then point `.mcp.json` at that wrapper.

### Restart Claude Code

MCP servers are loaded at session start. After creating `.mcp.json`, restart your Claude Code session.

### Available MCP tools

| Tool | Description |
|------|-------------|
| `camoufox_launch` | Launch browser with fingerprint spoofing, proxy, locale, OS options |
| `camoufox_goto` | Navigate to a URL |
| `camoufox_get_content` | Get page HTML |
| `camoufox_get_title` | Get page title |
| `camoufox_evaluate` | Execute JavaScript |
| `camoufox_wait_for_selector` | Wait for a CSS selector |
| `camoufox_screenshot` | Take a screenshot |
| `camoufox_close` | Close the browser |

## Environment variables

| Variable | Description |
|----------|-------------|
| `CAMOUFOX_EXECUTABLE_PATH` | Override path to the Camoufox Firefox binary |
| `CAMOUFOX_CACHE_DIR` | Override the binary install/cache directory |
| `CAMOUFOX_NODE_PATH` | Path to Node.js binary (defaults to `node`) |
| `CAMOUFOX_PLAYWRIGHT_DRIVER_DIR` | Playwright driver directory |

## Testing

```bash
bundle exec rspec
```

## License

MIT
