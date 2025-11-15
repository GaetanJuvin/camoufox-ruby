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

        const userDataDir = options.userDataDir;
        if (userDataDir) {
          delete options.userDataDir;
          context = await browserType.launchPersistentContext(userDataDir, options);
          const pages = context.pages();
          page = pages.length ? pages[0] : await context.newPage();
        } else {
          browser = await browserType.launch(options);
          page = await browser.newPage();
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
