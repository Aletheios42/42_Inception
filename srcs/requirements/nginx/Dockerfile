FROM alpine:3.19

WORKDIR /app

RUN apk update && apk add nginx openssl netcat-openbsd curl gettext

COPY ./tools/script.sh /script.sh

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /script.sh

EXPOSE 443

CMD ["/script.sh"]
