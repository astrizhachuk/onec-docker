# Используем базовый образ для скачивания
ARG DOWNLOADER_REGISTRY_URL
ARG DOWNLOADER_IMAGE
ARG DOWNLOADER_TAG
FROM ${DOWNLOADER_REGISTRY_URL}/${DOWNLOADER_IMAGE}:${DOWNLOADER_TAG} AS downloader

# Копирование скрипта скачивания и локальных дистрибутивов
COPY ./scripts/download_yard.sh /download.sh
COPY ./distr /distr
RUN chmod +x /download.sh

# Скачивание дистрибутива 1С с использованием вынесенного скрипта
ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION

WORKDIR /tmp

# Установка необходимых пакетов и генерация локали
RUN apt-get update \
  && apt-get install -y \
          locales \
          p7zip-rar \
          p7zip-full \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ru_RU.UTF-8 \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

# Установка переменных окружения для корректной работы локали
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

RUN /download.sh "$ONEC_USERNAME" "$ONEC_PASSWORD" "$ONEC_VERSION" "server"

FROM ubuntu:20.04 AS base

# Копируем скрипты и файлы установки
ARG ONEC_VERSION
ARG gosu_ver=1.11
ARG nls_enabled=false
ENV nls=$nls_enabled
ENV distrPath=/tmp/downloads/Platform83/${ONEC_VERSION}
ENV installer_type=server

# Установка зависимостей и настройка локали
RUN apt-get update \
&& apt-get install -yq \
      procps \
      tzdata \
      debconf-utils \
      curl \
      fontconfig \
      unixodbc \
      ttf-mscorefonts-installer \
      libgsf-1-114 \
      keyboard-configuration \
&& dpkg-reconfigure -f noninteractive tzdata \
&& dpkg-reconfigure -f noninteractive keyboard-configuration \
&& apt-get install -yq geoclue-2.0 gstreamer1.0-plugins-bad \
&& export LANG=ru_RU.UTF-8

COPY ./scripts/install_new.sh /install.sh
COPY --from=downloader /tmp/ /tmp/
WORKDIR ${distrPath}
RUN ls . \
  && chmod +x /install.sh \
  && sync; /install.sh

# Создание символической ссылки на текущую директорию 1C
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh

# Установка gosu
ADD https://github.com/tianon/gosu/releases/download/$gosu_ver/gosu-amd64 /bin/gosu
RUN chmod +x /bin/gosu

FROM debian:bullseye-slim
LABEL maintainers="Anton Kvashenkin <anton.jugatsu@gmail.com>, Alexander Strizhachuk <a.strizhachuk@yandex.ru>"

ARG ONEC_UID="999"
ARG ONEC_GID="999"

COPY --from=base /opt /opt
COPY --from=base /bin/gosu /bin/gosu

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
      imagemagick \
      fontconfig \
      apache2 \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

RUN sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=usr1cv8/g' /etc/apache2/envvars \
  && sed -i 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=grp1cv8/g' /etc/apache2/envvars

RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /opt/1cv8/current/conf /home/usr1cv8/.1cv8 /var/log/1C \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8 /var/log/1C

VOLUME /home/usr1cv8/.1cv8/ /var/log/1C

COPY ./configs/server/conf/logcfg.xml /opt/1cv8/current/conf

STOPSIGNAL SIGWINCH

COPY ./ws/apache2-foreground.sh /usr/local/bin/apache2-foreground

RUN chmod 755 /usr/local/bin/apache2-foreground \
  && chmod +x /usr/local/bin/apache2-foreground

WORKDIR /var/www

EXPOSE 80

CMD ["/usr/local/bin/apache2-foreground"]
