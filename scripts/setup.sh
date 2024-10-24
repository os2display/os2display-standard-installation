#! /bin/bash
apt-get update -qq -y
apt-get upgrade -qq -y
apt-get install -qq -y apache2 git

cd /etc/apt/sources.list.d/
rm php.list

cd /var/www
git clone https://github.com/os2display/os2display-standard-installation.git display

sudo apt install ca-certificates apt-transport-https software-properties-common lsb-release -y
curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x

apt-get update -qq -y
apt-get upgrade -qq -y

apt-get install -qq -y pwgen mariadb-server libapache2-mod-php vim certbot python3-certbot-apache redis-server redis-tools composer libapache2-mod-php git php8.3 libapache2-mod-php8.3 php8.3-gd php8.3-xml zip unzip php8.3-curl php-xml php8.3-mysql
apt-get install -qq -y mariadb-server

sudo a2enmod php8.3

sudo apt purge php8.2*
sudo a2enmod rewrite
sudo a2enmod ssl

systemctl restart apache2
chmod u+x /var/www/display/INSTALL.sh

