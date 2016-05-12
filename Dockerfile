FROM alpine:3.2

RUN apk add --update bash nginx && rm -rf /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
