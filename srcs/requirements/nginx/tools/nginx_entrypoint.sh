#!/bin/sh

# Génération of auto-signed SSL certificate if none is present
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42Paris/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
