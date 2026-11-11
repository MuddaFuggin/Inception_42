
## Inception : project's file tree


```text
.
├── Makefile                     # Entry point for managing the infrastructure (Make)
├── README.md                    # General project overview
├── USER_DOC.md                  # User and administrator documentation
├── DEV_DOC.md                   # Developer documentation
├── .gitignore                   # Files and directories excluded from Git tracking
│
├── secrets/                     # Local secured directory containing passwords (not tracked by Git)
│   ├── db_password.txt          # MariaDB user password
│   ├── db_root_password.txt     # MariaDB root password
│   ├── wp_admin_password.txt    # WordPress administrator password
│   └── wp_password.txt          # Standard WordPress user password
│
└── srcs/                        # Directory containing all Docker configuration files
    ├── (.env)                   # Not tracked by Git, has to be created by admin or user during setup.
    ├── .env.example             # Configuration template (tracked by Git)
    ├── docker-compose.yml       # Orchestration file (services, bridge networks, bind-mounted volumes)
    │
    └── requirements/            # Isolated build instructions and configuration for each service
        ├── mariadb/
        │   ├── Dockerfile       # Debian-based image for the database server
        │   ├── conf/
        │   │   └── 50-server.cnf # MySQL/MariaDB server configuration
        │   └── tools/
        │       └── entrypoint.sh # Initialization script (database creation and privilege configuration)
        │
        ├── wordpress/
        │   ├── Dockerfile       # Debian-based image with PHP-FPM and WP-CLI
        │   ├── conf/
        │   │   └── www.conf     # PHP-FPM pool configuration (listening on port 9000)
        │   └── tools/
        │       └── wordpress_entrypoint.sh # Waits for MariaDB and handles WordPress installation via WP-CLI
        │
        └── nginx/
            ├── Dockerfile       # Alpine-based image for the reverse proxy
            ├── conf/
            │   └── nginx.conf   # Server configuration (TLS 1.2/1.3, port 443, FastCGI)
            └── tools/
                └── nginx_entrypoint.sh # TLS/SSL certificate generation and NGINX startup
```

<br><br>

## Introduction

This project consists of setting up a small-scale web infrastructure using Docker and Docker Compose. The goal is to deploy a secure and isolated stack consisting of NGINX, WordPress, and MariaDB inside a Debian virtual machine.

Each service runs in its own dedicated container, built from custom Dockerfiles located in the srcs/requirements directory. The containers communicate through a private Docker network.

<br><br>

## Instructions To compile, install, and execute the stack :

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


*Note:* 
- Never commit .env or the contents of secrets/ to a public repository. Keep them private and properly excluded through .gitignore.
- You should use a strong password that does not contain the word 'admin', your name, or obvious sequences (e.g. 123456).

```bash
echo "my_db_password" > ~/Inception_42/secrets/db_password.txt 
echo "my_root_password" > ~/Inception_42/secrets/db_root_password.txt 
echo "my_admin_password" > ~/Inception_42/secrets/wp_admin_password.txt 
echo "my_user_password" > ~/Inception_42/secrets/wp_password.txt
```


#### Installation and launch : 

Run `make` at the root of the repository : it will prepare the host directories, build the images, and _start the containers_ via *Docker Compose*.


<br><br>
## Before you continue :

In the following, you might find entries like ${DATA_PATH} or ${your_domain_name}. Remember to always consider those having to be the actual data you entered in the .env file.
<br><br>

## A few User Commands :

#### Starting, stopping :

*All of those commands have to be launched from the folder containing the _Makefile_ file.*
*They are actual aliases of *Docker* and *Dockercompose* embeded commands.*

* Use `make start` to start all the containers at once.
* Use `make stop` to stop all the containers at once.
* Command `make restart` = `make stop` + `make start`.
  
*Tips :The commands above can be used for maintenance purposes and to test data persistence.*

#### Different levels of stopping + cleaning (use with care !) :

* `make down` : Stops and removes all project containers and the associated Docker network. Docker destroys the virtual network interfaces and bridge associated with that network. Named volumes and bind-mounted host data are preserved.
* `make clean` : Equivalent to make down + removes the Compose-managed named volumes (docker compose down -v). In our configuration, the Docker volume is removed, but the underlying host directory (${DATA_PATH}/mariadb) and its data are preserved.
* `make fclean` : Equivalent to make clean + all eligible unused resources (images, unused misc containers, unused networks, build cache) + deletes the contents of the host data directory using rm -rf $(DATA_PATH)*.

**Warning :** *This last command permanently deletes the persistent database and WordPress data stored in the host directories.*

#### Changing your credentials :

If you wish to change your credentials, you'll have to submit the make fclean command, knowing that it will permanently delete any change you made on your website, and then edit your files in the /secrets/ folder (see #Your First Launch, point 2). Alternatively, you can change only your Wordpress passwords from the website's Dashboard, keeping your data safe. you can also use the command `docker compose -f srcs/docker-compose.yml exec wordpress wp user update {USER_NAME} --user_pass="NouveauMotDePasse" --allow-root --path=/var/www/html`

<br><br>
## Access the website : 

_disclaimer : A security warning will appear due to the self-signed SSL/TLS certificate, which is expected._

#### With this particular 'headless' Linux Debian setup :

Due to the limitations of this development environment (no graphical interface), you must force a DNS redirection to bypass the NAT. To do so, please type the following _from your physical machine's terminal_ :

_Note : Please replace all '{your_domain_name}' entries by the domain name you indicated in the `.env` file. 

* For the website :
`google-chrome --incognito --host-resolver-rules="MAP {your_domain_name} 127.0.0.1" "https://{your_domain_name}:4443/"`   

* For administration panel :
`google-chrome --incognito --host-resolver-rules="MAP {your_domain_name} 127.0.0.1" "https://{your_domain_name}:4443/wp-admin/"`   

*Note:* You can replace 'google-chrome' with another Chromium-based browser prompt, but this specific DNS injection flag does not work with Firefox.

#### Accessing the website from a graphical Debian setup :

If your Debian VM already has a graphical environment and a web browser installed, only a few steps are required:

1. Find your VM's IP address: `ip addr`.
2. Add your domain name to `/etc/hosts` : type `sudo vim /etc/hosts`, and add this line to the document ->  
   `[YOUR_IP] {your_domain_name}`
3. Open your browser inside the VM and visit:
   - `https://{your_domain_name}/`
   - `https://{your_domain_name}/wp-admin/`

*Note:* This setup is entirely optional. Inception works perfectly fine with a headless VM and a browser running on the host machine.

<br><br>

## Various available tests

_Run `make check` at the root of the repository. It gives you access to a menu, possibly sub-menus, providing various options. Type `clear` to clear your entries or `exit` to go back to bash._

Type the following for some interesting tests :

- `status` : Checks which processes are _up_ and running (PID1). You can also witness Network isolation of Wordpress and MariaDb.
- `log` : Displays the real-time execution logs for the NGINX, MariaDB, or WordPress containers.
- `volumes` : Displays the Docker volume configurations and lists the physical persistent files currently stored on the host machine.
- `images` : Displays local Docker image information.
- `versions` : Extracts the FROM directive from the Dockerfiles to display which base OS images were used.
- `user` : Lists the registered WordPress users via WP-CLI to verify account roles and usernames.
- `ports` : Scans all 65.535 existing ports to display opened, closed or restricted ports.
- `wp` > `security` : displays TLS status.
- `wp` > `httptest` : Performs 'curl' exposure tests for port 80 (HTTP) and port 443 (HTTPS), verifying secured accessibility (only HTTPS, HTTP gets rejected).

And many more...  
<br><br>


****
## Inception : Inside the engine.

<br>

## Three Containers, one goal : Role of the Containers and Inter-Container Interactions

The project relies on three distinct services, each isolated in its own container and communicating through a private internal Docker bridge network (inception_net). The operation relies on a strict separation of tasks and how the main router sorts incoming requests.

1. **NGINX** (The Front-End Web Server & Reverse Proxy)  
It is the only container exposed to the outside world, handling secure HTTPS requests on port 443. It acts as the single entry point for all client traffic and separates requests into two distinct streams:
Static Requests Stream (CSS, JS, images): When a client requests a static asset, NGINX retrieves it directly from the shared volume (/var/www/html) and serves it instantly. The other containers are not involved or woken up.
Dynamic Requests Stream (.php files): NGINX cannot interpret PHP code. When a client requests a dynamic web page (e.g., index.php), NGINX forwards the request to the WordPress container via the internal network using the FastCGI protocol on port 9000.

2. **WordPress** / PHP-FPM (The Application Engine)  
Invisible from the outside, its strict role is to execute the core WordPress PHP scripts and business logic.
It receives the order from NGINX to process a specific PHP file.
During execution, it needs to query the database to retrieve articles or verify passwords, so it connects to the MariaDB container via the MySQL/SQL protocol on internal port 3306.
Once it has assembled the data into a standard HTML page, it sends the finished product back to NGINX, which transfers it to the client.

3. **MariaDB** (The Relational Database)  
Located at the very end of the chain, this container is completely isolated.
It only communicates with the WordPress container.
It stores all persistent application data, including user accounts, posts, comments, and site configuration, in its own secure volume.
It receives SQL queries from WordPress, reads or modifies the requested data, and sends the results back so WordPress can finish generating the page.
   
4. **_Shared Volumes_**: Both NGINX and WordPress mount the same shared WordPress source code volume so that NGINX can verify file existence and serve static assets directly.

<br><br>
****
****
<br>

## About your data, and Volumes :

* As this configuration uses mounted *Named Volumes with local bind mount*, everything you add or remove from your website will persist overtime. **Unless you go** `make fclean` **!**
* Here's the path to your Named Volumes, depending on what indications you gave to the section `DATA_PATH=  ` in the `.env` file :    
`${DATA_PATH}`/mariadb (pour la base de données)  
`${DATA_PATH}`/wordpress (pour les fichiers du site WordPress)  
Nginx doesn't hold a Volume.  

*Of Volumes :*  
By default, Docker stores all and any data inside the Container. However, this doesn't allow to hold data efficiently overtime as any reboot of the containers would loose new data (the data you add to your website, for instance).
Fortunately, Docker permits configuration of 'Named Volumes' for data persistence in a default directory, and even *Local Named Volumes* for which we can choose a convenient dedicated path.
To do so, in the `docker-compose.yml` file, we use the local driver with bind mount options (type: none, o: bind) to make it point directly to a directory on the host machine ($(DATA_PATH)).

<br><br>

## About security :

#### TLS & HTTPS:

All external web traffic is secured using TLS encryption. Nginx is configured to support TLSv1.2 and TLSv1.3, ensuring that communications between clients and the server are encrypted. Only HTTPS connections are allowed by Nginx (see `srcs/requirements/nginx/conf/nginx.conf`), and a a self-signed SSL/TLS certificate and private key are used to establish secure connections. *The Use of an official SSL/TLS certificate might be considered for further use.*

* Notes for a potential re-configuration :  
- The private key (`inception.key`) and the certificate (`inception.crt`) files are dynamically generated by the `nginx_entrypoint.sh` script when the NGINX container starts, .
- They are stored in the `/etc/nginx/ssl/` directory inside the container.
- NGINX uses them in its `nginx.conf` configuration file through the `ssl_certificate` and `ssl_certificate_key` directives to secure communications over port 443 using TLS v1.2 / v1.3.

*A quick explanation : the TLS certificate is given to your server's client to encrypt his own data when it communicates with your website and server. The TLS key is used by your server to decrypt your client's requests, that has been encrypted using the TLS certificate.  
In this project, our TLS certificate has not been signed by competent authority : it still does it's job but isn't trusted by your client's browser.*

#### Host-Level File Permissions & Ownership:

The raw credential files stored in the host's secrets/ directory are strictly protected using restricted permissions (chmod 600), ensuring that only the authorized owner (and root) on the host machine can read them.

#### Container Isolation & Least Privilege Principle:

Containers do not share a global security context. Secrets are explicitly distributed on a "need-to-know" basis via Docker Compose:
    NGINX receives no secrets since it does not authenticate against databases.
    MariaDB and WordPress only receive the specific credential files required for their internal operations, preventing horizontal privilege escalation if a container is compromised.

#### No Persistent Disk Footprint Inside Containers:

Because Docker mounts secrets using an in-memory tmpfs filesystem (/run/secrets/), no sensitive passwords are ever written to the container's writable storage layer. Once a container stops, all secret data instantly vanishes from memory without leaving forensic traces on the disk.
<br><br><br>
****
****
<br>

## A few words about the infrastructure used, and the advantages of using Docker containers.

* Docker Secrets & Security Compliance:
  
To comply with the strict security requirements of the 42 Inception project, no passwords or sensitive data are stored in plain text within the .env file or configuration scripts. Instead, all database and administrator credentials are securely managed using Docker Secrets. These secrets are stored locally on the host, protected with restricted permissions, and injected directly into the containers' memory (/run/secrets/) at runtime—ensuring they remain completely isolated, hidden, and never exposed in the repository.

* Docker Usage & Design Choices:
  
Docker is utilized to containerize applications at the OS level, sharing the host's kernel instead of virtualizing hardware. This project employs a modular design where each service relies on custom initialization scripts (entrypoint.sh) to prepare the environment and ensure the main process remains in the foreground as PID 1.

* Virtual Machines vs Docker:
  
Virtual Machines run a full guest operating system on top of virtualized hardware, making them heavy and resource-intensive. Docker containerizes applications at the OS level, sharing the host's kernel, which makes it significantly faster and more lightweight.

* Secrets vs Environment Variables:
  
Environment variables are useful for general configuration (like domain names) but can be exposed if the container environment is inspected. Docker Secrets are used for sensitive data (like database passwords) because they are securely mounted directly into temporary files, keeping them hidden from the standard environment.

* Docker Network vs Host Network:
  
Using the host network shares the host machine's network stack directly, which lacks isolation. This project uses a custom Docker Network to create an isolated internal bridge where containers communicate securely using internal DNS, exposing only port 443 to the outside world.

* Docker Volumes vs Bind Mounts:
  
Bind mounts map a physical directory from the host directly into a container, while Docker Volumes are entirely managed by Docker within its internal storage. To satisfy the project's requirement of storing data physically in ${DATA_PATH}, this infrastructure uses Named Volumes with a local driver pointing explicitly to the host's bind path, ensuring persistent data even if containers are destroyed.


<br><br>

## Going deeper :

### 1. About Network, PORTS and connections.

*Note : 127.0.0.1 always references to the machine (or network) from which a connection is made.*

#### a.1. Simple Network scheme :

       [ Browser / Client ] https://csimonne.42.fr:4443 --> VirtualBox[4443:443]
                |             
       =========|==========================================================================
                |  Port 443 (HTTPS / TLS v1.2-1.3)	         mappings in docker-compose.yml			
                |  ONLY external entry point				
                |                                            ports: - "443:443"-                    
                v
       +------------------------+
       |         NGINX          |  Reverse Proxy & TLS Security
       +------------------------+
       =========|==========================================================================
                |  Port 9000 (FastCGI Protocol)
                |  Internal Docker Network
                |                                            expose: 9000
                v
       +------------------------+
       |   WordPress / PHP-FPM  |  CMS Engine & Interpreter
       +------------------------+
       =========|==========================================================================
                |  Port 3306 (SQL Protocol)
                |  Internal Docker Network
                |                                            expose: 3306
                v
       +------------------------+
       |        MariaDB         |  Relational Database
       +------------------------+

#### a.2 Request Path: From Browser to Database

Here is the step-by-step path that connects your web page to your project through the Oracle VirtualBox redirection:

🌍 **1. The Physical Mac Browser (Port 4443)**
* The request originates from your browser using the target URL `https://csimonne.42.fr:4443`.
* The on-the-fly DNS rule (`--host-resolver-rules="MAP csimonne.42.fr 127.0.0.1"`) forces this request to the Mac's loopback address (`127.0.0.1`), bypassing the lack of administrator rights needed to modify the school's `/etc/hosts` file.

🛡️ **2. The VirtualBox Hypervisor (NAT Forwarding 4443 ➔ 443)**
* VirtualBox listens on the local port 4443 of your Mac.
* Thanks to your Port Forwarding rule, the hypervisor intercepts this incoming traffic and injects it directly into the standard HTTPS port (443) inside the Debian virtual machine.

🚪 **3. The NGINX Security Gateway (Port 443 ➔ Port 9000)**
* The request arrives on port 443 of the VM, which Docker immediately routes to the NGINX container (mapped via the `ports: "443:443"` directive).
* NGINX, acting as the only exposed entry point, decrypts the TLS security layer.
* Since it cannot interpret PHP, it forwards the page-building request to the WordPress container through the private FastCGI protocol on port 9000.

⚙️ **4. The Internal Private Network (Ports 9000 and 3306)**
* **WordPress (PHP-FPM):** Receives the commands on its port 9000. It executes the PHP scripts and queries the database via the isolated `inception_net` network on port 3306.
* **MariaDB:** Receives the SQL query on port 3306, retrieves the data from its persistent volume, and sends it back to WordPress.
* Finally, WordPress assembles the final HTML code and sends it back to NGINX, which re-encrypts it and sends it all the way back up to your browser.


#### b. A few conventions at use in this project :

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

Common Port Assignments for Fundamental Network Services :

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

#### d. Some Useful Bash Commands regarding Networks in this project

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

#### e. An Important Concept: Port ≠ Protocol

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

Gestion de l'hôte : Avant de lancer Docker, le Makefile crée obligatoirement les dossiers de persistance sur la machine hôte (mkdir -p ${DATA_PATH}/mariadb et wordpress) pour satisfaire les prérequis des volumes bind mount.

Nettoyage (fclean) : Supprime les conteneurs, réseaux, volumes et nettoie en profondeur les répertoires physiques sur l'hôte.

4. Persistance des données et Volumes

Exigence du sujet : Les données doivent être stockées dans des volumes persistants pointant vers ${DATA_PATH} sur la machine hôte.

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


