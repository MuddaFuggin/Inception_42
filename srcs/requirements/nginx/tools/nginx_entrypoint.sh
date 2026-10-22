#!/bin/sh

# Génération du certificat SSL auto-signé si absent
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42Paris/CN=${DOMAIN_NAME}"
fi

# Lancement de NGINX au premier plan (et pas en daemon : evite l'arret du PID (PID1))
exec nginx -g "daemon off;"