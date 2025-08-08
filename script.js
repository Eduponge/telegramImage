const puppeteer = require('puppeteer');
const sharp = require('sharp');

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

  // Salva o screenshot com nome fixo
  const screenshotPath = 'powerbi_screenshot.png';
  await page.screenshot({ path: screenshotPath, fullPage: true });

  await browser.close();

  // Crop para 600x374 a partir do canto superior esquerdo
  await sharp(screenshotPath)
    .extract({ width: 600, height: 374, left: 0, top: 0 })
    .toFile(screenshotPath);

  console.log('Screenshot capturado e CORTADO com sucesso!');
})();
