FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]