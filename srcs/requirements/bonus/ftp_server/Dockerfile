FROM alpine:3.13

RUN apk update && apk upgrade && apk add --no-cache vsftpd bash openssl shadow

COPY conf/vsftpd.conf /tmp/vsftpd.conf

COPY tools/server_ftp.sh /tmp/server_ftp.sh
RUN chmod +x /tmp/server_ftp.sh

CMD ["sh", "/tmp/server_ftp.sh"]
