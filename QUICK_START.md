# Guia de Início Rápido

Este guia ajuda você a começar a usar o sistema de screenshots com Telegram e/ou WhatsApp.

## Pré-requisitos

- Node.js (v14 ou superior)
- Bash
- ImageMagick (para processamento de imagens)
- Chromium/Chrome (para Puppeteer)

## Instalação

### 1. Instalar dependências do sistema

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y chromium-browser imagemagick
```

**macOS:**
```bash
brew install chromium imagemagick
```

### 2. Instalar dependências do Node.js

**Apenas para Telegram (padrão):**
```bash
npm install
```

**Para Telegram + WhatsApp:**
```bash
npm install
npm install whatsapp-web.js qrcode-terminal
```

## Configuração

### Opção 1: Apenas Telegram (Recomendado)

1. **Criar um bot no Telegram:**
   - Abra o Telegram e busque por [@BotFather](https://t.me/botfather)
   - Envie `/newbot` e siga as instruções
   - Copie o token do bot (algo como: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

2. **Obter seu Chat ID:**
   - Busque por [@userinfobot](https://t.me/userinfobot) no Telegram
   - Envie `/start` e copie seu ID
   - Ou envie uma mensagem para seu bot e acesse:
     ```
     https://api.telegram.org/bot<SEU_TOKEN>/getUpdates
     ```

3. **Configurar variáveis de ambiente:**
   ```bash
   export API_KEY_TELEGRAM="123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
   export CHAT_ID="987654321"
   export LINK="https://app.powerbi.com/view?r=sua_url_aqui"
   ```

4. **Executar:**
   ```bash
   bash scripts/tirar_screenshot.sh
   ```

### Opção 2: Telegram + WhatsApp

1. **Configure o Telegram** (veja Opção 1)

2. **Configure o WhatsApp:**
   
   Você precisará do número de telefone no formato internacional com `@c.us`:
   - Brasil: `5511999999999@c.us` (55 = país, 11 = DDD, 999999999 = número)
   - Para grupos: termine com `@g.us`

3. **Configurar variáveis:**
   ```bash
   export API_KEY_TELEGRAM="seu_token_telegram"
   export CHAT_ID="seu_chat_id"
   export WHATSAPP_NUMBERS="5511999999999@c.us,5511888888888@c.us"
   export LINK="https://app.powerbi.com/view?r=sua_url_aqui"
   ```

4. **Primeira execução (autenticar WhatsApp):**
   ```bash
   bash scripts/enviar_ambos.sh
   ```
   
   - Um QR code aparecerá no terminal
   - Abra o WhatsApp no celular
   - Vá em Configurações > Aparelhos conectados
   - Escaneie o QR code
   - A sessão será salva para próximas execuções

### Opção 3: Apenas WhatsApp

Se você quiser usar apenas WhatsApp (sem Telegram):

```bash
# Não defina as variáveis do Telegram
unset API_KEY_TELEGRAM
unset CHAT_ID

# Configure apenas WhatsApp
export WHATSAPP_NUMBERS="5511999999999@c.us"
export LINK="https://app.powerbi.com/view?r=sua_url_aqui"

bash scripts/enviar_ambos.sh
```

## Uso

### Comando Básico

```bash
# Telegram (método original)
bash scripts/tirar_screenshot.sh

# Telegram + WhatsApp (método híbrido)
bash scripts/enviar_ambos.sh
```

### Com npm scripts

```bash
# Telegram
npm run screenshot

# Telegram + WhatsApp
npm run screenshot-ambos
```

### Enviar apenas para WhatsApp (sem capturar screenshot)

Se você já tem uma imagem:

```bash
export WHATSAPP_NUMBERS="5511999999999@c.us"
node scripts/enviar_whatsapp.js caminho/para/imagem.jpg
```

## Exemplos de Uso

### Exemplo 1: Envio diário via cron

Adicione ao seu crontab:

```bash
# Editar crontab
crontab -e

# Adicionar linha (exemplo: todo dia às 9h)
0 9 * * * cd /caminho/do/projeto && /bin/bash -c 'source ~/.bashrc && bash scripts/tirar_screenshot.sh'
```

### Exemplo 2: Múltiplos destinatários

```bash
# Múltiplos chats do Telegram
export CHAT_ID="111111111"
export CHAT_ID_EDU="222222222"
export CHAT_ID_WELL="333333333"
export CHAT_GROUP_ID="444444444"

# Múltiplos números do WhatsApp (separados por vírgula)
export WHATSAPP_NUMBERS="5511999999999@c.us,5521888888888@c.us,5531777777777@c.us"

bash scripts/enviar_ambos.sh
```

### Exemplo 3: URLs diferentes

```bash
# Dashboard 1
export LINK="https://app.powerbi.com/view?r=dashboard1"
bash scripts/tirar_screenshot.sh

# Dashboard 2
export LINK="https://app.powerbi.com/view?r=dashboard2"
bash scripts/tirar_screenshot.sh
```

## Resolução de Problemas

### Erro: "Browser not found"

```bash
# Instalar Chromium
sudo apt-get install chromium-browser

# Ou especificar caminho customizado
export CHROMIUM_PATH="/usr/bin/google-chrome"
```

### Erro: "convert: command not found"

```bash
# Instalar ImageMagick
sudo apt-get install imagemagick
```

### QR code do WhatsApp não aparece

1. Certifique-se de ter instalado as dependências:
   ```bash
   npm install whatsapp-web.js qrcode-terminal
   ```

2. Delete a sessão antiga:
   ```bash
   rm -rf .wwebjs_auth
   ```

3. Tente novamente

### WhatsApp desconecta frequentemente

- Mantenha o celular conectado à internet
- Não desconecte o WhatsApp Web manualmente no celular
- Use um servidor/computador sempre ligado para produção

### Imagem fica em branco

O script espera o carregamento do dashboard, mas se ainda assim ficar em branco:

1. Aumente o timeout no script (linha 39 do `tirar_screenshot.sh`):
   ```javascript
   await page.waitForTimeout(30000); // 30 segundos em vez de 3
   ```

2. Verifique se a URL do Power BI está acessível
3. Verifique se não há bloqueio por autenticação

## Automação com GitHub Actions

O repositório já inclui workflows do GitHub Actions para Telegram.

Para adicionar WhatsApp, você precisaria:

1. **Self-hosted runner**: GitHub Actions não suporta QR code interativo
2. **Servidor separado**: Configure um servidor que mantém a sessão do WhatsApp
3. **API intermediária**: Crie uma API que o GitHub Actions pode chamar

**Recomendação:** Para automação em nuvem, continue usando apenas Telegram.

## Segurança

### Protegendo Credenciais

**Nunca comite credenciais no Git!**

Use variáveis de ambiente ou arquivo `.env`:

```bash
# Criar arquivo .env
cat > .env << EOF
API_KEY_TELEGRAM=seu_token_aqui
CHAT_ID=seu_chat_id_aqui
WHATSAPP_NUMBERS=5511999999999@c.us
LINK=sua_url_aqui
EOF

# Carregar variáveis
source .env

# Adicionar ao .gitignore
echo ".env" >> .gitignore
```

### WhatsApp - Considerações de Segurança

- Use número secundário/teste
- Não compartilhe sessões do WhatsApp
- Monitore por avisos de banimento
- Respeite limites de taxa

## Próximos Passos

1. **Personalize as mensagens** editando os scripts
2. **Ajuste o crop da imagem** modificando os parâmetros do ImageMagick
3. **Adicione mais validações** conforme sua necessidade
4. **Configure backups** da pasta de autenticação do WhatsApp

## Suporte

- Para issues do Telegram Bot API: https://core.telegram.org/bots/api
- Para whatsapp-web.js: https://github.com/pedroslopez/whatsapp-web.js
- Para Puppeteer: https://pptr.dev/

## Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

- Reportar bugs
- Sugerir melhorias
- Enviar pull requests
- Compartilhar casos de uso

---

**Dica:** Comece apenas com o Telegram. É mais simples, confiável e perfeito para automação!
