RED     = \033[0;31m
YELLOW  = \033[0;33m
RESET   = \033[0m

MAKEFLAGS += --no-print-directory

# ========================================================== #
secure:
	@mkdir -p secrets
	@if [ -f srcs/.env ]; then chmod 600 srcs/.env; fi
	@if ls secrets/*.txt 1>/dev/null 2>&1; then chmod 600 secrets/*.txt; fi

# for data path
-include srcs/.env

all: secure
	@mkdir -p $(DATA_PATH)/mariadb # because host dir must exist before docker starts
	@mkdir -p $(DATA_PATH)/wordpress # because host dir must exist before docker starts
	@printf "\n$(RED)===*^* 1. Composition of Docker will launch in ... *^*===$(RESET)\n\n"
	@sleep 1
	@echo "3..."
	@sleep 1
	@echo "2..."
	@sleep 1
	@echo "1..."
	@sleep 1
	docker compose -f srcs/docker-compose.yml up -d --build

re :
	docker compose -f srcs/docker-compose.yml up -d --build

#### -------- UNMOUNT --------  ####

down:
	docker compose -f srcs/docker-compose.yml down

#### -------- PLAY/PAUSE --------  ####

stop:
	@echo "Stopping containers (preserving state and network)..."
	@docker compose -f srcs/docker-compose.yml stop

start:
	@echo "Starting existing containers without rebuilding..."
	@docker compose -f srcs/docker-compose.yml start

instructions:
	./instructions.sh;
# REMOVE this last one after DEVELOPPING !!!

#### -------- DIAGNOSIS --------  ####

check:
	@read -p "Type one of those : [log] [status] [volumes] [user] [images] [versions] [wp] [ip] or [clear] / [exit]: " ans; \
	case "$${ans:-N}" in \
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
		user) \
			echo "\n" ; docker exec -it wordpress whoami; \
			docker compose -f srcs/docker-compose.yml exec wordpress wp user list --allow-root --path=/var/www/html ; make check ;; \
		images) \
			docker images ; make check ;; \
		versions) \
			echo "\n" ; grep -i "FROM" srcs/requirements/*/Dockerfile ; echo "\n" ; make check ;; \
		wp) \
			read -p "Type [homepage] [adminpage] [http] [tls] or [back]: " ans; \
			case "$${ans:-N}" in \
				homepage) \
					echo "\n https://csimonne.42.fr\n" ; make check ;; \
				adminpage) \
					echo "\n https://csimonne.42.fr/wp-admin" ; make check ;; \
				http) \
					curl -kI https://csimonne.42.fr ; make check ;; \
				tls) \
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
		exit) \
			exit 0 ;; \
		clear) \
			clear ; make check ;;  \
		*) \
			echo "$(RED)\n wrong command, try again or type : exit\n $(RESET)" ; make check ;; \
	esac



#### -------- CLEANING --------  ####

#clean:
 #	@read -p : "Are you sure you want to erase all volumes and data ? [y/N]" ans && [ $${ans:-N} = y ]
#	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	sudo rm -rf $(DATA_PATH)*

re: fclean all

.PHONY: all down start stop clean fclean re
