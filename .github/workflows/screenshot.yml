#!/bin/bash
LINK="https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.png"

# Usa variáveis de ambiente passadas pelo GitHub Actions
TOKEN="${API_KEY_TELEGRAM}"
CHAT_ID="${CHAT_ID}"

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
  echo "Erro: API_KEY_TELEGRAM (TOKEN) ou CHAT_ID não definidos como variáveis de ambiente."
  exit 1
fi

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
