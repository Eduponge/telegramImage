# telegramImage

## 📚 Índice de Documentação

**Comece aqui se está em dúvida:**
- 📊 **[COMPARACAO.md](COMPARACAO.md)** - Tabela comparativa rápida Telegram vs WhatsApp
- 📝 **[RESPOSTA_WHATSAPP.md](RESPOSTA_WHATSAPP.md)** - Resposta à pergunta sobre WhatsApp
- ⚡ **[QUICK_START.md](QUICK_START.md)** - Guia de início rápido

**Documentação detalhada:**
- ❓ **[FAQ.md](FAQ.md)** - Perguntas frequentes (em português)
- 💬 **[WHATSAPP_INTEGRATION.md](WHATSAPP_INTEGRATION.md)** - Guia técnico completo de WhatsApp

---

## Descrição

Este repositório automatiza a captura de screenshots de dashboards do Power BI e o envio para o Telegram usando a API de Bots do Telegram.

**💡 Novo:** Agora com suporte opcional para WhatsApp! Veja a [documentação](WHATSAPP_INTEGRATION.md) para mais detalhes.

## Como Funciona

1. **Captura de Tela**: Utiliza Puppeteer para capturar screenshots de dashboards do Power BI
2. **Processamento**: ImageMagick processa e recorta a imagem
3. **Envio**: A imagem é enviada para múltiplos chats do Telegram via Bot API

## Configuração

### Variáveis de Ambiente

- `API_KEY_TELEGRAM`: Token do seu bot do Telegram
- `CHAT_ID`, `CHAT_ID_EDU`, `CHAT_ID_WELL`, `CHAT_GROUP_ID`: IDs dos chats de destino
- `LINK`: URL do dashboard do Power BI
- `CHROMIUM_PATH`: Caminho do executável do Chromium (opcional)

### Instalação

```bash
npm install
chmod +x scripts/tirar_screenshot.sh
```

### Execução Local

```bash
export API_KEY_TELEGRAM="seu_token_aqui"
export CHAT_ID="seu_chat_id_aqui"
export LINK="url_do_powerbi_aqui"
bash scripts/tirar_screenshot.sh
```

## Integração com WhatsApp

### Existe algum método gratuito de fazer isso pelo WhatsApp?

Sim, existem algumas opções gratuitas para enviar screenshots via WhatsApp, cada uma com suas limitações:

### 1. **WhatsApp Business API (Oficial) - Limitado**

A Meta oferece a WhatsApp Business API, mas tem limitações:

**Prós:**
- Solução oficial da Meta
- Confiável e estável
- Boa para empresas médias/grandes

**Contras:**
- ❌ **Não é totalmente gratuito**: Há custos por conversação após um limite gratuito
- ❌ Requer aprovação da Meta
- ❌ Processo de setup mais complexo
- ❌ Necessita de um número de telefone de negócio verificado

### 2. **whatsapp-web.js (Gratuito e Recomendado)**

A biblioteca `whatsapp-web.js` é a melhor opção gratuita. Ela conecta via WhatsApp Web.

**Prós:**
- ✅ Completamente gratuito
- ✅ Fácil de implementar
- ✅ Não requer aprovação da Meta
- ✅ Suporta envio de imagens, documentos, etc.

**Contras:**
- ⚠️ Requer manter uma sessão ativa (como WhatsApp Web)
- ⚠️ Precisa escanear QR code na primeira vez
- ⚠️ Contra os termos de uso do WhatsApp (risco de banimento)

**Exemplo de Implementação:**

```javascript
// Instalar: npm install whatsapp-web.js qrcode-terminal

const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const fs = require('fs');

const client = new Client({
    authStrategy: new LocalAuth()
});

client.on('qr', (qr) => {
    // Gera QR code no terminal para autenticação
    qrcode.generate(qr, { small: true });
    console.log('[INFO] Escaneie o QR code com seu WhatsApp');
});

client.on('ready', async () => {
    console.log('[INFO] WhatsApp conectado e pronto!');
    
    // Número no formato: 5511999999999@c.us (país + DDD + número)
    const chatId = '5511999999999@c.us';
    
    // Carregar a imagem
    const media = MessageMedia.fromFilePath('./screenshot.jpg');
    
    // Enviar com legenda
    await client.sendMessage(chatId, media, {
        caption: 'Screenshot do Power BI em ' + new Date().toLocaleString()
    });
    
    console.log('[SUCESSO] Screenshot enviado via WhatsApp!');
});

client.initialize();
```

### 3. **Baileys (Alternativa Avançada)**

Biblioteca TypeScript para WhatsApp Multi-Device.

**Prós:**
- ✅ Gratuito
- ✅ Suporta multi-dispositivo
- ✅ Não requer navegador/Puppeteer

**Contras:**
- ⚠️ Mais complexo de configurar
- ⚠️ Contra os termos de uso do WhatsApp
- ⚠️ Requer gerenciamento de sessão

### 4. **Twilio API for WhatsApp (Sandbox Gratuito)**

**Prós:**
- ✅ Sandbox gratuito para testes
- ✅ Oficial e confiável
- ✅ Boa documentação

**Contras:**
- ❌ Sandbox tem limitações (apenas números pré-aprovados)
- ❌ Produção requer conta paga
- ❌ Necessita aprovação para templates de mensagem

## Comparação: Telegram vs WhatsApp

| Característica | Telegram Bot API | WhatsApp |
|---------------|------------------|----------|
| **Gratuito** | ✅ Sim, sempre | ⚠️ Limitado |
| **Fácil de usar** | ✅ Muito simples | ⚠️ Mais complexo |
| **Oficial** | ✅ API oficial | ⚠️ Depende do método |
| **Sem limites** | ✅ Sem custo por mensagem | ❌ Limites na API oficial |
| **Requer aprovação** | ❌ Não | ✅ Sim (API oficial) |
| **Risco de banimento** | ❌ Não | ⚠️ Sim (soluções não oficiais) |
| **Ideal para automação** | ✅ Excelente | ⚠️ Complicado |

## Recomendação

**Para casos de uso como este (envio automatizado de screenshots):**

1. **Continue usando Telegram**: É a melhor opção para automação
   - API gratuita e ilimitada
   - Sem risco de banimento
   - Fácil de implementar
   - Perfeito para bots

2. **Use WhatsApp apenas se necessário**: Se você realmente precisa do WhatsApp, use `whatsapp-web.js`
   - Entenda os riscos (possível banimento)
   - Mantenha uma sessão estável
   - Considere usar um número secundário

3. **Solução Híbrida**: Envie para ambos
   - Telegram para automação confiável
   - WhatsApp para usuários que preferem essa plataforma

## Adicionando Suporte para WhatsApp

Se você quiser adicionar suporte ao WhatsApp mantendo o Telegram, aqui está um exemplo:

### Instalação de Dependências

```bash
npm install whatsapp-web.js qrcode-terminal
```

### Script de Envio Híbrido

Crie `scripts/enviar_whatsapp.js`:

```javascript
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
  process.exit(1);
}

if (WHATSAPP_NUMBERS.length === 0) {
  console.log('[INFO] Nenhum número do WhatsApp configurado. Pulando envio.');
  process.exit(0);
}

const client = new Client({
  authStrategy: new LocalAuth(),
  puppeteer: {
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  }
});

client.on('qr', (qr) => {
  console.log('[INFO] Escaneie o QR code para autenticar:');
  qrcode.generate(qr, { small: true });
});

client.on('ready', async () => {
  console.log('[INFO] WhatsApp conectado!');
  
  try {
    const media = MessageMedia.fromFilePath(IMAGE_PATH);
    const caption = `Screenshot do Power BI em ${new Date().toLocaleString('pt-BR')}`;
    
    for (const number of WHATSAPP_NUMBERS) {
      if (number) {
        console.log(`[INFO] Enviando para WhatsApp: ${number}`);
        await client.sendMessage(number, media, { caption });
        console.log(`[SUCESSO] Enviado para ${number}`);
      }
    }
    
    await client.destroy();
    process.exit(0);
  } catch (error) {
    console.error('[ERRO] Falha ao enviar:', error);
    process.exit(1);
  }
});

client.on('auth_failure', () => {
  console.error('[ERRO] Falha na autenticação do WhatsApp');
  process.exit(1);
});

console.log('[INFO] Inicializando cliente WhatsApp...');
client.initialize();
```

### Atualizar o Script Principal

Modifique `scripts/tirar_screenshot.sh` para incluir o envio ao WhatsApp ao final:

```bash
# Após o loop de envio ao Telegram, adicione:

# Enviar para WhatsApp se configurado
if [ -n "$WHATSAPP_NUMBERS" ]; then
  echo "[INFO] Enviando para WhatsApp..."
  node scripts/enviar_whatsapp.js "${ARQUIVO}"
fi
```

### Configuração de Variáveis

Adicione aos secrets do GitHub Actions:

```yaml
env:
  WHATSAPP_NUMBERS: "5511999999999@c.us,5511888888888@c.us"
```

## Licença

MIT

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.