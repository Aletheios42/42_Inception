FROM alpine:3.19

# Instala PHP y extensiones necesarias
RUN apk add --no-cache php php-pdo php-pdo_mysql php-session curl

# Crea el directorio web
WORKDIR /var/www/html

# Descarga Adminer
RUN curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o index.php

# Expone el puerto
EXPOSE 8080

# Lanza servidor PHP embebido
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
