FROM php:7.3.9-fpm-alpine3.10

RUN apk update && apk upgrade

# add postgresql extensions
RUN set -ex && apk --no-cache add postgresql-dev
RUN docker-php-ext-install pdo pdo_pgsql pgsql
