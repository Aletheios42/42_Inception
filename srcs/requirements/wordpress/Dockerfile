FROM alpine:3.19

# ---------------------------------------------
# Cómo verificar versiones disponibles:
# $ docker run -it alpine sh
# # apk update
# # apk search php
#
# En Alpine 3.19, la versión disponible es php82
# ---------------------------------------------
# Instalación de PHP 8.2 y módulos necesarios para WordPress y debugeo
# el flag --no-cache reduce el tamaño de la imagen

RUN apk add --no-cache \
    php82 php82-fpm php82-mysqli php82-curl php82-json php82-openssl \
    php82-session php82-ctype php82-dom php82-zip php82-mbstring \
    php82-phar php82-pdo php82-pdo_mysql php82-tokenizer \
    curl bash tar netcat-openbsd less \
    redis php-redis

# Crear alias para facilitar compatibilidad con scripts que esperan "php" y "/etc/php"
# ya que Alpine nombra los paquetes con versiones especificas y no genericas
RUN [ ! -e /usr/bin/php ] && ln -s /usr/bin/php82 /usr/bin/php || true \
 && [ ! -e /etc/php ] && ln -s /etc/php82 /etc/php || true

# Para evitar problemas de recursos limitados (un poco random)
RUN sed -i 's/^memory_limit = .*/memory_limit = 256M/' /etc/php82/php.ini

# ---------------------------------------------
# Descargar e instalar WordPress
# Versión específica para mayor control y reproducibilidad
# ---------------------------------------------
RUN curl -O https://wordpress.org/wordpress-6.4.2.tar.gz \
    && tar -xzf wordpress-6.4.2.tar.gz \
    && mkdir -p /var/www/html \
    && cp -r wordpress/* /var/www/html/ \
    && rm -rf wordpress wordpress-6.4.2.tar.gz \
    && chown -R nobody:nogroup /var/www/html \
    && chmod -R 755 /var/www/html

# Instalar WP-CLI para automatizar la instalación de WordPress
RUN curl -L -o wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v2.8.1/wp-cli-2.8.1.phar \
    || curl -L -o wp-cli.phar https://wordpress.org/cli-archive/wp-cli-2.8.1.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root || echo "WP-CLI verificación falló"

# Copiar script de inicialización y configuración base de WordPress
COPY ./tools/script.sh /
COPY ./tools/wp-config.php /

# Dar permisos de ejecución al script en el contenedor
RUN chmod +x /script.sh

# Exponer puerto PHP-FPM (documentativo, no obligatorio en Docker Compose)
EXPOSE 9000

# Comando por defecto: ejecutar el script de inicialización
CMD ["/script.sh"]
