#!/bin/bash

# Script que captura screenshot e envia para AMBOS Telegram e WhatsApp
# Uso: bash scripts/enviar_ambos.sh

LINK="${LINK}"
TOKEN="${API_KEY_TELEGRAM}"
CHAT_IDS=("${CHAT_ID}" "${CHAT_ID_EDU}" "${CHAT_ID_WELL}" "${CHAT_GROUP_ID}")
WHATSAPP_NUMBERS="${WHATSAPP_NUMBERS}"
DATA=$(date +%Y%m%d_%H%M%S)
ARQUIVO="screenshot_${DATA}.jpg"
CHROMIUM_PATH="${CHROMIUM_PATH:-/usr/bin/chromium-browser}"

echo "=================================="
echo "  Screenshot para Telegram + WhatsApp"
echo "=================================="
echo ""

echo "[INFO] Iniciando captura de tela..."

# Validação de configuração
if [ -z "$TOKEN" ] || ([ -z "${CHAT_IDS[0]}" ] && [ -z "${CHAT_IDS[1]}" ] && [ -z "${CHAT_IDS[2]}" ]); then
  echo "[AVISO] API_KEY_TELEGRAM ou CHAT_ID não configurados. Telegram será ignorado."
  TELEGRAM_ENABLED=false
else
  TELEGRAM_ENABLED=true
fi

if [ -z "$WHATSAPP_NUMBERS" ]; then
  echo "[AVISO] WHATSAPP_NUMBERS não configurado. WhatsApp será ignorado."
  WHATSAPP_ENABLED=false
else
  WHATSAPP_ENABLED=true
fi

if [ "$TELEGRAM_ENABLED" = false ] && [ "$WHATSAPP_ENABLED" = false ]; then
  echo "[ERRO] Nenhum destino configurado (Telegram ou WhatsApp)."
  exit 1
fi

# Gera o screenshot com Puppeteer
echo "[INFO] Capturando screenshot..."
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

if [ $? -ne 0 ]; then
  echo "[ERRO] Falha ao capturar screenshot."
  exit 1
fi

# Faz o crop da imagem para 840x1070 pixels a partir do ponto (380,0), qualidade máxima e nitidez extra
if [ -f "${ARQUIVO}" ]; then
  echo "[INFO] Processando imagem..."
  convert "${ARQUIVO}" -crop 840x1070+380+0 -quality 100 -sharpen 0x1 "${ARQUIVO}"
  echo "[SUCESSO] Screenshot criado: ${ARQUIVO}"
else
  echo "[ERRO] Screenshot não criado. Abortando."
  exit 1
fi

echo ""
echo "=================================="
echo "  Enviando para Telegram"
echo "=================================="

# Enviar para Telegram
if [ "$TELEGRAM_ENABLED" = true ]; then
  for ID in "${CHAT_IDS[@]}"; do
    if [ -n "$ID" ]; then
      echo "[INFO] Enviando para Telegram chat_id: $ID..."
      HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://api.telegram.org/bot${TOKEN}/sendPhoto" \
        -F chat_id="$ID" \
        -F photo=@"${ARQUIVO}" \
        -F caption="Screenshot do Power BI em ${DATA}")

      if [ "$HTTP_CODE" != "200" ]; then
        echo "[ERRO] Falha ao enviar ao Telegram. Código HTTP: $HTTP_CODE"
      else
        echo "[SUCESSO] ✓ Enviado com sucesso ao Telegram (chat_id: $ID)"
      fi
    fi
  done
else
  echo "[INFO] Telegram não configurado. Pulando..."
fi

echo ""
echo "=================================="
echo "  Enviando para WhatsApp"
echo "=================================="

# Enviar para WhatsApp
if [ "$WHATSAPP_ENABLED" = true ]; then
  echo "[INFO] Iniciando envio para WhatsApp..."
  echo "[INFO] Números configurados: $WHATSAPP_NUMBERS"
  node scripts/enviar_whatsapp.js "${ARQUIVO}"
  
  if [ $? -eq 0 ]; then
    echo "[SUCESSO] ✓ Processamento do WhatsApp concluído"
  else
    echo "[ERRO] Falha no envio ao WhatsApp"
  fi
else
  echo "[INFO] WhatsApp não configurado. Pulando..."
fi

echo ""
echo "=================================="
echo "  Conclusão"
echo "=================================="
echo "[INFO] Processo finalizado!"
echo "[INFO] Arquivo gerado: ${ARQUIVO}"
echo "=================================="
