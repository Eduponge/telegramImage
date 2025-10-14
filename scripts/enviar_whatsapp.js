const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const path = require('path');

// Números de WhatsApp para enviar (formato: 5511999999999@c.us)
const WHATSAPP_NUMBERS = process.env.WHATSAPP_NUMBERS 
  ? process.env.WHATSAPP_NUMBERS.split(',')
  : [];

const IMAGE_PATH = process.argv[2];

if (!IMAGE_PATH) {
  console.error('[ERRO] Caminho da imagem não fornecido');
  console.error('Uso: node enviar_whatsapp.js <caminho_da_imagem>');
  process.exit(1);
}

if (WHATSAPP_NUMBERS.length === 0) {
  console.log('[INFO] Nenhum número do WhatsApp configurado. Pulando envio.');
  console.log('[INFO] Configure a variável de ambiente WHATSAPP_NUMBERS');
  console.log('[INFO] Exemplo: export WHATSAPP_NUMBERS="5511999999999@c.us,5511888888888@c.us"');
  process.exit(0);
}

const client = new Client({
  authStrategy: new LocalAuth(),
  puppeteer: {
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  }
});

client.on('qr', (qr) => {
  console.log('[INFO] Escaneie o QR code com seu WhatsApp para autenticar:');
  qrcode.generate(qr, { small: true });
  console.log('[INFO] Aguardando escaneamento...');
});

client.on('authenticated', () => {
  console.log('[INFO] Autenticação bem-sucedida!');
});

client.on('ready', async () => {
  console.log('[INFO] WhatsApp conectado e pronto!');
  
  try {
    const media = MessageMedia.fromFilePath(IMAGE_PATH);
    const caption = `Screenshot do Power BI em ${new Date().toLocaleString('pt-BR', { 
      timeZone: 'America/Sao_Paulo' 
    })}`;
    
    for (const number of WHATSAPP_NUMBERS) {
      if (number.trim()) {
        console.log(`[INFO] Enviando para WhatsApp: ${number}`);
        try {
          await client.sendMessage(number.trim(), media, { caption });
          console.log(`[SUCESSO] Enviado para ${number}`);
        } catch (error) {
          console.error(`[ERRO] Falha ao enviar para ${number}:`, error.message);
        }
      }
    }
    
    console.log('[INFO] Finalizando cliente WhatsApp...');
    await client.destroy();
    process.exit(0);
  } catch (error) {
    console.error('[ERRO] Falha ao enviar:', error);
    await client.destroy();
    process.exit(1);
  }
});

client.on('auth_failure', (msg) => {
  console.error('[ERRO] Falha na autenticação do WhatsApp:', msg);
  process.exit(1);
});

client.on('disconnected', (reason) => {
  console.log('[INFO] WhatsApp desconectado:', reason);
});

console.log('[INFO] Inicializando cliente WhatsApp...');
console.log('[INFO] Números configurados:', WHATSAPP_NUMBERS.join(', '));
client.initialize();
