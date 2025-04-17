const puppeteer = require('puppeteer');
const fs = require('fs');

const url = process.env.SCRAPE_URL;

if (!url) {
  console.error('Error: SCRAPE_URL environment variable is not set.');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.goto(url);

  const title = await page.title();
  const heading = await page.$eval('h1', el => el.innerText).catch(() => 'No H1 found');

  const data = { title, heading };

  fs.writeFileSync('scraped_data.json', JSON.stringify(data, null, 2));

  await browser.close();
})();
