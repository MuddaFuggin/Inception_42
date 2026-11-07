

### Instructions

To compile, install, and execute this project:

#### Prerequisites :

You could follow the instructions below to set up and run the infrastructure on your own hypervisor, provided that _docker_ and _docker compose_ are installed. However, the original development environment consists of a Virtual Machine with Debian Bookworm installed (without a graphical interface).

To reproduce this environment, you can set up your own Linux Virtual Machine with the following configuration : (note that in the context of a 42 school evaluation, the ready-made .ova file will be provided).

- Install Docker and Docker Compose.
- Configure your VM's port forwarding rules:
        HTTPS: TCP, host port 4443 → guest port 443.
	- For convenience, you can also access your VM through SSH :  
        SSH: TCP, host port 2222 → guest port 22.

- Launch Debian on your VM.

#### Configuration :

1. Ensure your environment variables are configured in `srcs/.env`.You can create your `.env` based on the `.env.example` provided.
(access : `cd ~/Inception_42/srcs && ls -la`, create _.env_ and modify it : `cp .env.example .env`)
2. Create your local passwords as text files inside the `secrets/` directory. To do so, use the following blueprint and add your personal credentials in place of ["my_db_password"] and the 3 other credentials. Once edited, submit it in bash.

```bash
echo "my_db_password" > ~/Inception_42/secrets/db_password.txt 
echo "my_root_password" > ~/Inception_42/secrets/db_root_password.txt 
echo "my_admin_password" > ~/Inception_42/secrets/wp_admin_password.txt 
echo "my_user_password" > ~/Inception_42/secrets/wp_password.txt
```

*Note:* 
- Never commit .env or the contents of secrets/ to a public repository. Keep them private and properly excluded through .gitignore.

#### Installation and launch : 

Run `make` at the root of the repository : it will prepare the host directories, build the images, and _start the containers_ via *Docker Compose*.

****

### User Commands :

#### Starting, stopping :

*All of those commands has to be launched from the folder containing the _Makefile_ file.*

* Use `make start` to start all the containers at once.
* Use `make stop` to stop all the containers at once.
* Command `make restart` is an alias for `make stop` + `make start`.
Tips :The commands above can be used for maintenance purposes and to test data persistence.

#### Different levels of stopping + cleaning (use with care !) :

* `make down` : Stops and removes all project containers and the associated Docker network. Docker destroys the virtual network interfaces and bridge associated with that network. Named volumes and bind-mounted host data are preserved.
* `make clean` : Equivalent to make down + removes the Compose-managed named volumes (docker compose down -v). In our configuration, the Docker volume is removed, but the underlying host directory (/home/csimonne/data/mariadb) and its data are preserved.
* `make fclean` : Equivalent to make clean + all eligible unused resources (images, unused misc containers, unused networks, build cache) + deletes the contents of the host data directory using rm -rf $(DATA_PATH)*.

Warning: This last command permanently deletes the persistent database and WordPress data stored in the host directories.

****

### Access the website : 

_disclaimer : A security warning will appear due to the self-signed SSL/TLS certificate, which is expected._

#### With this particular 'headless' Linux Debian setup :

Due to the limitations of this development environment (no graphical interface), you must force a DNS redirection to bypass the NAT. To do so, please type the following _from your physical machine's terminal_ :

* For the website :
`google-chrome --incognito --host-resolver-rules="MAP csimonne.42.fr 127.0.0.1" "https://csimonne.42.fr:4443/"`   

* For administration panel :
`google-chrome --incognito --host-resolver-rules="MAP csimonne.42.fr 127.0.0.1" "https://csimonne.42.fr:4443/wp-admin/"`   

*Note:* You can replace 'google-chrome' with another Chromium-based browser prompt, but this specific DNS injection flag does not work with Firefox.

#### Accessing the website from a graphical Debian setup :

If your Debian VM already has a graphical environment and a web browser installed, only a few steps are required:

1. Find your VM's IP address: `ip addr`.
2. Add your domain name to `/etc/hosts`, typing `sudo vim /etc/hosts`, and adding this line :  
   `[YOUR_IP] csimonne.42.fr`
3. Open your browser inside the VM and visit:
   - `https://csimonne.42.fr/`
   - `https://csimonne.42.fr/wp-admin/`

*Note:* This setup is entirely optional. Inception works perfectly fine with a headless VM and a browser running on the host machine.

****

### Various available tests

_Run `make check` at the root of the repository. It gives you access to a menu, possibly sub-menus, providing various options. Type `clear` to clear your entries or `exit` to go back to bash._

Type the following for some interesting tests :

- `status` : Checks which processes are _up_ and running (PID1). You can also witness Network isolation of Wordpress and MariaDb.
- `log` : Displays the real-time execution logs for the NGINX, MariaDB, or WordPress containers.
- `volumes` : Displays the Docker volume configurations and lists the physical persistent files currently stored on the host machine.
- `images` : Displays local Docker image information.
- `versions` : Extracts the FROM directive from the Dockerfiles to display which base OS images were used.
- `user` : Lists the registered WordPress users via WP-CLI to verify account roles and usernames.
- `wp` > `security` : displays TLS status.
- `wp` > `httptest` : Performs 'curl' exposure tests for port 80 (HTTP) and port 443 (HTTPS), verifying secured accessibility (only HTTPS, HTTP gets rejected).

And many more...  

****  





















## Useful informations about the infrastructure :

### 1. About the Network, PORTS and connections.

#### a. Simple Network scheme :

       [ Browser / Client ]
                |
                |  Port 443 (HTTPS / TLS v1.2-1.3)	  mappings in docker-compose.yml			
                |  ONLY external entry point				
                |                                            ports: - "443:443"-
                |                                            
                v
       +------------------------+
       |         NGINX          |  Reverse Proxy & TLS Security
       +------------------------+
                |
                |  Port 9000 (FastCGI Protocol)
                |  Internal Docker Network
                |                                            expose: 9000
                v
       +------------------------+
       |   WordPress / PHP-FPM  |  CMS Engine & Interpreter
       +------------------------+
                |
                |  Port 3306 (SQL Protocol)
                |  Internal Docker Network
                |                                            expose: 3306
                v
       +------------------------+
       |        MariaDB         |  Relational Database
       +------------------------+

#### b. A few conventions put to use in this project :

**HTTP** conventionally uses port **80**.  
**HTTPS** conventionally uses port **443**.  
**SSH** conventionally uses port **22**.  
**MariaDB** listens on the port **3306** (TCP) which is the standard port attributed to MySQL communications.   
**PHP-FPM** (engine for Wordpress) listens on the port **9000**, which is the standard port attributed to FastCGI communications.  


#### c. The "Internet Assigned Numbers Authority" convention :

Respecting conventions makes the following tasks easier:
- Network configuration.
- Troubleshooting.
- Communication between machines.
- Infrastructure maintenance.

##### d. Common Port Assignments for Fundamental Network Services

| Port | Protocol | Service |
|---:|---|---|
| 20 | TCP | FTP Data |
| 21 | TCP | FTP Control |
| 22 | TCP | SSH |
| 23 | TCP | Telnet |
| 25 | TCP | SMTP (email sending) |
| 53 | TCP/UDP | DNS |
| 67 / 68 | UDP | DHCP |
| 80 | TCP | HTTP |
| 110 | TCP | POP3 |
| 123 | UDP | NTP (time synchronization) |
| 143 | TCP | IMAP |
| 443 | TCP | HTTPS |
| 465 | TCP | Secure SMTP |
| 587 | TCP | SMTP Submission |
| 993 | TCP | IMAPS |
| 995 | TCP | POP3S |

#### e. Some Useful Bash Commands regarding Networks in this project

````
1. **IP address:** identifies a network interface on a machine.
2. **Port:** identifies a communication endpoint on that machine.
3. **Socket:** represents one endpoint of a communication channel, generally associated with an IP address, a port, and a protocol.
````

- All listening TCP ports:
  ```bash
  ss -tln
  ```
- All listening UDP ports:
  ```bash
  ss -uln
  ```
- All TCP connections:
  ```bash
  ss -tn
  ```
- All listening TCP and UDP sockets:
  ```bash
  ss -tuln
  ```

To find out which services are associated with port numbers:

```bash
cat /etc/services
```

#### f. An Important Concept: Port ≠ Protocol

A port is simply a number used to identify a communication endpoint on a machine.

For example:

```text
IP:       192.168.1.10
Port:     22
Protocol: TCP
Service:  SSH
```

A single machine can host several services simultaneously:

```text
192.168.1.10:22    → SSH
192.168.1.10:80    → HTTP
192.168.1.10:443   → HTTPS
192.168.1.10:3306  → MySQL
```

All these services can run simultaneously.




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


## Pedagogical notes

* You don't need to add the [:443] port number to test your connections and ports. The [https://] prefix already forces the browser to use the *443* port by default. If you type [http://], the browser will use the port *80*.
* 
