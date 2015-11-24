FROM ubuntu:14.04

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

RUN apt-get update && \
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
    php5-xhprof \
    php5-dev \
    php-pear \
  && \
  apt-get autoremove -y && \
  apt-get clean -y
  
COPY php.ini /etc/php5/fpm/php.ini
COPY php.ini /etc/php5/cli/php.ini
COPY php-fpm.conf /etc/php5/fpm/php-fpm.conf
COPY www.conf /etc/php5/fpm/pool.d/www.conf

VOLUME ["/var/lib/php5/sessions"]

EXPOSE 9000

CMD ["php5-fpm"]
