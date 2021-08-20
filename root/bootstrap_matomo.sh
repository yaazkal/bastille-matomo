#!/bin/sh
# Downlads matomo
echo "[INFO] Downloading matomo"
fetch -q -o /tmp/matomo.zip https://builds.matomo.org/matomo.zip
# Unzip the file
echo "[INFO] Extracting matomo"
unzip -q -u -d /usr/local/www /tmp/matomo.zip
# Set permissions
chown -R www:www /usr/local/www/matomo
# Cleanup
rm /root/bootstrap_matomo.sh
