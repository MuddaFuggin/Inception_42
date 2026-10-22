#!/bin/bash
set -e

# Lecture des mots de passe depuis les secrets Docker
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_PASSWORD=$(cat /run/secrets/wp_password)

# Créer le dossier pour le socket PHP-FPM si besoin
mkdir -p /run/php

# Se placer dans le dossier racine du site web
cd /var/www/html

# Attendre que MariaDB soit prêt = FIX
echo "Attente de MariaDB (${WORDPRESS_DB_HOST})..."
while ! mariadb-admin ping -h"$(echo ${WORDPRESS_DB_HOST} | cut -d: -f1)" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    sleep 2
done

# Si WordPress n'est pas encore téléchargé/installé
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Téléchargement de WordPress..."
    wp core download --allow-root

    echo "Création du fichier wp-config.php..."
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}"

    echo "Installation de WordPress..."
    wp core install --allow-root \
        --url="${DOMAIN_NAME}" \
        --title="${SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    echo "Création d'un utilisateur supplémentaire..."
    wp user create --allow-root \
        "${WP_USER}" "${WP_EMAIL}" \
        --user_pass="${WP_PASSWORD}" \
        --role="author"
fi

# Lancer PHP-FPM au premier plan (pas de daemon) pour garder le conteneur actif
exec php-fpm8.2 -F