FROM debian:bookworm

# Installation of PHP-FPM, all mandatory extensions and curl/mariadb-client
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

# Downloading and installing WP-CLI (WordPress command-line tool)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Creating the web directory and assigning permissions to the www-data user
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# Copying the custom PHP-FPM configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copying the initialization script
COPY tools/wordpress_entrypoint.sh /usr/local/bin/wordpress_entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress_entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["wordpress_entrypoint.sh"]
