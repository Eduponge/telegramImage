# Integração com WhatsApp - Guia Completo

## Visão Geral

Este guia explica como integrar o envio de screenshots via WhatsApp ao sistema existente de Telegram.

## ⚠️ Aviso Importante

O uso de bibliotecas não oficiais como `whatsapp-web.js` pode violar os Termos de Serviço do WhatsApp e resultar em banimento da conta. Use por sua conta e risco e considere:

- Usar um número secundário/de teste
- Não enviar spam ou mensagens em massa
- Respeitar limites de taxa de envio
- Monitorar avisos do WhatsApp

## Opções Disponíveis

### 1. whatsapp-web.js (Recomendado para uso pessoal/pequeno)

**Quando usar:**
- Projetos pessoais ou pequenas equipes
- Orçamento limitado
- Não precisa de suporte oficial
- Pode aceitar o risco de possível banimento

**Instalação:**

```bash
npm install whatsapp-web.js qrcode-terminal
```

**Configuração:**

O script `scripts/enviar_whatsapp.js` já está pronto para uso. Siga os passos:

1. Instale as dependências:
```bash
npm install
```

2. Configure os números de destino:
```bash
export WHATSAPP_NUMBERS="5511999999999@c.us,5511888888888@c.us"
```

**Formato do número:**
- Código do país (55 para Brasil)
- DDD (11 para São Paulo)
- Número do telefone (999999999)
- Sufixo @c.us para chats individuais
- Ou @g.us para grupos

3. Execute o script de teste:
```bash
node scripts/enviar_whatsapp.js screenshot_teste.jpg
```

4. Na primeira execução, escaneie o QR code com seu WhatsApp

**Integração com o workflow:**

Modifique `scripts/tirar_screenshot.sh` adicionando ao final:

```bash
# Após o envio ao Telegram
if [ -n "$WHATSAPP_NUMBERS" ]; then
  echo "[INFO] Enviando para WhatsApp..."
  node scripts/enviar_whatsapp.js "${ARQUIVO}"
fi
```

### 2. WhatsApp Business API (Para empresas)

**Quando usar:**
- Aplicações empresariais
- Necessita de solução oficial
- Volume alto de mensagens
- Pode investir financeiramente

**Custos:**
- Primeiras 1.000 conversas/mês: gratuitas
- Após isso: varia por país (Brasil: ~R$ 0,05-0,30 por conversa)

**Requisitos:**
- Conta Meta Business
- Número de telefone de negócio
- Aprovação da Meta
- Servidor para webhooks

**Implementação:**

1. Registre-se no [Meta for Developers](https://developers.facebook.com/)
2. Configure o WhatsApp Business API
3. Use a biblioteca oficial ou SDKs

```javascript
// Exemplo com WhatsApp Business API
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');

async function sendWhatsAppImage(phoneNumber, imagePath, caption) {
  const token = process.env.WHATSAPP_BUSINESS_TOKEN;
  const phoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  
  // 1. Upload da imagem
  const form = new FormData();
  form.append('messaging_product', 'whatsapp');
  form.append('file', fs.createReadStream(imagePath), {
    contentType: 'image/jpeg'
  });
  
  const uploadResponse = await axios.post(
    `https://graph.facebook.com/v18.0/${phoneNumberId}/media`,
    form,
    {
      headers: {
        ...form.getHeaders(),
        'Authorization': `Bearer ${token}`
      }
    }
  );
  
  const mediaId = uploadResponse.data.id;
  
  // 2. Enviar mensagem com imagem
  await axios.post(
    `https://graph.facebook.com/v18.0/${phoneNumberId}/messages`,
    {
      messaging_product: 'whatsapp',
      to: phoneNumber,
      type: 'image',
      image: {
        id: mediaId,
        caption: caption
      }
    },
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    }
  );
}
```

### 3. Baileys (Alternativa Avançada)

**Quando usar:**
- Necessita de controle total
- Conhecimento técnico avançado
- Aplicações mais complexas

**Instalação:**

```bash
npm install @whiskeysockets/baileys qrcode-terminal
```

**Exemplo básico:**

```javascript
const { default: makeWASocket, DisconnectReason, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const { Boom } = require('@hapi/boom');
const qrcode = require('qrcode-terminal');
const fs = require('fs');

async function connectWhatsApp() {
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  
  const sock = makeWASocket({
    auth: state,
    printQRInTerminal: true
  });
  
  sock.ev.on('creds.update', saveCreds);
  
  sock.ev.on('connection.update', async (update) => {
    const { connection, lastDisconnect, qr } = update;
    
    if (qr) {
      qrcode.generate(qr, { small: true });
    }
    
    if (connection === 'close') {
      const shouldReconnect = (lastDisconnect?.error instanceof Boom)
        ? lastDisconnect.error.output.statusCode !== DisconnectReason.loggedOut
        : true;
      
      if (shouldReconnect) {
        connectWhatsApp();
      }
    } else if (connection === 'open') {
      console.log('WhatsApp conectado!');
      
      // Enviar imagem
      const number = '5511999999999@s.whatsapp.net';
      const image = fs.readFileSync('./screenshot.jpg');
      
      await sock.sendMessage(number, {
        image: image,
        caption: 'Screenshot do Power BI'
      });
      
      console.log('Imagem enviada!');
    }
  });
}

connectWhatsApp();
```

### 4. Twilio API for WhatsApp (Sandbox)

**Quando usar:**
- Testes e desenvolvimento
- Prototipagem rápida
- Necessita de solução confiável

**Limitações:**
- Sandbox: apenas números pré-aprovados
- Produção: requer conta paga e templates aprovados

**Exemplo:**

```javascript
const twilio = require('twilio');
const fs = require('fs');

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const client = twilio(accountSid, authToken);

async function sendWhatsAppImage(to, imagePath, caption) {
  const message = await client.messages.create({
    from: 'whatsapp:+14155238886', // Número sandbox do Twilio
    to: `whatsapp:${to}`, // Ex: whatsapp:+5511999999999
    body: caption,
    mediaUrl: ['https://seu-servidor.com/screenshot.jpg'] // Precisa ser URL pública
  });
  
  console.log('Mensagem enviada:', message.sid);
}
```

## Comparação de Recursos

| Característica | whatsapp-web.js | Business API | Baileys | Twilio |
|---------------|----------------|--------------|---------|--------|
| **Custo** | Gratuito | Pago após limite | Gratuito | Pago |
| **Oficial** | ❌ | ✅ | ❌ | ✅ |
| **Fácil de usar** | ✅ | ⚠️ | ❌ | ✅ |
| **QR Code** | Sim | Não | Sim | Não |
| **Risco banimento** | Sim | Não | Sim | Não |
| **Webhooks** | Limitado | Sim | Sim | Sim |
| **Suporte** | Comunidade | Oficial | Comunidade | Oficial |

## Troubleshooting

### Erro: "Browser not found"

```bash
# Instalar dependências do Chromium
sudo apt-get install -y chromium-browser chromium-chromedriver
```

### QR Code não aparece

- Verifique se tem uma sessão anterior: delete a pasta `.wwebjs_auth`
- Tente executar com `NODE_OPTIONS=--max-old-space-size=4096`

### Erro de autenticação

- Delete a pasta de autenticação e tente novamente
- whatsapp-web.js: `.wwebjs_auth`
- Baileys: `auth_info_baileys`

### Mensagem não enviada

- Verifique o formato do número: deve incluir código do país
- Verifique se o número está registrado no WhatsApp
- Para grupos, use @g.us em vez de @c.us

## GitHub Actions Integration

Para integrar ao GitHub Actions, você precisará de um runner self-hosted, pois:

1. GitHub Actions não suporta interação com QR code
2. A sessão precisa persistir entre execuções

**Alternativa:** Use um servidor separado que:
- Mantém a sessão do WhatsApp ativa
- Expõe uma API para envio de mensagens
- É chamado pelo GitHub Actions via webhook

## Melhores Práticas

1. **Use número secundário**: Não use seu número pessoal principal
2. **Monitore limites**: Evite enviar muitas mensagens rapidamente
3. **Gerencie sessões**: Salve e restaure autenticação corretamente
4. **Tratamento de erros**: Sempre implemente retry logic
5. **Logs**: Mantenha logs detalhados para debug
6. **Backup**: Faça backup da pasta de autenticação

## Conclusão

Para este projeto específico (envio automatizado de screenshots):

**Recomendação:** Continue usando **Telegram**
- API gratuita e estável
- Sem risco de banimento
- Perfeito para automação

**Se precisar do WhatsApp:**
- Desenvolvimento/Pessoal: `whatsapp-web.js`
- Produção/Empresarial: WhatsApp Business API

## Recursos Adicionais

- [whatsapp-web.js Documentation](https://wwebjs.dev/)
- [WhatsApp Business API Docs](https://developers.facebook.com/docs/whatsapp)
- [Baileys GitHub](https://github.com/WhiskeySockets/Baileys)
- [Twilio WhatsApp API](https://www.twilio.com/docs/whatsapp)
