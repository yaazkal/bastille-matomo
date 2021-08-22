#!/bin/sh
# Copyright © 2021 Juan David Hurtado G <jdhurtado@orbiware.com>

# Downloads matomo
echo "[INFO] Downloading matomo"
fetch -q -o /tmp/matomo.zip https://builds.matomo.org/matomo.zip
# Unzip the file
echo "[INFO] Extracting matomo"
unzip -q -u -d /usr/local/www /tmp/matomo.zip
# Set permissions
chown -R www:www /usr/local/www/matomo

# Ensure MariaDB runs securely -- @yaazkal
if [ ! -e /root/.my.cnf ]; then
    echo "[INFO] Securing MariaDB"
    yes | mysql_secure_installation >/dev/null 2>&1
    RANDOM_PASSWORD=$(openssl rand -hex 15)
    mysql -u root -pyes -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${RANDOM_PASSWORD}';"
    cat << EOF > /root/.my.cnf
[client]
user=root
password=${RANDOM_PASSWORD}
EOF
    echo "[INFO] /root/.my.cnf created"
fi

# Create database and user if needed
if [ ! $(mysql -e "SELECT user FROM mysql.user WHERE user='matomo';" | awk "/^matomo$/") ]; then
    JAIL_IP=$(ifconfig | grep "inet" | awk '{ print $2 }')
    DB_PASSWORD=$(openssl rand -hex 15)
    echo "[INFO] Creating matomo database"
    mysql -e "CREATE DATABASE IF NOT EXISTS matomo;"
    echo "[INFO] Creating matomo user in MariaDB"
    mysql -e "CREATE USER IF NOT EXISTS 'matomo'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
    echo "[INFO] Grant permissions to matomo user"
    mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, DROP, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON matomo.* TO 'matomo'@'localhost';"
    echo "[INFO] Grant FILE global privilege to matomo user"
    mysql -e "GRANT FILE ON *.* TO 'matomo'@'localhost';"
    echo ""
    echo "[WARN] Please go to ${JAIL_IP} in order to finish the Matomo installation"
    echo "[INFO] Database server: /var/run/mysql/mysql.sock"
    echo "[INFO] Database user: matomo"
    echo "[INFO] Database password: ${DB_PASSWORD}"
fi

# Cleanup
rm /root/bootstrap_matomo.sh
