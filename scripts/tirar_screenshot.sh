#!/bin/bash
LINK="https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9"
TOKEN="7924491565:AAE9HMizTz08P20par9Ij0Gw-7pXVBdb1Xs"
CHAT_ID="7925545189"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.png"

# Gera o screenshot com puppeteer
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

# Envia screenshot para o Telegram
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendPhoto" \
  -F chat_id="${CHAT_ID}" \
  -F photo=@"${ARQUIVO}" \
  -F caption="Screenshot do Power BI em ${DATA}"
