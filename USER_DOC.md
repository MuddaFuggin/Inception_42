# "Welcome to the user documentation for your Docker-powered WordPress infrastructure."

### A brief Description of the services provided by the stack :

This infrastructure provides a fully functional WordPress website backed by a secure and isolated stack. The system runs inside a Debian Virtual Machine and is composed of three dedicated Docker containers:

* NGINX: The web server that acts as the sole secure entry point, receiving all external HTTPS requests.

* WordPress: The application container that executes the PHP code to run the website.

* MariaDB: The database container responsible for SQL storage, containing all user accounts and site data.

_To comply with strict security requirements, no passwords or sensitive data are stored in plain text within the .env file or configuration scripts. Instead, all database and administrator credentials are securely managed using Docker Secrets. These secrets are stored locally on the host and injected directly into the containers' memory (at /run/secrets/) at runtime, ensuring they remain completely isolated, hidden, and never exposed in the repository._

****


#### Your First Launch :

1. Ensure your environment variables are configured in `srcs/.env`.You can create your `.env` based on the `.env.example` provided.
(access : `cd ~/Inception_42/srcs && ls -la`, create _.env_ and modify it : `cp .env.example .env`)
2. Create your local passwords as text files inside the `secrets/` directory. To do so, use the following blueprint and add your personal credentials in place of ["my_db_password"] and the 3 other credentials. Once edited, submit it in bash.

```bash
echo "my_db_password" > ~/Inception_42/secrets/db_password.txt 
echo "my_root_password" > ~/Inception_42/secrets/db_root_password.txt 
echo "my_admin_password" > ~/Inception_42/secrets/wp_admin_password.txt 
echo "my_user_password" > ~/Inception_42/secrets/wp_password.txt
```
3. Run `make` at the root of the repository : it will prepare the infrastructure. When done, your engine is running !.

#### Basic commands > starting, stopping :

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
