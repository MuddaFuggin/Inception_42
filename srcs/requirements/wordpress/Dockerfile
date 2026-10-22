FROM debian:bookworm

# Installation de PHP-FPM, des extensions nécessaires et de curl/mariadb-client
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-gd \
    php8.2-cli \
    php8.2-mbstring \
    curl \
	ca-certificates \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Téléchargement et installation de WP-CLI (outil en ligne de commande pour WordPress)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Création du dossier web et attribution des droits à l'utilisateur www-data
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# Copie de la configuration PHP-FPM personnalisée
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copie du script d'initialisation
COPY tools/wordpress_entrypoint.sh /usr/local/bin/wordpress_entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress_entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["wordpress_entrypoint.sh"]