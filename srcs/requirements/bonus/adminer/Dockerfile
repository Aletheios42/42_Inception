FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-cli \
    php-mysqli \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer \
    && wget -q -O /var/www/adminer/index.php https://www.adminer.org/latest.php

EXPOSE 8080

WORKDIR /var/www/adminer

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]