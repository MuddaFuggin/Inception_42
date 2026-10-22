`docker build -t mariadb-test`
-> build indepedant avec le Dockerfile de Mariadb

`docker images`
-> verifier si l image apparait

`docker run -d --name test-db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress -e MYSQL_USER=user -e MYSQL_PASSWORD=password mariadb-test`
-> lancer un docker ephemere
Vérification : La commande retourne un long identifiant (hash) de conteneur.

`docker logs test-db`
-> verifiez que le script d'entrée s'est bien exécuté et que MariaDB écoute sur le port 3306 :
érification : Vous devriez voir des lignes indiquant que MariaDB a démarré et est prêt pour les connexions (socket: '/run/mysqld/mysqld.sock', port: 3306).

`docker ps -a`
-> status check.


`docker rm -f test-db`
-> supprimez ce conteneur de test proprement

