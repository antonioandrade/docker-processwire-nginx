#!/bin/sh
/usr/bin/mysqld_safe &
    sleep 10s
    service mysql start

if ! [ -d "/usr/share/nginx/www/site" ]; then
    DB_NAME="processwire"
    DB_USER="processwire"
    DB_ROOT_PASSWORD=`pwgen -c -n -1 12`
    DB_PASSWORD=`pwgen -c -n -1 12`

    # MySQL
    echo ""
    echo "========================================================================"
    echo "Setting up MySql permissions"
    echo ""
    mysqladmin -u root password $DB_ROOT_PASSWORD
    mysql -uroot -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$DB_ROOT_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql -uroot -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql -uroot -p$DB_ROOT_PASSWORD -e "CREATE DATABASE $DB_NAME; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"

    echo "========================================================================"
    echo ""
    echo "    Access Information for MySQL Server"
    echo ""
    echo "    MySQL Database: $DB_NAME"
    echo "    MySQL Root Password: $DB_ROOT_PASSWORD"
    echo "    MySQL User: $DB_USER"
    echo "    MySQL Password: $DB_PASSWORD"
    echo ""
    echo "========================================================================"
    echo ""

    # Composer
    echo ""
    echo "========================================================================"
    echo "Installing Composer"
    echo ""
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

    # Wireshell
    echo "========================================================================"
    echo "Installing Wireshell"
    echo ""
    php -d memory_limit=-1 /usr/local/bin/composer global require wireshell/wireshell
    export PATH="$HOME/.composer/vendor/bin:$PATH"
    cd /usr/share/nginx
    wireshell new --dbUser $DB_USER --dbPass $DB_PASSWORD --dbName $DB_NAME --dbHost localhost --username admin --userpass password --useremail email@domain.com --profile classic --adminUrl admin www
    php -d memory_limit=-1 /usr/local/bin/composer global remove wireshell/wireshell
    rm -rf /usr/local/bin/composer
    rm -rf ~/.composer
    chown -R www-data:www-data /usr/share/nginx/www
    usermod -u 1000 www-data

    echo "========================================================================"
    echo ""
    echo "    Access Information for Processwire"
    echo ""
    echo "    Username: admin"
    echo "    Password: password"
    echo "    Admin URL: /admin"
    echo ""
    echo "========================================================================"
    echo ""
fi

# Supervisor
/usr/local/bin/supervisord -n