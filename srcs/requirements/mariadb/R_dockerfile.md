## Voici l'explication détaillée de chaque ligne de votre Dockerfile MariaDB :

>>FROM debian:bookworm

Définit l'image de base. On repart d'une distribution Debian (version Bookworm) minimale pour y construire notre conteneur.

>>RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*

Met à jour la liste des paquets, installe le serveur MariaDB sans les paquets optionnels recommandés (--no-install-recommends pour garder l'image légère), puis nettoie immédiatement le cache apt pour réduire la taille finale de l'image.

>>COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

Copie votre fichier de configuration personnalisé depuis votre machine hôte (conf/50-server.cnf) vers l'emplacement où MariaDB va le lire à l'intérieur du conteneur.

>>COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

Copie votre script de démarrage et d'initialisation (entrypoint.sh) dans le dossier des exécutables système du conteneur.

>>RUN chmod +x /usr/local/bin/entrypoint.sh

Donne les droits d'exécution au script que vous venez de copier pour qu'il puisse se lancer au démarrage.

>>EXPOSE 3306

Indique à titre informatif (et pour la documentation du réseau Docker) que le conteneur écoute sur le port réseau standard de MySQL/MariaDB (3306).

>>ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

Définit la commande principale et obligatoire qui s'exécute automatiquement au lancement du conteneur. C'est elle qui va initialiser la base si elle n'existe pas, puis démarrer le serveur MariaDB.