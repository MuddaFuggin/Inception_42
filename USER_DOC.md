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