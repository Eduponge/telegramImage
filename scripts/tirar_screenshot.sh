#!/bin/bash

LINK="https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9"
TOKEN="${API_KEY_TELEGRAM}"
CHAT_ID="${CHAT_ID}"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.png"

echo "Iniciando captura de tela..."

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
  echo "Erro: API_KEY_TELEGRAM (TOKEN) ou CHAT_ID não definidos como variáveis de ambiente."
  exit 1
fi

# Gera o screenshot com puppeteer
node <<EOF
const puppeteer = require('puppeteer');
(async () => {
  try {
    const browser = await puppeteer.launch({ args: ['--no-sandbox'], executablePath: 'chromium-browser' });
    const page = await browser.newPage();
    await page.goto("${LINK}", {waitUntil: 'networkidle2'});
    await page.screenshot({path: "${ARQUIVO}", fullPage: true});
    await browser.close();
    console.log("Screenshot gerado com sucesso.");
  } catch (e) {
    console.error("Erro ao gerar screenshot:", e);
    process.exit(1);
  }
})();
EOF

if [ ! -f "${ARQUIVO}" ]; then
  echo "Screenshot não criado. Abortando envio ao Telegram."
  exit 1
fi

echo "Enviando screenshot para o Telegram..."

RESP=$(curl -s -w "%{http_code}" -X POST "https://api.telegram.org/bot${TOKEN}/sendPhoto" \
  -F chat_id="${CHAT_ID}" \
  -F photo=@"${ARQUIVO}" \
  -F caption="Screenshot do Power BI em ${DATA}")

HTTP_CODE="${RESP: -3}"
if [ "$HTTP_CODE" != "200" ]; then
  echo "Falha ao enviar imagem ao Telegram. Código HTTP: $HTTP_CODE"
  exit 1
else
  echo "Imagem enviada com sucesso ao Telegram."
fi
