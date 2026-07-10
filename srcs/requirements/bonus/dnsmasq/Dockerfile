FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    dnsmasq \
    gettext \
    && rm -rf /var/lib/apt/lists/*

COPY conf/dnsmasq.conf.template /etc/dnsmasq/dnsmasq.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["dnsmasq", "-k", "--user=root"]