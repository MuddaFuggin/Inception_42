# NOTES :

* Non, vous n'avez pas besoin d'écrire :443. Le préfixe https:// indique déjà automatiquement à n'importe quel navigateur d'utiliser le port 443 par défaut. Écrire [https://csimonne.42.fr/wp-admin/](https://csimonne.42.fr/wp-admin/) suffit donc amplement et correspond à l'URL standard exacte attendue.



# A propos des ports de connection 

## la convention Internet Assigned Numbers Authority :

Respecter les conventions facilite :

    La configuration réseau.

    Le dépannage.

    La communication entre machines.

    La maintenance des infrastructures.

#### Quelques conventions d'assignation pour les 'Services reseau fondamentaux'

Services réseau fondamentaux

| Port 	| Protocole | Service 
| ---  	| --- 		| --- 
| 20 	| TCP 		| FTP Data 
| 21 	| TCP 		| FTP Control 
| 22 	| TCP 		| SSH 
| 23 	| TCP 		| Telnet 
| 25 	| TCP 		| SMTP (envoi d'emails)
| 53 	| TCP/UDP	| DNS 
| 67 	| 68  		| UDP | DHCP 
| 80 	| TCP  		| HTTP 
| 110 	| TCP  		| POP3 
| 123 	| UDP  		| NTP (synchronisation horaire) 
| 143 	| TCP  		| IMAP 
| 443 	| TCP  		| HTTPS 
| 465 	| TCP  		| SMTP sécurisé 
| 587 	| TCP  		| SMTP Submission 
| 993 	| TCP  		| IMAPS 
| 995 	| TCP  		| POP3S

#### Quelques commandes utiles :

* Tous les ports TCP en écoute
ss -tln

* Tous les ports UDP en écoute
ss -uln

* Toutes les connexions TCP
ss -tn

* Tous les sockets (TCP et UDP)
ss -tuln


* Et pour connaître les services associés aux numéros de ports :
cat /etc/services


#### Une notion importante : port ≠ protocole

C'est probablement le point le plus intéressant à retenir.

Un port est simplement un numéro permettant d'identifier un point de communication sur une machine.

Par exemple :

IP : 192.168.1.10
Port : 22
Protocole : TCP
Service : SSH

Et une même machine peut héberger simultanément :


192.168.1.10:22    → SSH
192.168.1.10:80    → HTTP
192.168.1.10:443   → HTTPS
192.168.1.10:3306  → MySQL

Tous ces services peuvent fonctionner simultanément.

#### Pour aller plus loin

Je te conseille de retenir particulièrement ces trois notions :

1. IP : identifie une interface réseau sur une machine.
2. Port : identifie un point de communication sur cette machine.
3. Socket : représente une extrémité de communication, généralement associée à une IP, un port et un protocole.






# Guide de Soutenance - Projet Inception 42

Ce document synthétise l'ensemble de l'architecture, des choix techniques et des mécanismes de sécurité validés pour le projet Inception. Il est conçu pour vous servir de support de référence clair et direct lors de votre soutenance.

1. Architecture globale et Flux Réseau

Principe clé : L'infrastructure repose sur un cloisonnement strict et une isolation par conteneurs Docker orchestrés via un réseau privé bridge (inception_net).

Trajet d'une requête :

Le navigateur de l'utilisateur envoie une requête chiffrée en HTTPS (TLS v1.2 / v1.3) sur le port 443.

NGINX est l'unique point d'entrée de toute l'infrastructure (seul conteneur dont le port 443 est exposé sur l'hôte). Il déchiffre le TLS et analyse la requête.

Si la ressource est dynamique (.php), NGINX la transmet au conteneur WordPress (PHP-FPM) via le protocole FastCGI sur le port interne 9000.

WordPress traite la logique applicative et interroge la base de données MariaDB en SQL sur le port interne 3306.

Le résultat HTML est renvoyé à NGINX, rechiffré, puis transmis au navigateur.

2. Configuration Docker Compose et Images

Isolation des ports : Seul NGINX expose un port vers l'extérieur (443:443). MariaDB (3306) et WordPress (9000) sont strictement confinés au réseau interne et ne possèdent aucune directive ports: exposée sur l'hôte.

Conformité des tags : Aucune image n'utilise le tag interdit :latest. Toutes les images personnalisées portent le tag :42 (ex: nginx:42, wordpress:42, mariadb:42).

Secrets Docker : Les informations sensibles (mots de passe de la base de données et de l'administrateur WordPress) sont stockées dans des fichiers de secrets montés de manière sécurisée en mémoire (/run/secrets/), évitant toute exposition en clair dans le fichier .env ou les Dockerfiles.

3. Le Makefile : Rôle et Complémentarité

Pourquoi un Makefile ? Il sert de « télécommande » globale pour standardiser les commandes du projet (lancement, arrêt, diagnostic, nettoyage).

Gestion de l'hôte : Avant de lancer Docker, le Makefile crée obligatoirement les dossiers de persistance sur la machine hôte (mkdir -p /home/csimonne/data/mariadb et wordpress) pour satisfaire les prérequis des volumes bind mount.

Nettoyage (fclean) : Supprime les conteneurs, réseaux, volumes et nettoie en profondeur les répertoires physiques sur l'hôte.

4. Persistance des données et Volumes

Exigence du sujet : Les données doivent être stockées dans des volumes persistants pointant vers /home/csimonne/data/ sur la machine hôte.

Implémentation : Utilisation de volumes nommés (mariadb_data et wordpress_data) configurés avec le pilote local, le type none, l'option de bind (o: bind), et pointant vers les chemins absolus sur l'hôte.

Vérification en soutenance : La commande docker volume inspect prouve que le point de montage (Mountpoint) est correctement lié au dossier de l'hôte.

5. Sécurité TLS 1.2 / 1.3 et Certificat SSL

Restriction stricte : Le fichier de configuration NGINX impose explicitement la directive ssl_protocols TLSv1.2 TLSv1.3;, bloquant ainsi tous les protocoles obsolètes ou vulnérables.

Certificat auto-signé : Le certificat est généré automatiquement au premier lancement via OpenSSL (openssl req -x509).

Argument de soutenance : Si le navigateur affiche un avertissement de sécurité ("Your connection is not private" / ERR_CERT_AUTHORITY_INVALID), expliquez calmement qu'il s'agit d'un certificat auto-signé, ce qui est explicitement autorisé par la grille d'évaluation ("The SSL/TLS certificate doesn't have to be recognized. A self-signed certificate warning may appear"). Le tunnel chiffré reste pleinement fonctionnel.

6. Gestion des processus et PID 1

Règle d'or de Docker : Un conteneur s'arrête dès que son processus principal (PID 1) se termine ou se détache en arrière-plan.

Solution appliquée :

NGINX se termine par exec nginx -g "daemon off;".

PHP-FPM se termine par exec php-fpm -F (Force Foreground).

MariaDB se termine par exec mysqld --user=mysql.

L'utilisation de la commande exec remplace le script bash initial par le service, lui garantissant le statut de PID 1 au premier plan.

7. Scripts d'initialisation et WordPress (WP-CLI)

Automatisation complète : Aucun assistant d'installation graphique de WordPress ne doit apparaître. Les scripts d'entrypoint automatisent tout au premier lancement :

Attente active de MariaDB (mariadb-admin ping).

Téléchargement de WordPress si le dossier est vide (wp core download).

Génération du fichier wp-config.php connecté à MariaDB (wp config create).

Installation de la base de données (wp core install).

Gestion des utilisateurs : Deux utilisateurs sont obligatoirement créés via WP-CLI :

Un compte administrateur dont le nom d'utilisateur ne contient pas le mot "admin" ou "administrator" (ex: csimonne).

Un second utilisateur régulier avec un rôle restreint (ex: visitor en tant qu'auteur).
