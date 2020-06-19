#!/bin/sh

MYSQL_ROOT_PASS=rOoT@Pass89

# install LEMP server , linux nginx mysql php server
# wiht nginx , no need to install PHP-FPM like apache2 , is installed by default

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

sudo apt install nginx -y

echo -e "$Cyan \n installing MySQL server and client  $Color_Off"

sudo apt install mysql-server mysql-client -y

#you can install mariaDB in this point
#sudo apt install mariadb-server mariadb-client -y
#
#curl -fsSL https://raw.githubusercontent.com/Pishoy/automated_scripts/master/secure_mysql_maria.sh?token=AFHYBFLPWD5RITG6I6CD7IS65SOD2 >> secure_mysql_maria.sh
#bash secure_mysql_maria.sh $MYSQL_ROOT_PASS

sudo mysql_secure_installation
# it depend on cloud provider , assume you are using DO
echo -e "$Cyan \n installing php-fpm and php-mysql   $Color_Off"

sudo add-apt-repository universe -y
sudo apt install php-fpm php-mysql -y

# to install specifc version goes to this toutorial
# https://www.linuxbabe.com/ubuntu/install-lemp-stack-nginx-mariadb-php7-2-ubuntu-18-04-lts

echo -e "$Cyan \n enable nginx in boot $Color_Off"

sudo systemctl enable nginx

echo -e "$Cyan \n checking nginx is running now $Color_Off"

curl http://localhost

# create example.com

curl -fsSL https://raw.githubusercontent.com/Pishoy/automated_scripts/master/example.com >> /etc/nginx/sites-available/example.com
sudo unlink /etc/nginx/sites-enabled/default
# if you need to restore default file
# sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

echo -e "$Cyan \n checking nginx config $Color_Off"

sudo nginx -t
sudo systemctl reload nginx

# Create info.php for testing php processing
echo -e "$Cyan \n Create info.php for testing php processing $Color_Off"
sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php


echo -e "$Cyan \n restart nginx $Color_Off"

sudo systemctl start nginx

# Verify LAMP Installation
echo -e "$Cyan \nVerify LAMP Installation ,checking php serving $Color_Off"

curl http://localhost/info.php | grep head
ipadd=`ip addr show eth0 | grep inet | awk '{ print $2; }'|head -1 | sed 's/\/.*$//'`

echo "you can test on http://$ipadd/info.php"


#  configure firewall

echo -e "$Cyan \n showing ufw rules $Color_Off"
sudo ufw status

echo -e "$Cyan \n backup ufw rules to file /root/rules.ufw $Color_Off"
sudo sed '/RULES/,/END RULES/!d' /etc/ufw/user{,6}.rules >> ~/rules.ufw_before

echo -e "$Cyan \n showing ufw rules $Color_Off"
sudo ufw status >> ~/status.ufw_before
sudo ufw status

echo -e "$Cyan \n enabling ufw to ssh incase connection goes down $Color_Off"
sudo ufw allow 'Nginx HTTP'

echo -e "$Cyan \n please check ufw rules my you need to run below $Color_Off"

echo "sudo ufw allow ssh && sudo ufw enable"


