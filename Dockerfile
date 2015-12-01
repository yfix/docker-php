FROM yfix/baseimage

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/

RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" > /etc/apt/sources.list.d/php56.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
  \
  && apt-get update && apt-get install -y \
    php5 \
    php5-cli \
    php5-curl \
    php5-fpm \
    php5-gd \
    php5-geoip \
    php5-gmp \
    php5-imagick \
    php5-intl \
    php5-mcrypt \
    php5-memcache \
    php5-mysql \
    php5-xcache \
    php5-xdebug \
    php5-dev \
    php-pear \
    libyaml-dev \
  \
  && php5dismod opcache \
  \
  && (yes '' | pecl install yaml) \
  && echo "extension=yaml.so" > /etc/php5/mods-available/yaml.ini \
  && php5enmod yaml \
  \
  && (yes '' | pecl install channel://pecl.php.net/xhprof-0.9.4) \
  && echo "extension=xhprof.so" > /etc/php5/mods-available/xhprof.ini \
  && php5enmod xhprof \
  \
  && php -m 2>&1 \
  \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer --version \
  && echo "PATH VARIABLE: "$PATH \
  \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

COPY container-files /

EXPOSE 9000
