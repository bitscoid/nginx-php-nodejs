FROM node:current-alpine3.18 AS nodejs
FROM bantenitsolutions/nginx-php

LABEL Maintainer="Nurul Imam <bits.co.id>" \
    Description="Nginx 1.25, PHP 8.3 & NodeJS 21.4 with essential php extensions on top of latest Alpine Linux."

LABEL org.opencontainers.image.vendor="Nurul Imam" \
    org.opencontainers.image.url="https://github.com/bitscoid/nginx-php-nodejs" \
    org.opencontainers.image.source="https://github.com/bitscoid/nginx-php-nodejs" \
    org.opencontainers.image.title="Nginx, PHP & NodeJS of Alpine" \
    org.opencontainers.image.description="Nginx 1.25, PHP 8.3 & NodeJS 21.4 with essential php extensions on top of latest Alpine Linux." \
    org.opencontainers.image.version="2.0" \
    org.opencontainers.image.documentation="https://github.com/bitscoid/nginx-php-nodejs"

WORKDIR /var/www/bits

COPY --from=nodejs /opt /opt
COPY --from=nodejs /usr/local /usr/local

EXPOSE 80 443

# Script Installation
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Run Script
CMD ["/run.sh"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1