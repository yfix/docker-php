FROM yfix/baseimage

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV PHP_VERSION 7.0.0
ENV PHP_INI_DIR /etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data
ENV PHP_EXTRA_PECL_EXTENSIONS memcache geoip #### redis mongo
ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/
ENV GPG_KEYS 1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
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

#ENV PHP_EXTRA_PECL_EXTENSIONS memcached

RUN echo "" \
  \
#  && apt-get install --no-install-recommends -y \
#    zlib1g-dev \
#    libgeoip-dev \
#    geoip-database \
#    libmemcached-dev \
#  \
#  && for ext in $PHP_EXTRA_PECL_EXTENSIONS; do \
#    (yes '' | pecl install --nodeps $ext) \
#    ; \
#    && echo "extension=$ext.so" > /etc/php/mods-available/$ext.ini \
#   && phpenmod $ext \
#  done \
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
  && rm -rf /var/lib/apt/lists/* \
  \
  && echo "the end"
  
COPY container-files /

WORKDIR /var/www

EXPOSE 9000
