FROM thecodingmachine/php:8.1-v4-apache-node16 as base
ENV \
    # Disable default extensions (otherwise enabled by default)
    PHP_EXTENSION_PDO_MYSQL=0 \
    PHP_EXTENSION_MYSQLI=0 \
    PHP_EXTENSION_MYSQLND=0 \
    PHP_EXTENSION_SOAP=0 \
    PHP_EXTENSION_XSL=0 \
    # Enable extensions
    PHP_EXTENSION_PDO_PGSQL=1 \
    PHP_EXTENSION_PGSQL=1 \
    PHP_EXTENSION_GD=1 \
    APACHE_DOCUMENT_ROOT=public/
COPY --chown=docker:docker ./ /var/www/html/
EXPOSE 80

FROM base as dev
ARG SKIP_DEV_BUILD
RUN if [ -z ${SKIP_DEV_BUILD} ];then \
        composer install; \
    fi
#RUN npm install
#RUN npm run build

FROM base as prod
RUN composer install --optimize-autoloader --no-dev \
    && cp .env.example .env \
    && php artisan key:generate --force
# Change back Apache user and group to www-data
ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data
RUN sudo chgrp -R www-data storage bootstrap/cache \
    && sudo chmod -R ug+rwx storage bootstrap/cache
ENV \
    APP_NAME="Laravel Ganttastic" \
    APP_ENV=prod \
    APP_DEBUG=false \
    LOG_CHANNEL=stack \
    LOG_LEVEL=error
ENV \
    STARTUP_COMMAND_1="php artisan migrate --force -v" \
    STARTUP_COMMAND_2="php artisan config:cache"

