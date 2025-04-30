#!/bin/bash


#---
# Setting verions to be used in this upgrade
#---
ADMIN_VERSION=2.4.0
API_VERSION="Latest 2.4.0"
CLIENT_VERSION=2.1.2

printf "\nThe following versions will be installed in this update\n"
printf "\nAdmin = $ADMIN_VERSION \nApi = $API_VERSION \nClient = $CLIENT_VERSION \n\n"

# Making sure all files are owned by www-data
# TODO - find the webserver user in the system and use that
chown -R www-data: /var/www/$1/public_html

# Getting comand line argument no 1
IFS='.' read -r -a array <<< $1

if [ -z $1 ]; then 
	printf "
	No domain name given\n
	Usage: ./UPDATE.sh your.domanin.com\n
	For further help type ./UPDATE.sh help\n\n"
	exit
fi
if [ "$1" = "help" ]; then 
	printf "
	Help section\n
	For further help type ./INSTALL.sh help
	For system info and version type ./INSTALL.sh info
	For OS2display management type ./INSTALL.sh display\n\n"
	exit
fi

# Creating backup folder if it does not exist
BACKUP_FOLDER=/var/www/backup
if [ -d "$BACKUP_FOLDER" ]; then
    	printf "Backup directory already exists in $BACKUP_FOLDER.\n"
else
	mkdir $BACKUP_FOLDER
	printf "\nBackup directory created in $BACKUP_FOLDER.\n"
fi

# Loading DB password. If the file has been removed you will be promptet for the root password
mapfile -t a < /var/www/$1/db.txt
declare "${a[@]}"

# Backing up the database if it exists
mysql=$(mysql -u root -e 'show databases;')
check_db=${1//./_}

if [[ $mysql == *"$check_db"* ]]; then
	read -p "Do you want to backup the database and files before update (y/n) ?" -n 1 -r
if [[ $REPLY =~ ^[Nn]$ ]]
	then
		exit
	else
		mysql=$(mysqldump -u root -p$DBPASS $check_db > $BACKUP_FOLDER/$check_db.sql)
		printf "\nDatabase has been backed up into $BACKUP_FOLDER"
		cp -R /var/www/$1 $BACKUP_FOLDER/ 
		printf "\nDocument root has been backed up into $BACKUP_FOLDER\n"
		
	fi	
fi

# Stashing files in git before git pull
cd /var/www/$1/public_html
git config --global --add safe.directory /var/www/$1/public_html
git stash
git pull
rm -rf migrations/Version2022*
rm -rf migrations/Version2023*
rm -rf migrations/Version20240110091802.php
rm -rf migrations/Version20240116162235.php
rm -rf migrations/Version20240221142818.php
rm -rf migrations/Version20240225055224.php
rm -rf migrations/Version20240403043527.php
chown -R www-data: /var/www/$1/public_html

# Composer install
cd /var/www/$1/public_html
#sudo -u www-data composer require symfony/flex
sudo -u www-data composer require predis/predis
sudo -u www-data composer install --optimize-autoloader --no-interaction
#sudo -u www-data composer -n --no-plugins require predis/predis
#sudo -u www-data composer -n --no-plugins install --optimize-autoloader
#sudo -u www-data composer install --no-interaction
sudo -u www-data php bin/console do:mi:status
sudo -u www-data php bin/console doctrine:migration:migrate latest

# Moving install scripts
#cp /var/www/display/scripts/install_templates.sh /var/www/$1/public_html/
#cp /var/www/display/scripts/install_layouts.sh /var/www/$1/public_html/
#cp /var/www/display/scripts/install_feeds.sh /var/www/$1/public_html/

#---
# OS2display client
#---

# Cloning the OS2display client into ./public_html/client 
cd /var/www/$1/public_html
wget -q https://github.com/os2display/display-client/releases/download/$CLIENT_VERSION/display-client-$CLIENT_VERSION.tar.gz
tar -xzf display-client-$CLIENT_VERSION.tar.gz
rm display-client-$CLIENT_VERSION.tar.gz

chown -R www-data: client/

# Setup of the client configuration
#cd /var/www/$1/public_html/client
#cp example_config.json config.json
#chown -R www-data: config.json
#sed -i 's/os2display.example.org/'$1'/g' config.json
#echo $1 ' Has been added to config.json' 


#---
# OS2display sdmin client
#---

# Cloning the OS2display admin client into ./public_html/admin
cd /var/www/$1/public_html
wget -q https://github.com/os2display/display-admin-client/releases/download/$ADMIN_VERSION/display-admin-client-$ADMIN_VERSION.tar.gz
tar -xzf display-admin-client-$ADMIN_VERSION.tar.gz
rm display-admin-client-$ADMIN_VERSION.tar.gz
chown -R www-data: admin/

# Setup of the admin client configuration
#cd /var/www/$1/public_html/admin
#cp example_config.json config.json
#cp example-access-config.json access-config.json 
#chown -R www-data: config.json
#chown -R www-data: access-config.json

# File that has been changed and needs a patch - planned
#cp /var/www/display/patch/Media.php /var/www/$1/public_html/src/Entity/Tenant/Media.php 


# Running Symfony install commands for templates and layouts.
chown -R www-data: /var/www/$1
cd /var/www/$1/public_html
./install_templates.sh
./install_layouts.sh

