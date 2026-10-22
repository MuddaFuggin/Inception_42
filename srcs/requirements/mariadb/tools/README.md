# La structure attendue de ton entrypoint.sh

### Un script d'entrée MariaDB classique gère généralement deux cas de figure :

1. ##### Premier démarrage (initialisation) :

Création du répertoire /var/lib/mysql et initialisation des bases de données système (mariadb-install-db ou mysql_install_db).

2. ##### Démarrage temporaire de MariaDB en arrière-plan.

Exécution des requêtes SQL pour créer la base de données, l'utilisateur applicatif avec ses droits, et sécuriser le mot de passe root.

Arrêt du processus temporaire.

3. ##### Démarrage final :

Lancement de mysqld (ou mariadbd) au premier plan avec exec mysqld --user=mysql pour récupérer le PID 1 et capter les signaux d'arrêt du conteneur.