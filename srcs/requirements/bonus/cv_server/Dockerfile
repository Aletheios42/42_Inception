FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json ./
COPY server.js ./
COPY public/ ./public/

RUN npm install

EXPOSE 7777

CMD ["node", "server.js"]