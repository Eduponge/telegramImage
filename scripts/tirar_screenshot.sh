#!/bin/bash
LINK="$1"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.png"

node - <<EOF
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({ args: ['--no-sandbox'], executablePath: 'chromium-browser' });
  const page = await browser.newPage();
  await page.goto("${LINK}", {waitUntil: 'networkidle2'});
  await page.screenshot({path: "${ARQUIVO}", fullPage: true});
  await browser.close();
})();
EOF
