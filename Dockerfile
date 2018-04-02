FROM yfix/baseimage:16.04

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/

ARG DEBIAN_FRONTED=noninteractive

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" > /etc/apt/sources.list.d/php.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
  \
  && apt-get update \
  \
  && apt-get purge -y --auto-remove php5-* \
  \
  && apt-cache search php7 2>&1 \
  && apt-cache search php- 2>&1 | egrep -i "(extension|module)" | grep -v php5.6 | sort \
  \
  && apt-get install -y --no-install-recommends \
    php7.2-cli \
    php7.2-fpm \
    php7.2-bcmath \
    php7.2-bz2 \
    php7.2-common \
    php7.2-curl \
    php7.2-dev \
    php7.2-gd \
    php7.2-gmp \
    php7.2-intl \
    php7.2-json \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-opcache \
    php7.2-pgsql \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
  \
    php-amqp \
    php-apcu \
    php-apcu-bc \
    php-geoip \
    php-igbinary \
    php-imagick \
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
    imagemagick \
  \
  \
  \
  && pecl install -f rdkafka \
  && echo 'extension=rdkafka.so' > /etc/php/7.2/mods-available/rdkafka.ini \
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
  && echo "====The end===="

RUN echo "====Fixing links====" \
  \
  && ls -Rl /etc/php* \
  \
  && rm -vrf /etc/php/5* \
  && rm -vrf /etc/php/7.2/apache* \
  \
  && cp -vrf /etc/php/7.2/* /etc/php/ \
  \
  && rm -vrf /etc/php/7.2/* \
  && rm -vrf /etc/php/7.2/* \
  \
  && cp -vrf /etc/php/fpm/conf.d /etc/php/conf.d \
  && ln -vs /etc/php/mods-available /etc/php/7.2/mods-available \
  && ln -vs /etc/php/fpm /etc/php/7.2/fpm \
  && ln -vs /etc/php/cli /etc/php/7.2/cli \
  && rm -vrf /etc/php/fpm/conf.d \
  && ln -vs /etc/php/conf.d /etc/php/fpm/conf.d \
  && rm -vrf /etc/php/cli/conf.d \
  && ln -vs /etc/php/conf.d /etc/php/cli/conf.d \
  \
  && ln -vs /usr/sbin/php-fpm7.2 /usr/local/sbin/php-fpm \
  \
  && mkdir -p /etc/php/conf.d.dist/ \
  && mv -vf /etc/php/conf.d/*.ini /etc/php/conf.d.dist/ \
  \
  && ls -Rl /etc/php* \
  && cat /etc/php/mods-available/* \
  \
  && echo "====The end===="

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
  && echo "====The end===="

EXPOSE 9000
