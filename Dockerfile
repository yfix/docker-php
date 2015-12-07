FROM yfix/baseimage

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/

RUN echo "deb http://ppa.launchpad.net/ondrej/php-7.0/ubuntu trusty main" > /etc/apt/sources.list.d/php-7.0.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
  \
  && apt-get update \
  \
  && apt-cache search php- 2>&1 \
  && apt-cache search php7 2>&1 \
  \
  && apt-get install -y \
    php7.0 \
    php7.0-cli \
    php7.0-curl \
    php7.0-fpm \
    php7.0-gd \
    php7.0-intl \
    php7.0-mysql \
    php7.0-sqlite3 \
    php7.0-dev \
#    php7.0-pear \
#    php7.0-geoip \
#    php7.0-imagick \
#    php7.0-memcache \
#    php7.0-xcache \
#    php7.0-xdebug \
    libyaml-dev \
    wget \
    curl \
    git \
  \
&& echo "========="

RUN echo "========" \
  && phpdismod opcache \
  && phpdismod xdebug \
  \
  && cd /tmp && wget http://pear.php.net/go-pear.phar \
  && php go-pear.phar \
  \
  && (yes '' | pecl install geoip) \
  && echo "extension=geoip.so" > /etc/php/7.0/mods-available/geoip.ini \
  && phpenmod geoip \
  \
  && (yes '' | pecl install yaml) \
  && echo "extension=yaml.so" > /etc/php/7.0/mods-available/yaml.ini \
  && phpenmod yaml \
  \
  && (yes '' | pecl install channel://pecl.php.net/xhprof-0.9.4) \
  && echo "extension=xhprof.so" > /etc/php/7.0/mods-available/xhprof.ini \
  && phpenmod xhprof \
&& echo "========="

RUN echo "========" \
  && php -v 2>&1 \
  && php -m 2>&1 \
  && php --ini 2>&1 \
  \
  && find / -name "php*" \
  && find / -name "pear*" \
  && find / -name "pecl*" \
  && find / -name "phpize*" \
  && find / -name "pyrus*" \
  \
&& echo "========="

RUN echo "========" \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

COPY container-files /

EXPOSE 9000
