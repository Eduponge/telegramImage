#!/bin/bash

LINK="${LINK}"
TOKEN="${API_KEY_TELEGRAM}"
CHAT_IDS=("${CHAT_ID}" "${CHAT_ID_EDU}" "${CHAT_ID_WELL}")
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.png"
CHROMIUM_PATH="${CHROMIUM_PATH:-/usr/bin/chromium-browser}"

echo "[INFO] Iniciando captura de tela..."

if [ -z "$TOKEN" ] || ([ -z "${CHAT_IDS[0]}" ] && [ -z "${CHAT_IDS[1]}" ] && [ -z "${CHAT_IDS[2]}" ]); then
  echo "[ERRO] API_KEY_TELEGRAM (TOKEN) ou nenhum CHAT_ID definido como variável de ambiente."
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
    await page.waitForTimeout(20000);
    await page.screenshot({path: "${ARQUIVO}", fullPage: true});
    await browser.close();
    console.log("[INFO] Screenshot gerado com sucesso.");
  } catch (e) {
    console.error("[ERRO] ao gerar screenshot:", e);
    process.exit(1);
  }
})();
EOF

# NOVO: Faz o crop da imagem para 600x374 pixels a partir do canto superior esquerdo
convert "${ARQUIVO}" -crop 600x374+0+0 "${ARQUIVO}"

if [ ! -f "${ARQUIVO}" ]; then
  echo "[ERRO] Screenshot não criado. Abortando envio ao Telegram."
  exit 1
fi

for ID in "${CHAT_IDS[@]}"; do
  echo "[INFO] Enviando screenshot para o Telegram chat_id: $ID..."
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.telegram.org/bot${TOKEN}/sendPhoto" \
    -F chat_id="$ID" \
    -F photo=@"${ARQUIVO}" \
    -F caption="Screenshot do Power BI em ${DATA}")

  if [ "$HTTP_CODE" != "200" ]; then
    echo "[ERRO] Falha ao enviar imagem ao Telegram. Código HTTP: $HTTP_CODE"
  else
    echo "[SUCESSO] Imagem enviada com sucesso ao Telegram para chat_id $ID."
  fi
done
