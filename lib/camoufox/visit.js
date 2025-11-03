const path = require('path');
const fs = require('fs');

function readStdinAsBase64() {
  return new Promise((resolve, reject) => {
    const chunks = [];
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => chunks.push(chunk));
    process.stdin.on('end', () => resolve(chunks.join('')));
    process.stdin.on('error', (error) => reject(error));
  });
}

function loadPlaywright() {
  const override = process.env.CAMOUFOX_PLAYWRIGHT_JS_REQUIRE;
  if (override) {
    return require(override);
  }

  try {
    return require('playwright');
  } catch (error) {
    // fall through
  }

  const driverDir = process.env.CAMOUFOX_PLAYWRIGHT_DRIVER_DIR;
  if (driverDir) {
    try {
      return require(path.join(driverDir, 'package'));
    } catch (error) {
      // fall through
    }
  }

  console.error('Unable to require Playwright. Install the `playwright` npm package or set CAMOUFOX_PLAYWRIGHT_JS_REQUIRE.');
  process.exit(1);
}

async function main() {
  const payloadB64 = await readStdinAsBase64();
  const payload = JSON.parse(Buffer.from(payloadB64, 'base64').toString());
  const { options, url } = payload;

  if (options.executablePath && !fs.existsSync(options.executablePath)) {
    console.warn(`camoufox: executable ${options.executablePath} not found, falling back to Playwright default`);
    delete options.executablePath;
  }

  const playwright = loadPlaywright();
  const browserType = playwright.firefox;
  if (!browserType) {
    console.error('Playwright module does not expose `firefox`.');
    process.exit(1);
  }

  const browser = await browserType.launch(options);
  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  try {
    await page.waitForLoadState('networkidle', { timeout: 15000 });
  } catch (error) {
    console.warn(`camoufox: waitForLoadState(networkidle) warning: ${error.message || error}`);
  }

  const [title, content] = await Promise.all([
    page.title(),
    page.content(),
  ]);

  console.log(JSON.stringify({ title, content }));
  await browser.close();
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
