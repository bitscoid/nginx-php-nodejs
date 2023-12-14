#!/bin/sh

# Set Custom Webroot
if [ ! -z "$WEBROOT" ]; then
 sed -i "s#root /var/www/bits;#root ${WEBROOT};#g" /etc/nginx/http.d/default.conf
else
 WEBROOT=/var/www/bits
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
 sed -i "s/memory_limit = 1024M/memory_limit = ${PHP_MEM_LIMIT}M/g" /usr/local/etc/php/php.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
 sed -i "s/post_max_size = 64M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /usr/local/etc/php/php.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
 sed -i "s/upload_max_filesize = 64M/upload_max_filesize= ${PHP_UPLOAD_MAX_FILESIZE}M/g" /usr/local/etc/php/php.ini
fi

# Use redis as session storage
if [ ! -z "$REDIS_HOST" ]; then
 sed -i "s/session.save_handler = files/session.save_handler = redis/g" /usr/local/etc/php/php.ini
 sed -i "s/;session.save_path = "/tmp"/;session.save_path = "tcp:\/\/'${REDIS_HOST}':6379"/g" /usr/local/etc/php/php.ini
fi

# Run Composer & NodeJS
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
  if [ -d "/var/www/bits/" ]; then
    composer install && composer update && npm install && npm run dev
  else
    echo "Can't find script directory"
  fi
fi


# change ownership to user=nobody, group=nobody
chown -R nobody:nobody /var/www/bits /run /var/lib/nginx /var/log/nginx /usr/local/bin/composer /etc/nginx/http.d /usr/local/etc/php

# open with sudo a new shell as user nobody and call your application
su nobody -s /bin/sh

# Let supervisord start Nginx & PHP-FPM
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf