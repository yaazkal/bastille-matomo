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
if [ ! -e /root/.my.pass ]; then
    echo "[INFO] Securing MariaDB"
    yes | mysql_secure_installation >/dev/null 2>&1
    RANDOM_PASSWORD=$(openssl rand -base64 15)
    mysql -u root -pyes -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${RANDOM_PASSWORD}';"
    cat << EOF > /root/.my.cnf
[client]
user=root
password=${RANDOM_PASSWORD}
EOF
    echo "[INFO] Check /root/.my.cnf for the root password of the database server if needed"
fi

# Cleanup
rm /root/bootstrap_matomo.sh
