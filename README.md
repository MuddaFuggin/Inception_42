*This project has been created as part of the 42 curriculum by csimonne.*

## Description

This project consists of setting up a small-scale web infrastructure using _Docker_ and _Docker Compose_. The goal is to deploy a secure and isolated stack consisting of NGINX, WordPress, and MariaDB inside a Debian virtual machine.

Each service runs in its own dedicated container, built from custom Dockerfiles located in the `srcs/requirements` directory. The containers communicate through a private Docker network.


## Instructions

To compile, install, and execute this project:

##### Prerequisites :

You could follow the instructions below to set up and run the infrastructure on your own hypervisor, provided that _docker_ and _docker compose_ are installed. However, the original developpement environnement consists of a Virtual Machine with Debian Bookworm installed (without a graphical interface).

To reproduce this environment, you can set up your own Linux Virtual Machine with the following configuration : (note that in the context of a 42 school evaluation, the ready-made .ova file will be provided)

- Install Docker and Docker Compose.
- Configure your VM's port forwarding rules:
        HTTPS: TCP, host port 4443 → guest port 443.
	- For convenience, you can also access your VM through SSH :  
        SSH: TCP, host port 2222 → guest port 22.

- Launch Debian on your VM.

##### Configuration :

1. Ensure your environment variables are configured in `srcs/.env`.You can create your `.env` based on the `.env.example` provided.

2. Create your local passwords as text files inside the `secrets/` directory. Use this blueprint :

```bash
echo "my_db_password" > secrets/db_password.txt 
echo "my_root_password" > secrets/db_root_password.txt 
echo "my_admin_password" > secrets/wp_admin_password.txt 
echo "my_user_password" > secrets/wp_password.txt
```

##### Basic Usage 

1. Run `make` at the root of the repository : it will prepare the host directories, build the images, and start the containers via *Docker Compose*.

2. Access the website :  
Due to the limitations of the development environment (headless VM, lack of sudo privileges on the physical machine), if you are testing from a campus 42's computer, you must force a DNS redirection to bypass the NAT. To do so, please type the following _from your physical machine's terminal_ :  
`google-chrome --incognito --host-resolver-rules="MAP csimonne.42.fr 127.0.0.1" "https://csimonne.42.fr:4443/wp-admin/"`   

	If it does not work, try clearing your browser's navigation history and cookies.  

		Note: You can replace 'google-chrome' with another Chromium-based browser prompt, but this specific DNS injection flag does not work with Firefox.
 
	_However_, if you have configured a graphical interface and a browser directly inside your VM, simply navigate to the standard URL without the forwarded port: `https://csimonne.42.fr/wp-admin/`

		disclaimer : In both cases, a security warning will appear due to the self-signed SSL/TLS certificate, which is expected.

3. Use `make stop` / `make start` (or `make restart`) for maintenance purposes and to test data persistence, `make down` to stop and remove containers, or `make fclean` to completely erase persistent volumes and data from the host.

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


## Resources

* Official documentation:
  - [Docker](https://docs.docker.com/)
  - [NGINX](https://nginx.org/en/docs/)
  - [MariaDB](https://mariadb.org/documentation/)
  - [WordPress](https://wordpress.org/documentation/)  

* Project guide / tutorial :   
https://devabdilah.medium.com/  
https://inception-42-a-comprehensive-guide-to-dockerizing-your-first-infrastructure-part-iii-a10e93e9d922

* AI Usage:  Artificial Intelligence was used to assist in structuring the project : as a step by step tutorial, to adapt some commands, find some execution scripts, understand concepts and ask questions.


## Design specifications and choices

**Docker Usage & Design Choices:**
Docker is utilized to containerize applications at the OS level, sharing the host's kernel instead of virtualizing hardware. This project employs a modular design where each service relies on custom initialization scripts (`entrypoint.sh`) to prepare the environment (as well as ensuring the main process remains in the foreground as PID 1).

* **Virtual Machines vs Docker:** Virtual Machines run a full guest operating system on top of virtualized hardware, making them heavy and resource-intensive. Docker containerizes applications at the OS level, sharing the host's kernel, which makes it significantly faster and more lightweight.

* **Secrets vs Environment Variables:** Environment variables are useful for general configuration (like domain names) but can be exposed if the container environment is inspected (via 'docker inspect' for instance, or through child process's error logs). Docker Secrets are used for sensitive data (like database passwords) because they are securely mounted directly into temporary files, keeping them hidden from the standard environment.

* **Docker Network vs Host Network:** Using the host network shares the host machine's network stack directly, which lacks isolation. This project uses a custom Docker Network to create an isolated internal bridge where containers communicate securely using internal DNS, exposing only port 443 to the outside world.

* **Docker Volumes vs Bind Mounts:** Bind mounts map a physical directory from the host directly into a container, while Docker Volumes are entirely managed by Docker within its internal storage. To satisfy the project's requirement of storing data physically in _/home/csimonne/data_, this infrastructure uses Named Volumes with a local driver pointing explicitly to the host's bind path, ensuring persistent data even if containers are destroyed.





