FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-soap \
    php-xml \
    php-xmlrpc \
    php-zip \
    php-redis \
    mariadb-client \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup-wp.sh /usr/local/bin/setup-wp.sh
RUN chmod +x /usr/local/bin/setup-wp.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup-wp.sh"]
CMD ["/usr/sbin/php-fpm8.2", "-F"]