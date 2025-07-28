const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  // URL do relatório Power BI
  const url = 'https://app.powerbi.com/view?r=eyJrIjoiY2Q3NDU0ZTYtNzBjNS00NzE5LTkzMzEtMGU3ODRhZDc4YjY5IiwidCI6ImQ4NDI2OWQ4LWMxNWUtNGRmMS1iOWRmLTBlNjAzMWMzZjc0YyJ9';

  // Acessa a página e espera carregar
  await page.goto(url, { waitUntil: 'networkidle2' });

  // Aguarda um tempo extra para garantir que os gráficos carreguem
  await page.waitForTimeout(15000);

  // Tira o screenshot
  await page.screenshot({ path: 'powerbi_screenshot.png', fullPage: true });

  await browser.close();
})();
