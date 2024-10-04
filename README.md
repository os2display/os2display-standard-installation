# OSdisplay
Os2display install profile without docker
If you are looking for the older (debrecated) docker setup go [here](https://github.com/os2display/os2display-docker-compose)

Se usefull links and latest changes at the buttom of the readme file. 

## How to install OS2display (a valid domain is neede for SSL)
This installation has been tested for Debian 12 server version and Ubuntu 24.04 server version. 
Both should work on the Desktop version as well. 

### Installation needs
- Server: Debain 12 or Ubuntu 24.04
- Root or sudo access
- A valid dns name that points to the ip address of your server

### Installation - step 1 - Server components
Issue the commands below and the needed server components will be installed  

(You can copy and paste all commands - except sudo - in one copy past to a terminal - they will execute after each other)

```bash
sudo -s
rm -rf /var/setup.sh
wget -P /var https://raw.githubusercontent.com/os2display/os2display-standard-installation/main/scripts/setup.sh
chmod a+x /var/setup.sh
cd /var
./setup.sh
```

### Installation - step 2 - OS2display
Issue the commands below to install OS2display and follow the instructions

DB credentials are saved in /var/www/[your_domain]
```bash
cd /var/www/display
./INSTALL.sh your-domain
```

### Installation - step 3 - Using Lets encrypt - Certbot for SSL
Lets encrypt needs a valid domain. As does this installation. :-)

Lets encrypt could be blocked by your domain owner

To install via lets encrypt with a valid domain for your server do (follow instructions): 


```bash
certbot
```
## Access to OS2display
The installation can be accessed via these URL's
- API: [your.domain.dk]/
- Client: [your.domain.dk]/client
- Admin: [your.domain.dk]/admin (use the user created from the installation)

### OS2display / symfony management
The INSTALL.sh scripts helps with creating a tenant, admin user, templates, screens and feeds 
For help on creating more of these type ./INSTALL.sh display (Not implemented yet)

Also look at the install scripts in ./public_html

## Latest changes
https://os2web.atlassian.net/browse/S2DSPL-45

1. Get the right composer.json file when installing. (no prompt)
2. Removing bindings to vendor server
3. Removing bindings to vendor github repo
4. Better installation / fix of RSS feeds - added seperate install.sh for feeds
5. Fixing apt installation error regarding to PHP
6. Documenting setup of SSL without certbot - added cert generation script for apache and link for doing it for nginx

## TODO
1. Install Symfony as non root user 
2. Display help info in INSTALL.sh
3. Descruption on how to update - or make an update script.

## LINKS
Symfony for Apache configuration: https://symfony.com/doc/current/setup/web_server_configuration.html
 
