FROM alpine:3.19

RUN apk add --no-cache redis

COPY ./tools/redis.sh /tmp/redis.sh

EXPOSE 6379

CMD ["sh", "/tmp/redis.sh"]
