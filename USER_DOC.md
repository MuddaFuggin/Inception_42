*This project has been created as part of the 42 curriculum by csimonne.*

• USER_DOC.md — User documentation This file must explain, in clear and simple
terms, how an end user or administrator can:

◦ Access the website and the administration panel.
◦ Locate and manage credentials.
◦ Check that the services are running correctly.


## Description (Understand what services are provided by the stack.)


## Instructions

To compile, install, and execute this project:

##### Prerequisites :

You could follow the instructions below to set up and run the infrastructure on your own hypervisor, provided that _docker_ and _docker compose_ are installed. However, the original development environment consists of a Virtual Machine with Debian Bookworm installed (without a graphical interface).

To reproduce this environment, you can set up your own Linux Virtual Machine with the following configuration : (note that in the context of a 42 school evaluation, the ready-made .ova file will be provided)

- Install Docker and Docker Compose.
- Configure your VM's port forwarding rules:
        HTTPS: TCP, host port 4443 → guest port 443.
	- For convenience, you can also access your VM through SSH :  
        SSH: TCP, host port 2222 → guest port 22.

- Launch Debian on your VM.

##### Configuration :

1. Ensure your environment variables are configured in `srcs/.env`.You can create your `.env` based on the `.env.example` provided.
(access : `cd ~/Inception_42/srcs && ls -la`, create _.env_ and modify it : `cp .env.example .env`)
2. Create your local passwords as text files inside the `secrets/` directory. Use this blueprint :

```bash
echo "my_db_password" > ~/Inception_42/secrets/db_password.txt 
echo "my_root_password" > ~/Inception_42/secrets/db_root_password.txt 
echo "my_admin_password" > ~/Inception_42/secrets/wp_admin_password.txt 
echo "my_user_password" > ~/Inception_42/secrets/wp_password.txt
```

##### Installation and launch : 

Run `make` at the root of the repository : it will prepare the host directories, build the images, and _start the containers_ via *Docker Compose*.

## Starting, stopping :

*All of those commands has to be launched from the folder containing the _Makefile_ file.*

* Use `make start` to start all the containers at once.
* Use `make stop` to stop all the containers at once.
* Command `make restart` is an alias for `make stop` + `make start`.
Tips :The commands above can be used for maintenance purposes and to test data persistence.

## Different levels of stopping + cleaning (use with care !) :

* `make down` : Stops and removes all project containers and the associated Docker network. Docker destroys the virtual network interfaces and bridge associated with that network. Named volumes and bind-mounted host data are preserved.
* `make clean` : Equivalent to make down + removes the Compose-managed named volumes (docker compose down -v). In our configuration, the Docker volume is removed, but the underlying host directory (/home/csimonne/data/mariadb) and its data are preserved.
* `make fclean` : Equivalent to make clean + all eligible unused resources (images, unused misc containers, unused networks, build cache) + deletes the contents of the host data directory using rm -rf $(DATA_PATH)*.

Warning: This last command permanently deletes the persistent database and WordPress data stored in the host directories.


## Access the website :  
Due to the limitations of the development environment (headless VM, lack of sudo privileges on the physical machine), if you are testing from a campus 42's computer, you must force a DNS redirection to bypass the NAT. To do so, please type the following _from your physical machine's terminal_ :  
`google-chrome --incognito --host-resolver-rules="MAP csimonne.42.fr 127.0.0.1" "https://csimonne.42.fr:4443/wp-admin/"`   

	If it does not work, try clearing your browser's navigation history and cookies.  

		Note: You can replace 'google-chrome' with another Chromium-based browser prompt, but this specific DNS injection flag does not work with Firefox.
 
	_However_, if you have configured a graphical interface and a browser directly inside your VM, simply navigate to the standard URL without the forwarded port: `https://csimonne.42.fr/`

		disclaimer : In both cases, a security warning will appear due to the self-signed SSL/TLS certificate, which is expected.


##### Various available tests

Run `make check` at the root of the repository. It gives you access to various options. type `clear` to clear your entries or `exit` to go back to bash.

Type the following for some interesting tests :

- `status` : Checks which processes are _up_ and running.
- `volumes` : Displays the Docker volume configurations and lists the physical persistent files currently stored on the host machine.
- `user` : Lists the registered WordPress users via WP-CLI to verify account roles and usernames.
- `images` : Displays local Docker image information.
- `versions` : Extracts the FROM directive from the Dockerfiles to display which base OS images were used..
- `log` : Displays the real-time execution logs for the NGINX, MariaDB, or WordPress containers.
- `wp` : Performs 'curl' exposure tests for port 80 (HTTP) and port 443 (HTTPS).





















##### WHAAAAAAAAAAAAAAAAAAAAAAAAAAAAT
echo "mon_mot_de_passe_db" > secrets/db_password.txt 
echo "mon_root_password" > secrets/db_root_password.txt 
echo "mon_admin_password" > secrets/wp_admin_password.txt 
echo "mon_user_password" > secrets/wp_password.txt




make down  = 
docker compose -f srcs/docker-compose.yml down 

=

removing all containers

[+] down 4/4
 ✔ Container nginx       Removed                                                                                                               4.2s
 ✔ Container wordpress   Removed                                                                                                               3.9s
 ✔ Container mariadb     Removed                                                                                                               5.1s
 ✔ Network inception_net Removed





 make clean =
  docker compose -f srcs/docker-compose.yml down -v

=

removing allc ontainers AND volumes


 ✔ Volume mariadb_data   Removed                                                                                                               0.2s
 ✔ Volume wordpress_data Removed   


 make fclean = clean !

 +

 	docker system prune -af
	sudo rm -rf $(DATA_PATH)


la ligne 'prune' =

supprime les :
Conteneurs arrêtés / Images Docker non utilisées / Réseaux inutilisés / Cache de build
