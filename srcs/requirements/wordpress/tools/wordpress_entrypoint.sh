#!/bin/bash
set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_PASSWORD=$(cat /run/secrets/wp_password)

mkdir -p /run/php

cd /var/www/html


echo "Waiting for MariaDb... (${WORDPRESS_DB_HOST})..."
while ! mariadb-admin ping -h"$(echo ${WORDPRESS_DB_HOST} | cut -d: -f1)" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    sleep 2
done

# if wordpress is not installed yet :
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Creation of file wp-config.php..."
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}"

    echo "Installation of WordPress..."
    wp core install --allow-root \
        --url="${DOMAIN_NAME}" \
        --title="${SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

 # NAT redirection
    wp config set WP_HOME "https://${DOMAIN_NAME}:4443" --allow-root
    wp config set WP_SITEURL "https://${DOMAIN_NAME}:4443" --allow-root

    echo "Creating one more user..."
    wp user create --allow-root \
        "${WP_USER}" "${WP_EMAIL}" \
        --user_pass="${WP_PASSWORD}" \
        --role="author"
fi

# keep container alive (no daemon)
exec php-fpm8.2 -F
