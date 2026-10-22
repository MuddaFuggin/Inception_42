#!/bin/bash
set -e

# Lecture des mots de passe depuis les secrets Docker
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Créer le répertoire du socket s'il n'existe pas
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Si la base principale n'existe pas encore, on l'initialise
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Démarrage temporaire en arrière-plan pour exécuter les commandes SQL
	mysqld --user=mysql --bootstrap << EOF

USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Lancement final de mysqld au premier plan
exec mysqld --user=mysql