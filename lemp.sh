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
#  configure firewall
echo -e "$Cyan \n backup ufw rules to file /root/rules.ufw $Color_Off"
sudo sed '/RULES/,/END RULES/!d' /etc/ufw/user{,6}.rules >> ~/rules.ufw_before

echo -e "$Cyan \n showing ufw rules $Color_Off"
sudo ufw status >> ~/status.ufw_before
sudo ufw status

echo -e "$Cyan \n enabling ufw to ssh incase connection goes down $Color_Off"
sudo ufw allow ssh && sudo ufw enable
sudo ufw allow 'Nginx HTTP'

echo -e "$Cyan \n showing ufw rules $Color_Off"
sudo ufw status

echo -e "$Cyan \n checking nginx is running now $Color_Off"

curl http://localhost

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
sudo apt install php-fpm php-mysql

# to install specifc version goes to this toutorial




