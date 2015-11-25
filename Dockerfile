FROM ubuntu:14.04

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" > /etc/apt/sources.list.d/php56.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
  \
  apt-get update && \
  apt-get install -y \
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
    && \
  php5dismod opcache && \
  \
  (yes '' | pecl install yaml) && \
  echo "extension=yaml.so" > /etc/php5/mods-available/yaml.ini && \
  php5enmod yaml && \
  \
  (yes '' | pecl install channel://pecl.php.net/xhprof-0.9.4) && \
  echo "extension=xhprof.so" > /etc/php5/mods-available/xhprof.ini && \
  php5enmod xhprof && \
  \
  php -m 2>&1 && \
  \
  apt-get autoremove -y && \
  apt-get clean -y
  
COPY php.ini /etc/php5/fpm/php.ini
COPY php.ini /etc/php5/cli/php.ini
COPY php-fpm.conf /etc/php5/fpm/php-fpm.conf
COPY www.conf /etc/php5/fpm/pool.d/www.conf

VOLUME ["/var/lib/php5/sessions"]

EXPOSE 9000

CMD ["php5-fpm", "--nodaemonize"]
