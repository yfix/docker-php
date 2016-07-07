FROM yfix/baseimage

MAINTAINER Yuri Vysotskiy (yfix) <yfix.dev@gmail.com>

ENV COMPOSER_HOME /usr/local/share/composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin/

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu trusty main" > /etc/apt/sources.list.d/php.list \
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
    php7.0 \
    php7.0-opcache \
    php7.0-bcmath \
  \
    php-amqp \
    php-apcu \
    php-apcu-bc \
    php-bz2 \
    php-cli \
    php-curl \
    php-fpm \
    php-gd \
    php-geoip \
    php-gmp \
    php-igbinary \
    php-imagick \
    php-intl \
    php-json \
    php-mbstring \
    php-memcached \
    php-mongodb \
    php-msgpack \
    php-mysql \
    php-redis \
    php-sqlite3 \
    php-ssh2 \
    php-uploadprogress \
    php-uuid \
    php-zip \
    php-zmq \
  \
    php-dev \
    libyaml-dev \
  \
    wget \
    curl \
    git \
  \
  \
  \
  && cd /tmp && wget http://pear.php.net/go-pear.phar \
  && php go-pear.phar \
  \
  \
  \
  && git clone https://github.com/php/pecl-file_formats-yaml.git /tmp/php-yaml \
  && cd /tmp/php-yaml && git checkout php7 \
  && phpize && ./configure && make && make install \
  && echo 'extension=yaml.so' > /etc/php/7.0/fpm/conf.d/yaml.ini \
  && cd /tmp && rm -rf /tmp/php-yaml \
  \
  \
  \
  && echo "====Fixing links====" \
  \
  && ls -Rl /etc/php* \
  \
  && rm -vrf /etc/php/5.6 \
  && rm -vrf /etc/php/7.0/apache* \
  && cp -vrf /etc/php/7.0/* /etc/php/ \
  && rm -vrf /etc/php/7.0/* \
  && cp -vrf /etc/php/fpm/conf.d /etc/php/conf.d \
  && ln -vs /etc/php/mods-available /etc/php/7.0/mods-available \
  && ln -vs /etc/php/fpm /etc/php/7.0/fpm \
  && ln -vs /etc/php/cli /etc/php/7.0/cli \
  && rm -vrf /etc/php/fpm/conf.d \
  && ln -vs /etc/php/conf.d /etc/php/fpm/conf.d \
  && rm -vrf /etc/php/cli/conf.d \
  && ln -vs /etc/php/conf.d /etc/php/cli/conf.d \
  \
  && ln -vs /usr/sbin/php-fpm7.0 /usr/local/sbin/php-fpm \
  \
  && ls -Rl /etc/php* \
  \
  \
  \
  && php -v \
  && php -m \
  && php --ini \
  \
  \
  \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer --version \
  && echo "PATH VARIABLE: "$PATH \
  \
  \
  \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /usr/{{lib,share}/locale,share/{man,doc,info,gnome/help,cracklib,il8n},{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} \
  \
  && echo "====The end===="

COPY docker /

EXPOSE 9000
