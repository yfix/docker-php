FROM yfix/baseimage:20.04

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/

ARG DEBIAN_FRONTED=noninteractive

RUN apt-get update && apt-get install -my wget gnupg \
  \
  && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/php.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
  \
  && apt-get update \
  \
  && apt-get purge -y --auto-remove php5-* php7.0-* php7.1-* php7.2-* php7.3-* php7.4-* \
  \
  && apt-cache search php8 2>&1 \
  && apt-cache search php- 2>&1 | egrep -i "(extension|module)" | grep -v php7 | sort \
  \
  && apt-get install -y --no-install-recommends \
    php8.0-cli \
    php8.0-fpm \
    php8.0-bcmath \
    php8.0-bz2 \
    php8.0-common \
    php8.0-curl \
    php8.0-dev \
    php8.0-gd \
    php8.0-gmp \
    php8.0-intl \
    php8.0-mbstring \
    php8.0-mysql \
    php8.0-opcache \
    php8.0-pgsql \
    php8.0-sqlite3 \
    php8.0-xml \
    php8.0-zip \
  \
    php-amqp \
    php-apcu \
    php-apcu-bc \
    php-geoip \
    php-igbinary \
    php-imagick \
    php-json \
    php-memcached \
    php-mongodb \
    php-msgpack \
    php-pear \
    php-redis \
    php-ssh2 \
    php-uploadprogress \
    php-uuid \
    php-xdebug \
    php-yaml \
    php-zmq \
  \
    wget \
    curl \
    git \
    librdkafka-dev \
    build-essential \
    graphviz \
    imagemagick

RUN echo "=== continue ===" \
  \
  && pecl install -f rdkafka \
  && echo 'extension=rdkafka.so' > /etc/php/8.0/mods-available/rdkafka.ini \
  && phpenmod rdkafka \
  \
  \
  \
  && cd /tmp/ \
  && git clone https://github.com/longxinH/xhprof.git ./xhprof \
  && cd xhprof/extension/ \
  && phpize \
  && ./configure \
  && make \
  && make install \
  \
  \
  \
  && apt-get purge -y --auto-remove $(dpkg -l | grep ii | grep php7.0 | awk '{print $2}') \
  && apt-get purge -y --auto-remove $(dpkg -l | grep ii | grep php7.1 | awk '{print $2}') \
  && apt-get purge -y --auto-remove $(dpkg -l | grep ii | grep php7.2 | awk '{print $2}') \
  && apt-get purge -y --auto-remove $(dpkg -l | grep ii | grep php7.3 | awk '{print $2}') \
  && apt-get purge -y --auto-remove $(dpkg -l | grep ii | grep php7.4 | awk '{print $2}') \
  && apt-get purge -y --auto-remove \
    apache2-bin \
    autoconf \
    automake \
    autotools-dev \
    binutils \
    cpp \
    gcc \
    php-dev \
  \
  \
  \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /usr/{lib,lib/share,share}/{man,doc,info,gnome/help,cracklib} \
  && rm -rf /tmp/* \
  \
  && echo "=== The end ==="

RUN echo "=== Fixing links ===" \
  \
  && ls -Rl /etc/php* \
  \
  && rm -vrf /etc/php/5* \
  && rm -vrf /etc/php/8.0/apache* \
  \
  && cp -vrf /etc/php/8.0/* /etc/php/ \
  \
  && rm -vrf /etc/php/8.0/* \
  && rm -vrf /etc/php/8.0/* \
  \
  && cp -vrf /etc/php/fpm/conf.d /etc/php/conf.d \
  && ln -vs /etc/php/mods-available /etc/php/8.0/mods-available \
  && ln -vs /etc/php/fpm /etc/php/8.0/fpm \
  && ln -vs /etc/php/cli /etc/php/8.0/cli \
  && rm -vrf /etc/php/fpm/conf.d \
  && ln -vs /etc/php/conf.d /etc/php/fpm/conf.d \
  && rm -vrf /etc/php/cli/conf.d \
  && ln -vs /etc/php/conf.d /etc/php/cli/conf.d \
  \
  && ln -vs /usr/sbin/php-fpm8.0 /usr/local/sbin/php-fpm \
  \
  && mkdir -p /etc/php/conf.d.dist/ \
  && mv -vf /etc/php/conf.d/*.ini /etc/php/conf.d.dist/ \
  \
  && ls -Rl /etc/php* \
  && cat /etc/php/mods-available/* \
  \
  && echo "=== The end ==="

COPY docker /

RUN echo "=== check php and install tools ===" \
  \
  && php -v \
  && php -m \
  && php --ini \
  \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer --version --no-plugins --no-scripts 2>/dev/null \
  \
  && composer global require --prefer-source --no-interaction --no-plugins --no-scripts jakub-onderka/php-parallel-lint \
  \
  && wget https://phar.phpunit.de/phpunit.phar && chmod +x phpunit.phar && mv phpunit.phar /usr/local/bin/phpunit \
  && phpunit --version \
  \
  && echo "=== The end ==="

EXPOSE 9000
