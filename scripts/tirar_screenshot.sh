#!/bin/bash

LINK="https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9"
TOKEN="${API_KEY_TELEGRAM}"
CHAT_ID="${CHAT_ID}"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.png"
CHROMIUM_PATH="${CHROMIUM_PATH:-/usr/bin/chromium-browser}"

echo "[INFO] Iniciando captura de tela..."

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
  echo "[ERRO] API_KEY_TELEGRAM (TOKEN) ou CHAT_ID não definidos como variáveis de ambiente."
  exit 1
fi

if ! command -v node > /dev/null; then
  echo "[ERRO] Node.js não encontrado. Instale antes de rodar o script."
  exit 1
fi

if ! command -v curl > /dev/null; then
  echo "[ERRO] curl não encontrado. Instale antes de rodar o script."
  exit 1
fi

if ! [ -x "$CHROMIUM_PATH" ]; then
  echo "[ERRO] Chromium não encontrado em $CHROMIUM_PATH."
  exit 1
fi

# Gera o screenshot com Puppeteer
node <<EOF
const puppeteer = require('puppeteer');
(async () => {
  try {
    const browser = await puppeteer.launch({ args: ['--no-sandbox'], executablePath: '${CHROMIUM_PATH}' });
    const page = await browser.newPage();
    await page.goto("${LINK}", {waitUntil: 'networkidle2'});
    await page.waitForTimeout(20000); // Aguarda 20 segundos para garantir o carregamento completo
    await page.screenshot({path: "${ARQUIVO}", fullPage: true});
    await browser.close();
    console.log("[INFO] Screenshot gerado com sucesso.");
  } catch (e) {
    console.error("[ERRO] ao gerar screenshot:", e);
    process.exit(1);
  }
})();
EOF

if [ ! -f "${ARQUIVO}" ]; then
  echo "[ERRO] Screenshot não criado. Abortando envio ao Telegram."
  exit 1
fi

echo "[INFO] Enviando screenshot para o Telegram..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.telegram.org/bot${TOKEN}/sendPhoto" \
  -F chat_id="${CHAT_ID}" \
  -F photo=@"${ARQUIVO}" \
  -F caption="Screenshot do Power BI em ${DATA}")

if [ "$HTTP_CODE" != "200" ]; then
  echo "[ERRO] Falha ao enviar imagem ao Telegram. Código HTTP: $HTTP_CODE"
  exit 1
else
  echo "[SUCESSO] Imagem enviada com sucesso ao Telegram."
fi
