const puppeteer = require('puppeteer');

(async () => {
  // Recebe o link via variável de ambiente LINK, ou usa um padrão se não definido
  const url =
    process.env.LINK ||
    'https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9';

  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto(url, { waitUntil: 'networkidle2' });

  // Aguarda um tempo extra para garantir que os gráficos carreguem (20 segundos)
  await page.waitForTimeout(20000);

  // Salva o screenshot com nome fixo (pode ser alterado para dinâmico se quiser)
  await page.screenshot({ path: 'powerbi_screenshot.png', fullPage: true });

  await browser.close();
})();
