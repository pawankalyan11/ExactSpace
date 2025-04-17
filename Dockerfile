# Stage 1 - Scraper
FROM node:18-slim AS scraper

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install dependencies
RUN apt-get update && apt-get install -y \
  chromium \
  fonts-liberation \
  libappindicator3-1 \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libcups2 \
  libdbus-1-3 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  xdg-utils \
  && rm -rf /var/lib/apt/lists/*

ENV CHROME_PATH=/usr/bin/chromium

WORKDIR /app

COPY package.json ./
RUN npm install
COPY scrape.js ./
# Scrape URL passed during build
ARG SCRAPE_URL
ENV SCRAPE_URL=${SCRAPE_URL}

RUN node scrape.js

# Stage 2 - Flask server
FROM python:3.10-slim

WORKDIR /app

COPY --from=scraper /app/scraped_data.json /app/
COPY server.py requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "server.py"]
