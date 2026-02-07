const path = require('path');
const fs = require('fs');
const readline = require('readline');

function withDefault(value, extractor) {
  if (!value) {
    return null;
  }

  try {
    return extractor(value);
  } catch (error) {
    console.warn(`camoufox: failed to initialize Playwright shim (${error.message || error})`);
    return null;
  }
}

function resolvePlaywrightApi(candidate) {
  if (!candidate) {
    return null;
  }

  if (candidate.firefox) {
    return candidate;
  }

  if (candidate.default) {
    const resolved = resolvePlaywrightApi(candidate.default);
    if (resolved) {
      return resolved;
    }
  }

  if (typeof candidate.createInProcessPlaywright === 'function') {
    const resolved = withDefault(candidate, (mod) => mod.createInProcessPlaywright());
    if (resolved) {
      return resolved;
    }
  }

  if (typeof candidate.createPlaywright === 'function') {
    const resolved = withDefault(candidate, (mod) => mod.createPlaywright({ sdkLanguage: process.env.PW_LANG_NAME || 'javascript' }));
    if (resolved && resolved.firefox) {
      return resolved;
    }
  }

  if (candidate.playwright) {
    return resolvePlaywrightApi(candidate.playwright);
  }

  return null;
}

function loadPlaywright() {
  const override = process.env.CAMOUFOX_PLAYWRIGHT_JS_REQUIRE;
  if (override) {
    // eslint-disable-next-line global-require, import/no-dynamic-require
    return require(override);
  }

  try {
    // eslint-disable-next-line global-require, import/no-dynamic-require
    return require('playwright');
  } catch (error) {
    // fall through
  }

  const driverDir = process.env.CAMOUFOX_PLAYWRIGHT_DRIVER_DIR;
  if (driverDir) {
    try {
      // eslint-disable-next-line global-require, import/no-dynamic-require
      return require(path.join(driverDir, 'package'));
    } catch (error) {
      // fall through
    }
  }

  console.error('Unable to require Playwright. Install the `playwright` npm package or set CAMOUFOX_PLAYWRIGHT_JS_REQUIRE.');
  process.exit(1);
}

function decodePayload(line) {
  const trimmed = (line || '').trim();
  if (!trimmed) {
    return null;
  }
  const buffer = Buffer.from(trimmed, 'base64');
  return JSON.parse(buffer.toString());
}

function encodePayload(message) {
  const json = JSON.stringify(message);
  return Buffer.from(json).toString('base64');
}

function writeMessage(message) {
  process.stdout.write(`${encodePayload(message)}\n`);
}

function coercePageFunction(expression) {
  const trimmed = (expression || '').trim();
  if (!trimmed) {
    return null;
  }
  try {
    const evaluated = eval(`(${trimmed})`); // eslint-disable-line no-eval
    if (typeof evaluated === 'function') {
      return evaluated;
    }
  } catch (error) {
    // fall through – treat expression as plain script
  }
  return null;
}

async function waitForNetworkIdle(page, timeout) {
  try {
    await page.waitForLoadState('networkidle', { timeout });
  } catch (error) {
    console.warn(`camoufox: waitForLoadState(networkidle) warning: ${error.message || error}`);
  }
}

async function run() {
  const rl = readline.createInterface({
    input: process.stdin,
    crlfDelay: Infinity,
    terminal: false,
  });

  let initialized = false;
  let browser;
  let context;
  let page;

  rl.on('line', async (line) => {
    try {
      if (!initialized) {
        const payload = decodePayload(line);
        if (!payload || !payload.options) {
          throw new Error('Missing launch options');
        }

        const options = payload.options;
        if (options.executablePath && !fs.existsSync(options.executablePath)) {
          delete options.executablePath;
        }

        const playwrightModule = loadPlaywright();
        const playwright = resolvePlaywrightApi(playwrightModule);
        const browserType = playwright && playwright.firefox;
        if (!browserType) {
          throw new Error('Playwright module does not expose `firefox` browser type');
        }

        const stealthScript = `
          // Hide webdriver flag
          Object.defineProperty(navigator, 'webdriver', { get: () => false });

          // Fake plugins array
          Object.defineProperty(navigator, 'plugins', {
            get: () => {
              const p = [
                { name: 'PDF Viewer', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
                { name: 'Chrome PDF Viewer', filename: 'internal-pdf-viewer', description: '' },
                { name: 'Chromium PDF Viewer', filename: 'internal-pdf-viewer', description: '' },
              ];
              p.length = 3;
              return p;
            },
          });

          // Hide Playwright-specific markers
          delete window.__playwright;
          delete window.__pw_manual;
          delete window.__PW_inspect;

          // Patch permissions API
          const origQuery = window.navigator.permissions.query.bind(window.navigator.permissions);
          window.navigator.permissions.query = (params) => {
            if (params.name === 'notifications') {
              return Promise.resolve({ state: Notification.permission });
            }
            return origQuery(params);
          };

          // Convincing toString for overridden getters
          const nativeToString = Function.prototype.toString;
          const overrides = new Map();
          function mockNative(fn, nativeName) {
            overrides.set(fn, 'function ' + nativeName + '() { [native code] }');
          }
          Function.prototype.toString = function () {
            if (overrides.has(this)) return overrides.get(this);
            return nativeToString.call(this);
          };
          mockNative(Function.prototype.toString, 'toString');
        `;

        const userDataDir = options.userDataDir;
        if (userDataDir) {
          delete options.userDataDir;
          context = await browserType.launchPersistentContext(userDataDir, options);
          await context.addInitScript(stealthScript);
          const pages = context.pages();
          page = pages.length ? pages[0] : await context.newPage();
        } else {
          browser = await browserType.launch(options);
          const ctx = browser.contexts()[0] || await browser.newContext();
          await ctx.addInitScript(stealthScript);
          page = ctx.pages()[0] || await ctx.newPage();
        }
        initialized = true;
        writeMessage({ event: 'ready' });
        return;
      }

      const payload = decodePayload(line);
      if (!payload || typeof payload !== 'object') {
        throw new Error('Invalid command payload');
      }

      const { id, action, params = {} } = payload;
      if (typeof id === 'undefined') {
        throw new Error('Command is missing id');
      }

      const respond = (body) => writeMessage({ id, ...body });

      try {
        let result;
        switch (action) {
          case 'goto': {
            const { url, waitUntil = 'domcontentloaded', waitForNetworkIdleTimeout = 15000 } = params;
            if (!url) {
              throw new Error('goto requires a url');
            }
            await page.goto(url, { waitUntil });
            await waitForNetworkIdle(page, waitForNetworkIdleTimeout);
            const [title, content] = await Promise.all([page.title(), page.content()]);
            result = { title, content };
            break;
          }
          case 'wait_for_selector': {
            const { selector, options = {} } = params;
            if (!selector) {
              throw new Error('wait_for_selector requires a selector');
            }
            const handle = await page.waitForSelector(selector, options);
            if (handle) {
              await handle.dispose();
            }
            result = { resolved: true };
            break;
          }
          case 'content': {
            const content = await page.content();
            result = { content };
            break;
          }
          case 'title': {
            const title = await page.title();
            result = { title };
            break;
          }
          case 'screenshot': {
            const { fullPage = false } = params;
            const buffer = await page.screenshot({ fullPage });
            const base64 = buffer.toString('base64');
            result = { data: base64 };
            break;
          }
          case 'evaluate': {
            const { expression, arg } = params;
            if (!expression || typeof expression !== 'string') {
              throw new Error('evaluate requires a string expression');
            }
            const pageFunction = coercePageFunction(expression);
            const target = pageFunction || expression;
            const value = arg !== undefined
              ? await page.evaluate(target, arg)
              : await page.evaluate(target);
            result = { value };
            break;
          }
          case 'close': {
            if (context) {
              await context.close();
              context = null;
            } else if (browser) {
              await browser.close();
              browser = null;
            }
            result = { closed: true };
            respond({ result });
            rl.close();
            return process.exit(0);
          }
          default:
            throw new Error(`Unknown action: ${action}`);
        }

        respond({ result });
      } catch (error) {
        respond({ error: { message: error.message || String(error), name: error.name } });
      }
    } catch (fatalError) {
      console.error(fatalError.message || fatalError);
      process.exit(1);
    }
  });

  rl.on('close', async () => {
    if (context) {
      try {
        await context.close();
      } catch (error) {
        // swallow
      }
    } else if (browser) {
      try {
        await browser.close();
      } catch (error) {
        // swallow
      }
    }
  });
}

run().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
