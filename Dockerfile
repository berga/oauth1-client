# FROM composer:1.10 as build
# COPY composer.json .
# RUN composer update

FROM php:8-alpine
LABEL Name=oauth1client Version=0.0.1

RUN apk add php7-apache2 php7-session composer

WORKDIR /app

COPY composer.json .
RUN composer update

COPY . .
RUN mkdir public && \
  cp -r resources/examples public/ && \
  sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/public\"#g" /etc/apache2/httpd.conf && \
  sed -i "s#/var/www/localhost/htdocs#/app/public#" /etc/apache2/httpd.conf && \
  printf "\n<Directory \"/app/public\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf && \
  printf "\nPassEnv endpoint callbackuri clientid clientsecret\n" >> /etc/apache2/httpd.conf && \
  cp php.ini-development /etc/php7/php.ini

# COPY --from=build /app/vendor vendor

EXPOSE 80 443

CMD ["httpd", "-DFOREGROUND"]