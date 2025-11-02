// Adapted from the Camoufox Python implementation
// Launches the Playwright browser server by invoking the undocumented launchServer API.

const path = require('path');
const fs = require('fs');

function resolveBrowserServerImpl() {
  const cwd = process.cwd();
  const candidate = path.join(cwd, 'lib', 'browserServerImpl.js');
  try {
    // eslint-disable-next-line global-require, import/no-dynamic-require
    return require(candidate);
  } catch (error) {
    console.error('Unable to load Playwright browserServerImpl.js from', candidate);
    console.error('Set CAMOUFOX_PLAYWRIGHT_DRIVER_DIR to the Playwright driver directory.');
    process.exit(1);
  }
}

const { BrowserServerLauncherImpl } = resolveBrowserServerImpl();

function collectData() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');

    process.stdin.on('data', (chunk) => {
      data += chunk;
    });

    process.stdin.on('end', () => {
      const buffer = Buffer.from(data, 'base64');
      resolve(JSON.parse(buffer.toString()));
    });
  });
}

collectData()
  .then((options) => {
    if (options.executablePath && !fs.existsSync(options.executablePath)) {
      console.warn(`camoufox: executable ${options.executablePath} not found, falling back to Playwright default`);
      delete options.executablePath;
    }

    console.time('Server launched');
    console.info('Launching server...');

    const server = new BrowserServerLauncherImpl('firefox');

    server
      .launchServer(options)
      .then((browserServer) => {
        console.timeEnd('Server launched');
        console.log('Websocket endpoint:\x1b[93m', browserServer.wsEndpoint(), '\x1b[0m');
        process.stdin.resume();
      })
      .catch((error) => {
        console.error('Error launching server:', error.message);
        process.exit(1);
      });
  })
  .catch((error) => {
    console.error('Error collecting data:', error.message);
    process.exit(1);
  });
