#!/bin/sh

#######################################
# Bash script to install an AMP stack and PHPMyAdmin plus tweaks. For Debian based systems.
# Written by @AamnahAkram from http://aamnah.com

# In case of any errors (e.g. MySQL) just re-run the script. Nothing will be re-installed except for the packages with errors.
#######################################

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

## Update packages and Upgrade system
echo -e "$Cyan \n Updating System.. $Color_Off"
sudo apt-get update -y && sudo apt-get upgrade -y
#
### Install  Apache2, MySQL, PHP
#echo -e "$Cyan \n  Apache2, MySQL, PHP $Color_Off"
#sudo apt install apache2 mysql-server php php-mysql libapache2-mod-php php-cli
#
#echo -e "$Cyan \n Installing phpMyAdmin $Color_Off"
#sudo apt-get install phpmyadmin -y
#
#echo -e "$Cyan \n Verifying installs$Color_Off"
#sudo apt install apache2 mysql-server php php-mysql libapache2-mod-php php-cli phpmyadmin

# Install the tasksel package
echo -e "$Cyan \n Install the tasksel package $Color_Off"
sudo apt install tasksel -y

# Install LAMP using tasksel
echo -e "$Cyan \n Install LAMP using tasksel $Color_Off"
sudo tasksel install lamp-server

# install php modules
for mod in $(apt-cache search ^php- | grep module | awk '{print $1}') ;
do
  echo "Installing module $mod ... " ; sudo apt install $mod -y ;
done


# Configure LAMP (Linux Apache MySQL and PHP)

#sudo mysql_secure_installation

# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('RootSQLpass') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"

#  configure firewall
echo -e "$Cyan \n backup ufw rules to file /root/rules.ufw $Color_Off"
sudo sed '/RULES/,/END RULES/!d' /etc/ufw/user{,6}.rules >> /root/rules.ufw

echo -e "$Cyan \n showing ufw rules $Color_Off"
sudo ufw status
echo -e "$Cyan \n enabling ufw to ssh incase connection goes down $Color_Off"
sudo ufw allow ssh && sudo ufw enable
sudo ufw allow in "Apache Full"

echo -e "$Cyan \n showing ufw rules $Color_Off"
sudo ufw status

## TWEAKS and Settings
# Permissions
echo -e "$Cyan \n Permissions for /var/www $Color_Off"
sudo chown -R www-data:www-data /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
echo -e "$Cyan \n Enabling Modules $Color_Off"
sudo a2enmod rewrite
sudo php5enmod mcrypt

# Allow to run Apache on boot up
sudo systemctl enable apache2

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo systemctl restart apache2

# Create info.php for testing php processing
echo -e "$Cyan \n Create info.php for testing php processing $Color_Off"
sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Verify LAMP Installation
echo -e "$Cyan \nVerify LAMP Installation $Color_Off"

curl http://localhost/info.php | grep head
ipadd=`ip addr show eth0 | grep inet | awk '{ print $2; }'|head -1 | sed 's/\/.*$//'`

echo "you can test on http://$ipadd/info.php"

## Open localhost in the default browser
#echo -e "$Cyan \n Open localhost in the default browser"
#xdg-open "http://localhost"
#xdg-open "http://localhost/info.php"

# to enable module php-FPM with apache2 you need to enable module as below

# reference
# https://www.linuxbabe.com/linux-server/install-apache-mariadb-and-php7-lamp-stack-on-ubuntu-16-04-lts
# sudo a2enmod proxy_fcgi
# you need to change apache configuration to
# sudo nano /etc/apache2/sites-available/000-default.conf
# ErrorLog ${APACHE_LOG_DIR}/error.log
#CustomLog ${APACHE_LOG_DIR}/access.log combined
#ProxyPassMatch ^/(.*\.php(/.*)?)$ unix:/run/php/php7.0-fpm.sock|fcgi://localhost/var/www/html/

## then restart apache2
#sudo systemctl restart apache2
#
#Start php7.0-fpm
#
#sudo systemctl start php7.0-fpm
#
#Enable php7.0-fpm to start at boot time.
#
#sudo systemctl enable php7.0-fpm
#
#Check status:
#
#systemctl status php7.0-fpm