RED     = \033[0;31m
YELLOW  = \033[0;33m
RESET   = \033[0m

MAKEFLAGS += --no-print-directory
.DEFAULT_GOAL := all

# ========================================================== #
secure:
	@mkdir -p secrets
	@if [ -f srcs/.env ]; then chmod 600 srcs/.env; fi
	@if ls secrets/*.txt 1>/dev/null 2>&1; then chmod 600 secrets/*.txt; fi


# for data path
-include srcs/.env

all: secure
	@sudo mkdir -p $(DATA_PATH)/mariadb
	@sudo mkdir -p $(DATA_PATH)/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

re :
	docker compose -f srcs/docker-compose.yml up -d --build

#### -------- UNMOUNT --------  ####

down:
	docker compose -f srcs/docker-compose.yml down

#### -------- PLAY/PAUSE --------  ####

stop:
	@echo "Stopping containers (preserving state, named volumes and network)..."
	@docker compose -f srcs/docker-compose.yml stop

start:
	@echo "Starting existing containers without rebuilding..."
	@docker compose -f srcs/docker-compose.yml start

restart :
	@echo "Stopping and restarting containers (preserving state, named volumes and network)..."
	@docker compose -f srcs/docker-compose.yml restart

#### -------- DIAGNOSIS --------  ####

check:
	@read -p "Type one of those : [ports] [sql] [log] [status] [volumes] [images] [versions] [wp] [ip] or [clear] / [exit]: " ans; \
	case "$${ans:-N}" in \
		sql) \
			printf "\n\n$(RED) === Welcome to the SQL database connection center. ===  $(RESET)\n\n"; \
			printf "$(YELLOW)Once inside the database, type the following (including > ; sign) : $(RESET)\n"; \
			printf "SHOW DATABASES;\n"; \
			printf "USE $(MYSQL_DATABASE);\n"; \
			printf "SHOW TABLES;\n"; \
			printf "exit\n\n"; \
			printf "\n$(RED)=== Root connection to SQL ===$(RESET)\n"; \
			printf "$(YELLOW)(type Ctrl+C to force exit)$(RESET)\n\n"; \
			while ! docker compose -f srcs/docker-compose.yml exec mariadb mysql -u $(MYSQL_USER) -p; do \
				printf "\n$(RED)Mot de passe refusé. Nouvelle tentative...$(RESET)\n\n"; \
			done; \
			printf "$(RED)=== 2. Connexion with user and Database check===$(RESET)\n"; \
			printf "Once inside the database, type : (including > ; sign)\n"; \
			printf "SHOW DATABASES;\n"; \
			printf "USE $(MYSQL_DATABASE);\n"; \
			printf "SHOW TABLES;\n"; \
			printf "exit\n\n"; \
			docker compose -f srcs/docker-compose.yml exec mariadb mysql -u $(MYSQL_USER) -p ; \
			make check ;; \
		log) \
			read -p "Type [nginx] [mariadb] [wp] or [back]: " ans; \
			case "$${ans:-N}" in \
				nginx) \
					docker compose -f srcs/docker-compose.yml logs -f nginx ; make check ;; \
				wp) \
					docker compose -f srcs/docker-compose.yml logs -f wordpress ; make check ;; \
				mariadb) \
					docker compose -f srcs/docker-compose.yml logs -f mariadb ; make check ;; \
				back) \
					make check ;; \
				*) \
					echo "Unknown option: $${ans}" ;; \
			esac ;; \
		volumes) \
			echo "\n$(RED)=== 1. Named volumes registered in Docker ===$(RESET)\n"; \
			docker volume ls; \
			echo "\n$(RED)=== 2. Mounting point to host (/home/csimonne/data) === $(RESET)\n"; \
			docker volume inspect mariadb_data wordpress_data | grep -E "(device|Name)"; \
			echo "\n$(RED)=== 3. Files on Host === $(RESET)\n"; \
			echo "$(YELLOW)--- MariaDB ---$(RESET)"; \
			ls -la $(DATA_PATH)/mariadb; \
			echo "$(YELLOW)--- WordPress ---$(RESET)"; \
			ls -la $(DATA_PATH)/wordpress ; make check ;; \
		status) \
			echo "\n" ; docker compose -f srcs/docker-compose.yml ps ; echo "\n" ; make check ;; \
		images) \
			docker images ; make check ;; \
		versions) \
			echo "\n" ; grep -i "FROM" srcs/requirements/*/Dockerfile ; echo "\n" ; make check ;; \
		wp) \
			read -p "Type [user] [homepage] [adminpage] [httptest] [security] or [back]: " ans; \
			case "$${ans:-N}" in \
				user) \
					echo "\n" ; docker exec -it wordpress whoami; \
					docker compose -f srcs/docker-compose.yml exec wordpress wp user list --allow-root --path=/var/www/html ; make check ;; \
				homepage) \
					echo "\n https://csimonne.42.fr\n" ; make check ;; \
				adminpage) \
					echo "\n https://csimonne.42.fr/wp-admin" ; make check ;; \
				httptest) \
					printf "\n" ; \
					printf "\n==== Testing :  -kI http://csimonne.42.fr ====\n\n" ; \
					curl -I http://csimonne.42.fr ; \
					printf "\n==== Testing :  -kI https://csimonne.42.fr ====\n\n" ; \
					curl -kI https://csimonne.42.fr ;; \
				security) \
					echo "==== Checking TLS status : ====" ; \
					curl -kv https://csimonne.42.fr 2>&1 | grep -i "SSL connection using TLSv" ; make check ;; \
				back) \
					make check ;; \
				exit) \
					exit 0 ;; \
				*) \
					echo "$(RED)\n wrong command, try again or type : exit \n $(RESET)" ; make check ;; \
			esac ;; \
		ip) \
			echo "\n" ; hostname -I ; echo "\n" ; make check ;; \
		ports) \
			echo "\n$(RED)=== Scanning all 65.535 existing ports to display opened, closed or restricted. ===$(RESET)\n" ; \
			nmap -p- csimonne.42.fr  ;; \
		exit) \
			exit 0 ;; \
		clear) \
			clear ; make check ;;  \
		*) \
			echo "$(RED)\n wrong command, try again or type : exit\n $(RESET)" ; make check ;; \
	esac


#### -------- CLEANING --------  ####

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	sudo rm -rf $(DATA_PATH)*

re: fclean all

.PHONY: all down start stop clean fclean re
