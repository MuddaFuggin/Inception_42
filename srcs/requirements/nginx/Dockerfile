FROM alpine:3.18

RUN apk update && apk add --no-cache \
    nginx \
    openssl
    iproute2       # necessary for ss route testing in nginx, via `make check` `ports`

RUN mkdir -p /etc/nginx/ssl /run/nginx

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/nginx_entrypoint.sh /usr/local/bin/nginx_entrypoint.sh
RUN chmod +x /usr/local/bin/nginx_entrypoint.sh

EXPOSE 443

ENTRYPOINT ["nginx_entrypoint.sh"]
