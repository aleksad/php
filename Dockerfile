FROM php:5.4-apache

ENV APPLICATION_ENV production

RUN apt-get update
RUN apt-get install -y g++ 

# pour ext intl
RUN apt-get install -y libicu-dev
RUN docker-php-ext-install intl

# pour ext imap
RUN apt-get install -y openssl
RUN apt-get install -y libc-client-dev
RUN apt-get install -y libkrb5-dev 
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install dom

RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libgd-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr
# exif pour gregwar/image ?
RUN docker-php-ext-install gd exif

RUN docker-php-ext-install mysql mysqli pdo pdo_mysql 

RUN apt-get install -y libmcrypt-dev
RUN docker-php-ext-install mcrypt

RUN docker-php-ext-install gettext mbstring soap

# Pour C&P
RUN docker-php-ext-install zip

RUN docker-php-ext-install ftp

# pour ext ldap
# RUN apt-get install -y libldap2-dev
# RUN docker-php-ext-configure ldap --prefix=/usr/local/php --with-ldap=/usr/lib/i386-linux-gnu
# RUN docker-php-ext-install ldap

# ext curl pour elasticsearch
RUN apt-get install -y libcurl4-openssl-dev
RUN docker-php-ext-install curl

# APC
COPY ./php.ini /usr/local/etc/php/php.ini
RUN pear config-set php_ini /usr/local/etc/php/php.ini
RUN pecl config-set php_ini /usr/local/etc/php/php.ini
RUN pecl install apc

RUN a2enmod rewrite

# PhantomJS
ENV PHANTOMJS_VERSION 1.9.7
RUN \
  apt-get install -y libfreetype6 libfontconfig bzip2 && \
  mkdir -p /srv/var && \
  curl -s -o /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
  rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
  ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs
  
RUN apt-get autoremove -y && apt-get clean all
  
VOLUME ["/u"]
VOLUME ["/var/log"]

COPY apache2.development.conf /etc/apache2/apache2.development.conf
COPY apache2.production.conf /etc/apache2/apache2.production.conf

CMD apache2 -DFOREGROUND -f /etc/apache2/apache2.$APPLICATION_ENV.conf
