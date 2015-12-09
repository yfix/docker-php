FROM yfix/baseimage

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV PHP_VERSION 7.0.0
ENV PHP_INI_DIR /etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data
ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/
ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763

COPY container-files/usr/local/bin/ /usr/local/bin/

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    git \
    subversion \
    librecode0 \
    libsqlite3-0 \
    libxml2 \
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
    re2c \
  \
  && mkdir -p $PHP_INI_DIR/conf.d \
  \
  && set -xe \
  && for key in $GPG_KEYS; do gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; done \
  && echo ""

RUN echo "" \
  \
  && buildDeps=" \
    $PHP_EXTRA_BUILD_DEPS \
    libcurl4-openssl-dev \
    libreadline6-dev \
    librecode-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    xz-utils \
  " \
  && set -x \
  && apt-get install --no-install-recommends -y $buildDeps \
  \
  && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror" -o php.tar.xz \
  && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz.asc/from/this/mirror" -o php.tar.xz.asc \
  && gpg --verify php.tar.xz.asc \
  \
  && mkdir -p /usr/src/php \
  && tar -xof php.tar.xz -C /usr/src/php --strip-components=1 \
  && rm php.tar.xz* \
  && cd /usr/src/php \
  && ./configure \
    --with-config-file-path="$PHP_INI_DIR" \
    --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
    $PHP_EXTRA_CONFIGURE_ARGS \
    --disable-cgi \
    --enable-mysqlnd \
    --with-curl \
    --with-openssl \
    --with-readline \
    --with-recode \
    --with-zlib \
  && make -j"$(nproc)" \
  && make install \
  && make clean \
  \
  && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
  && echo ""

RUN echo "" \
  \
  && apt-get install --no-install-recommends -y \
    \
    libpng12-dev libjpeg-dev libfreetype6-dev \
    \
    libgmp-dev \
    \
    libicu-dev \
    \
    libmcrypt-dev \
    \
    zlib1g-dev \
    libmemcached-dev \
    \
    libmagickwand-dev \
    \
    libgeoip-dev \
  \
  && echo ""

RUN echo "" \
  \
  && docker-php-ext-install mysqli \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install mbstring \
  && docker-php-ext-install gettext \
  && docker-php-ext-install zip \
  && docker-php-ext-install sockets \
  && docker-php-ext-install pcntl \
  && docker-php-ext-install exif \
  && docker-php-ext-install intl \
  && docker-php-ext-install mcrypt \
  && docker-php-ext-install opcache \
  \
  && echo ""

RUN echo "" \
  \
  && docker-php-ext-configure gd --with-freetype-dir --enable-gd-native-ttf \
  && docker-php-ext-install gd \
  \
  && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
  && docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu \
  && docker-php-ext-install gmp \
  \
  && git clone https://github.com/php-memcached-dev/php-memcached.git /tmp/php-memcached \
  && cd /tmp/php-memcached && git checkout php7 \
  && phpize && ./configure --disable-memcached-sasl && make && make install \
  && echo 'extension=memcached.so' > /etc/php/conf.d/memcached.ini \
  && cd /tmp && rm -rf /tmp/php-memcached \
  \
  && git clone https://github.com/mkoppanen/imagick.git /tmp/php-imagick \
  && cd /tmp/php-imagick && git checkout phpseven \
  && phpize && ./configure && make && make install \
  && echo 'extension=imagick.so' > /etc/php/conf.d/imagick.ini \
  && cd /tmp && rm -rf /tmp/php-imagick \
  \
  && (yes 'no' | pecl install apcu) \
  && echo 'extension=apcu.so' > /etc/php/conf.d/apcu.ini \
  \
  && svn co http://svn.php.net/repository/pecl/geoip/trunk /tmp/php-geoip && cd /tmp/php-geoip \
  && phpize && ./configure && make && make install \
  && echo 'extension=geoip.so' > /etc/php/conf.d/geoip.ini \
  && cd /tmp && rm -rf /tmp/php-geoip \
  \
#  && pecl install xhprof \
  \
  && echo ""

RUN echo "" \
  \
  && php -v \
  && php -m \
  && php --ini \
  \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer --version \
  && echo "PATH VARIABLE: "$PATH \
  \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false$(dpkg -l | grep ii | grep '\-dev' | awk '{print $2}') \
  && rm -rf /var/lib/apt/lists/* \
  \
  && echo "the end"

COPY container-files /
  
WORKDIR /var/www

EXPOSE 9000
