FROM alpine:3.19

# Instala Node.js y npm
RUN apk add --no-cache nodejs npm

# Crea directorio de trabajo
WORKDIR /app

# Copia archivos de la app
COPY package.json ./
COPY server.js ./
COPY public/ ./public/

# Instala dependencias
RUN npm install

# Expone el puerto usado por Express
EXPOSE 7777

# Ejecuta el servidor
CMD ["node", "server.js"]
