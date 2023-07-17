#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade
sudo apt autoremove
echo "Install LAMP with MariaDB | LAMPM Server"
sudo apt install -y php php-apcu php-bcmath php-cli php-common php-curl php-gd php-gmp php-imagick php-intl php-mbstring php-mysql php-zip php-xml mariadb-server
echo "Secure MariaDB Server"
sudo mysql_secure_installation
echo "Enable required Apache and PHP mods"
sudo phpenmod bcmath gmp imagick intl
echo "Create new user for Cloud Database"
# Prompt for new user details
read -p "Enter username for the new user: " username
read -s -p "Enter password for the new user: " password
# Prompt for new database name
read -p "Enter name for the new database: " dbname
# Log in to MariaDB as root (assuming root user has sufficient privileges)
sudo mariadb <<EOF
CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON *.* TO '${username}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE ${dbname};
EOF
echo "Install PhpMyAdmin"
sudo apt install -y phpmyadmin
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
echo "Installing unzip"
sudo apt install -y unzip
echo "Download NextCloud zip file"
wget https://download.nextcloud.com/server/releases/latest.zip
echo "Unzip NextCloud zip file"
unzip latest.zip
echo "Remove NextCloud zip file"
rm latest.zip
echo "Moving the nextcloud folder in the Apache2 instance /var/www/"
# Move the Nextcloud folder to the newly created folder
sudo mv nextcloud /var/www
echo "Give permission to www-data"
sudo chown -R www-data:www-data /var/www/nextcloud
echo "Disable default host page on Apache2"
sudo a2dissite 000-default.conf
sudo touch /var/log/apache2/nextcloud_access.log
sudo touch /var/log/apache2/nextcloud_error.log
echo "Set up a config file for Apache that tells it how to serve Nextcloud."
wget https://raw.githubusercontent.com/George-Atmatsidis/Nextcloud-Installation-Script-for-Ubuntu/main/nextcloud.conf
sudo mv nextcloud.conf /etc/apache2/sites-available
echo "Enable the site"
sudo a2ensite nextcloud.conf
echo "Configuring PHP /etc/php/8.1/apache2/php.ini"
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 200M/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/max_execution_time = .*/max_execution_time = 360/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 200M/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;date.timezone =/date.timezone = Europe\/Athens/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;opcache.enable=1/opcache.enable=1/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;opcache.memory_consumption=.*/opcache.memory_consumption=128/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;opcache.save_comments=.*/opcache.save_comments=1/' /etc/php/8.1/apache2/php.ini
sudo sed -i 's/;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/' /etc/php/8.1/apache2/php.ini
echo "Restart Apache2"
sudo systemctl restart apache2
