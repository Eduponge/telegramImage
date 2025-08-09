#!/bin/bash

LINK="${LINK}"
TOKEN="${API_KEY_TELEGRAM}"
CHAT_IDS=("${CHAT_ID}" "${CHAT_ID_EDU}" "${CHAT_ID_WELL}")
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.jpg"
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
  const url =
    process.env.LINK ||
    'https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9';

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  await page.setViewport({ width: 800, height: 600, deviceScaleFactor: 2 });

  await page.goto(url, { waitUntil: 'networkidle2' });

  // Aguarda seletor do Power BI ou espera extra, para evitar imagem branca
  try {
    await page.waitForSelector('.visual-container', { timeout: 60000 });
    await page.waitForTimeout(3000);
  } catch (e) {
    console.log('Aviso: seletor .visual-container não encontrado. Tentando screenshot mesmo assim.');
    await page.waitForTimeout(20000);
  }

  // Salva o screenshot em JPEG, qualidade máxima, com nome dinâmico
  await page.screenshot({ path: '${ARQUIVO}', type: 'jpeg', quality: 100 });

  await browser.close();
})();
EOF

# Faz o crop da imagem para 410x540 pixels a partir do ponto (190,0), qualidade máxima e nitidez extra
if [ -f "${ARQUIVO}" ]; then
  convert "${ARQUIVO}" -crop 410x540+190+0 -quality 100 -sharpen 0x1 "${ARQUIVO}"
else
  echo "[ERRO] Screenshot não criado. Abortando envio ao Telegram."
  exit 1
fi

for ID in "${CHAT_IDS[@]}"; do
  if [ -n "$ID" ]; then
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
  fi
done
