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

FROM debian:bookworm-slim

ARG ONEC_UID="999"
ARG ONEC_GID="999"

COPY --from=base /opt/1cv8 /opt/1cv8
COPY --from=base /bin/gosu /bin/gosu

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
      iproute2 \
      imagemagick \
      fontconfig \
      ca-certificates \
  && rm -rf /var/lib/apt/lists/* /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

# Настройка группы и пользователя
RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /var/log/1C /home/usr1cv8/.1cv8/1C/1cv8/conf /opt/1cv8/current/conf \
  && chown -R usr1cv8:grp1cv8 /var/log/1C /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8 /var/log/1C

# Копирование конфигурационных файлов
COPY ./configs/server/conf/logcfg.xml /home/usr1cv8/.1cv8/1C/1cv8/conf
COPY ./configs/server/conf/logcfg.xml /opt/1cv8/current/conf

# Установка точки входа и выполнение дополнительных настроек
COPY ./server/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 1540 1541 1545 1560

CMD ["ragent"]
