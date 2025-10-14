# FAQ - Perguntas Frequentes

## Sobre o Projeto

### O que este projeto faz?

Este projeto automatiza a captura de screenshots de dashboards do Power BI e envia para Telegram e/ou WhatsApp.

### Por que usar Telegram em vez de WhatsApp?

**Telegram é superior para automação por vários motivos:**

1. **✅ API Oficial e Gratuita**: O Telegram oferece uma API de bots completamente gratuita e ilimitada
2. **✅ Sem Risco de Banimento**: Usar bots é incentivado e oficial no Telegram
3. **✅ Fácil de Configurar**: Não precisa de QR code ou sessões complexas
4. **✅ Perfeito para CI/CD**: Funciona perfeitamente em GitHub Actions, servidores, etc.
5. **✅ Documentação Excelente**: A API é bem documentada e estável

**WhatsApp tem limitações para automação:**

1. **❌ Sem API Gratuita Oficial**: A API oficial é paga após um limite
2. **❌ Soluções Não Oficiais**: Bibliotecas como whatsapp-web.js violam termos de uso
3. **❌ Risco de Banimento**: Usar soluções não oficiais pode resultar em ban
4. **❌ Requer QR Code**: Precisa de interação manual na primeira vez
5. **❌ Difícil em CI/CD**: Não funciona bem em ambientes de integração contínua

## Telegram

### Como criar um bot do Telegram?

1. Abra o Telegram e busque por [@BotFather](https://t.me/botfather)
2. Envie o comando `/newbot`
3. Escolha um nome para o bot (ex: "Meu Bot de Screenshots")
4. Escolha um username (deve terminar com 'bot', ex: "meu_screenshot_bot")
5. Copie o token que o BotFather enviar (algo como: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### Como descobrir meu Chat ID?

**Método 1 - Usando um bot:**
1. Busque por [@userinfobot](https://t.me/userinfobot) no Telegram
2. Envie `/start`
3. O bot responderá com seu ID

**Método 2 - Via API:**
1. Envie uma mensagem qualquer para seu bot
2. Acesse no navegador:
   ```
   https://api.telegram.org/bot<SEU_TOKEN>/getUpdates
   ```
3. Procure por `"chat":{"id":123456789}`

**Método 3 - Para grupos:**
1. Adicione o bot ao grupo
2. Acesse:
   ```
   https://api.telegram.org/bot<SEU_TOKEN>/getUpdates
   ```
3. Procure por `"chat":{"id":-123456789}` (IDs de grupo são negativos)

### Posso enviar para múltiplos chats?

Sim! Configure múltiplas variáveis:

```bash
export CHAT_ID="111111111"
export CHAT_ID_EDU="222222222"
export CHAT_ID_WELL="333333333"
export CHAT_GROUP_ID="-444444444"  # Grupos têm IDs negativos
```

### O Telegram tem limites de envio?

O Telegram tem limites para evitar spam:
- **Mensagens**: 30 mensagens por segundo por bot
- **Grupos**: 20 mensagens por minuto para o mesmo grupo
- **Imagens**: Máximo de 10MB por arquivo

Para uso normal (alguns screenshots por dia), você nunca atingirá esses limites.

## WhatsApp

### Existe uma forma oficial gratuita de usar WhatsApp?

**Parcialmente**. A WhatsApp Business API oferece:
- ✅ Primeiras 1.000 conversas por mês: **gratuitas**
- ❌ Após 1.000: aproximadamente R$ 0,05 a R$ 0,30 por conversa (varia por país)
- ❌ Requer aprovação da Meta
- ❌ Processo de setup mais complexo

Para envio automatizado de poucos screenshots por dia, você provavelmente ficaria no plano gratuito.

### E as soluções não oficiais para WhatsApp?

Existem bibliotecas como `whatsapp-web.js` e `Baileys` que são **gratuitas**, mas:

**⚠️ AVISOS IMPORTANTES:**

1. **Violam os Termos de Uso**: O WhatsApp proíbe o uso de clientes não oficiais
2. **Risco de Banimento**: Sua conta pode ser banida permanentemente
3. **Sem Suporte Oficial**: Se der problema, você está por conta própria
4. **Instabilidade**: Podem parar de funcionar quando o WhatsApp atualizar

**Recomendações se for usar:**
- Use um número secundário/teste
- Não use para negócios críticos
- Esteja preparado para possível banimento
- Não envie spam ou mensagens em massa

### Como funciona o whatsapp-web.js?

O `whatsapp-web.js` funciona como o WhatsApp Web:

1. **Primeira Execução**:
   - Você executa o script
   - Um QR code aparece no terminal
   - Você escaneia com seu WhatsApp
   - A sessão é salva localmente

2. **Execuções Seguintes**:
   - O script usa a sessão salva
   - Não precisa escanear QR code novamente
   - Funciona como se o WhatsApp Web estivesse aberto

3. **Manutenção**:
   - A sessão pode expirar se ficar muito tempo sem usar
   - Você precisará escanear o QR code novamente
   - Mantenha a pasta `.wwebjs_auth` em backup

### Formato do número do WhatsApp

O número precisa estar no formato internacional com sufixo:

**Para contatos individuais:**
```
[código_país][DDD][número]@c.us
```

**Exemplos:**
- Brasil (São Paulo): `5511999999999@c.us`
- Brasil (Rio): `5521888888888@c.us`
- Portugal (Lisboa): `351211234567@c.us`

**Para grupos:**
```
[ID_do_grupo]@g.us
```

**Como descobrir o ID de um grupo:**
1. Envie uma mensagem no grupo enquanto o bot está conectado
2. Verifique os logs - o ID do grupo aparecerá

### Posso usar GitHub Actions com WhatsApp?

**Não diretamente**. O WhatsApp precisa de:
1. Interação manual (QR code)
2. Sessão persistente
3. Navegador rodando (para whatsapp-web.js)

**Soluções:**

1. **Self-Hosted Runner**: Configure um runner próprio
2. **Servidor Separado**: Mantenha um servidor com a sessão ativa que expõe uma API
3. **Continue com Telegram**: É a opção mais simples e confiável para CI/CD

## Técnicas

### Como alterar o tamanho do screenshot?

Edite o arquivo `scripts/tirar_screenshot.sh`:

```javascript
// Linha 32 - Viewport do navegador
await page.setViewport({ 
  width: 1920,  // Largura em pixels
  height: 1080, // Altura em pixels
  deviceScaleFactor: 2  // Resolução (2 = Retina/HiDPI)
});
```

```bash
# Linha 54 - Crop da imagem (ImageMagick)
convert "${ARQUIVO}" -crop [largura]x[altura]+[x]+[y] -quality 100 -sharpen 0x1 "${ARQUIVO}"
# Exemplo: -crop 840x1070+380+0
# 840x1070 = tamanho do recorte
# +380+0 = posição inicial (x=380, y=0)
```

### Como capturar a página inteira?

Modifique a linha do screenshot:

```javascript
// Captura completa da página
await page.screenshot({ 
  path: '${ARQUIVO}', 
  type: 'jpeg', 
  quality: 100,
  fullPage: true  // Adicione esta linha
});
```

E comente/remova a linha do crop no bash:

```bash
# convert "${ARQUIVO}" -crop 840x1070+380+0 -quality 100 -sharpen 0x1 "${ARQUIVO}"
```

### Como adicionar autenticação no Power BI?

Se o dashboard requer login, adicione no script:

```javascript
const page = await browser.newPage();

// Adicione credenciais antes do goto
await page.authenticate({
  username: process.env.POWERBI_USER,
  password: process.env.POWERBI_PASS
});

await page.goto(url, { waitUntil: 'networkidle2' });
```

### A imagem fica em branco, o que fazer?

**Problema comum**: O dashboard não carregou antes do screenshot.

**Soluções:**

1. **Aumentar o timeout**:
   ```javascript
   await page.waitForTimeout(30000); // 30 segundos
   ```

2. **Esperar por elemento específico**:
   ```javascript
   await page.waitForSelector('.seu-elemento', { timeout: 60000 });
   ```

3. **Scroll na página** (força carregamento):
   ```javascript
   await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
   await page.waitForTimeout(3000);
   await page.evaluate(() => window.scrollTo(0, 0));
   ```

### Como agendar execuções automáticas?

**Linux/macOS - Cron:**

```bash
# Editar crontab
crontab -e

# Adicionar linha
# Minuto Hora Dia Mês DiaDaSemana Comando
0 9 * * * cd /caminho/projeto && bash scripts/tirar_screenshot.sh

# Exemplos:
# Todo dia às 9h:        0 9 * * *
# A cada 3 horas:        0 */3 * * *
# Seg a Sex às 8h:       0 8 * * 1-5
# Todo dia 1 do mês:     0 9 1 * *
```

**GitHub Actions:**

Já está configurado! Veja `.github/workflows/`.

Para adicionar novos horários, crie um novo arquivo:

```yaml
name: Screenshot às 15h
on:
  schedule:
    - cron: '0 18 * * *'  # 18:00 UTC = 15:00 BRT
  workflow_dispatch:
# ... resto igual aos outros workflows
```

**Windows - Task Scheduler:**

1. Abra o Agendador de Tarefas
2. Criar Tarefa Básica
3. Configure o horário
4. Ação: "Iniciar um programa"
5. Programa: `bash.exe`
6. Argumentos: `/caminho/para/scripts/tirar_screenshot.sh`

## Erros Comuns

### "Browser not found" ou "Chromium not installed"

**Solução Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y chromium-browser
```

**Solução macOS:**
```bash
brew install chromium
```

**Ou especifique o caminho:**
```bash
export CHROMIUM_PATH="/usr/bin/google-chrome"
```

### "convert: command not found"

**ImageMagick não instalado.**

```bash
# Ubuntu/Debian
sudo apt-get install imagemagick

# macOS
brew install imagemagick
```

### "Error: Cannot find module 'puppeteer'"

**Dependências não instaladas.**

```bash
npm install
```

### WhatsApp desconecta sozinho

**Possíveis causas:**

1. **Celular sem internet**: Mantenha o celular online
2. **Sessão expirada**: Delete `.wwebjs_auth` e autentique novamente
3. **WhatsApp detectou uso não oficial**: Possível soft ban temporário
4. **Múltiplas sessões**: Não conecte o mesmo número em múltiplos lugares

### Telegram retorna erro 401 Unauthorized

**Token inválido ou incorreto.**

1. Verifique se copiou o token completo
2. Confirme com o @BotFather
3. Gere um novo token se necessário: `/token` para o @BotFather

### Telegram retorna erro 400 Bad Request: chat not found

**Chat ID incorreto.**

1. Verifique se o Chat ID está correto
2. Para grupos, certifique-se de que o bot foi adicionado
3. IDs de grupo são negativos: `-123456789`

## Segurança e Privacidade

### É seguro usar este código?

Sim, desde que:

1. **Não compartilhe seus tokens/credenciais**
2. **Use variáveis de ambiente, não hardcode**
3. **Adicione `.env` ao `.gitignore`**
4. **Use secrets no GitHub Actions**
5. **Mantenha dependências atualizadas**: `npm audit fix`

### Como proteger minhas credenciais?

**Nunca comite credenciais!**

```bash
# Use arquivo .env (já no .gitignore)
cat > .env << EOF
API_KEY_TELEGRAM=seu_token
CHAT_ID=seu_chat_id
EOF

# Carregue as variáveis
source .env

# Ou use um gerenciador de secrets como:
# - pass
# - 1Password CLI
# - AWS Secrets Manager
# - Azure Key Vault
```

### O WhatsApp pode ver minhas mensagens?

**Sim**, WhatsApp tem acesso às mensagens, mas elas são criptografadas ponta-a-ponta entre os dispositivos. O Meta (Facebook) pode ver:

- Metadados (quem enviou, quando, para quem)
- Não vê o conteúdo das mensagens (em teoria)

**Telegram:**
- Chats normais: criptografados no servidor
- Chats secretos: criptografados ponta-a-ponta
- Bots: mensagens não são criptografadas ponta-a-ponta

**Para screenshots do Power BI:**
- Se contêm dados sensíveis, considere usar Telegram Secret Chats
- Ou adicione senha/criptografia nas imagens
- Ou use um servidor privado

## Outros

### Posso contribuir com o projeto?

Sim! Contribuições são bem-vindas:

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça commit das mudanças
4. Envie um Pull Request

### Posso usar comercialmente?

Sim, o código é MIT License. Mas atenção:

- **Telegram Bot API**: Uso comercial permitido
- **WhatsApp**: Verifique os termos de uso
  - API Oficial: Sim, mas paga após limite
  - Soluções não oficiais: Não recomendado

### Quanto custa rodar isso?

**Completamente gratuito se usar apenas Telegram:**

- ✅ Telegram Bot API: Gratuito
- ✅ GitHub Actions: 2.000 minutos grátis/mês (plano free)
- ✅ Puppeteer: Gratuito
- ✅ ImageMagick: Gratuito

**Com WhatsApp:**

- ⚠️ whatsapp-web.js: Gratuito mas risco de ban
- 💰 WhatsApp Business API: Grátis até 1.000 conversas/mês

### Onde posso obter ajuda?

1. **Issues do GitHub**: Abra uma issue no repositório
2. **Documentação**:
   - [Telegram Bot API](https://core.telegram.org/bots/api)
   - [whatsapp-web.js](https://wwebjs.dev/)
   - [Puppeteer](https://pptr.dev/)
3. **Comunidades**:
   - Stack Overflow
   - Reddit r/Telegram
   - Grupos de desenvolvedores

---

**Ainda tem dúvidas?** Abra uma issue no GitHub!
