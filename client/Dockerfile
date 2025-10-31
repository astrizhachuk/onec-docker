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

RUN /download.sh "$ONEC_USERNAME" "$ONEC_PASSWORD" "$ONEC_VERSION" "client"

FROM debian:bookworm-slim AS base

ARG ONEC_VERSION
ARG nls_enabled=false
ENV nls=$nls_enabled
ENV distrPath=/tmp/downloads/Platform83/${ONEC_VERSION}
ENV installer_type=client

COPY ./scripts/install_new.sh /install.sh
COPY --from=downloader ${distrPath}/ /tmp/distr/

RUN apt-get update && apt-get install -y --no-install-recommends curl \
  && chmod +x /install.sh \
  && cd /tmp/distr \
  && /install.sh \
  && apt-get purge -y --auto-remove curl \
  && rm -rf /var/lib/apt/lists/* /tmp/distr

# create symlink to current 1c:enterprise directory
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh \
  && rm /install.sh

COPY ./configs/client/current/ /opt/1cv8/current/

FROM debian:bookworm-slim AS client

ARG ONEC_UID="1001"
ARG ONEC_GID="1001"

RUN set -xe \
  && echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list \
  && apt-get update \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      locales \
      ttf-mscorefonts-installer \
      libfontconfig1 \
      libgsf-1-114 \
      libglib2.0-0 \
      libgtk2.0-0 \
      libodbc1 \
      libmagickwand-6.q16-6 \
      libwebkit2gtk-4.0-37 \
      at-spi2-core \
      libglu1-mesa \
      libsm6 \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

COPY --from=base /opt /opt

ENV LANG ru_RU.UTF-8

RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8/

USER usr1cv8

CMD ["/opt/1cv8/current/1cv8"]

FROM client AS client-vnc

LABEL maintainer="Alexander Strizhachuk <a.strizhachuk@yandex.ru>"

USER root

RUN set -xe \
  && echo "deb http://http.debian.net/debian/ bookworm-backports main" > /etc/apt/sources.list.d/backports.list \
  && echo "deb http://http.debian.net/debian/ bookworm-proposed-updates main contrib non-free" > /etc/apt/sources.list.d/proposed-updates.list \
  && echo "deb http://security.debian.org/debian-security/ bookworm-security main contrib non-free" > /etc/apt/sources.list.d/security.list \
  && apt-get update \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      dbus-x11 \
      psmisc \
      xdg-utils \
      x11-xserver-utils \
      x11-utils \
      xvfb \
      xfce4 \
      xfce4-goodies \
      dirmngr \
      gnupg \
      git \
      libtcmalloc-minimal4 \
      procps \
      x11vnc \
      iproute2 \
      xz-utils \
  && sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf

ENV LANG=ru_RU.UTF-8

# remove DST Root CA X3 cert if it exists
COPY ./scripts/remove-dst-root-ca-x3.sh /remove-dst-root-ca-x3.sh
RUN chmod +x /remove-dst-root-ca-x3.sh \
  && /remove-dst-root-ca-x3.sh \
  && rm /remove-dst-root-ca-x3.sh

ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1440
ENV DISPLAY_HEIGHT=900

EXPOSE 5900

# Install s6-overlay v3
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-noarch.tar.xz /tmp/
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-x86_64.tar.xz /tmp/
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-symlinks-noarch.tar.xz /tmp/
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
  && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
  && tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz \
  && rm -f /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-x86_64.tar.xz /tmp/s6-overlay-symlinks-noarch.tar.xz

COPY ./configs/client-vnc/rootfs-v3/ /

ENTRYPOINT ["/init"]

FROM client-vnc as client-vnc-va

ARG VA_VERSION
ARG INIT_DB_VERSION="2.0.0"

RUN set -xe \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        unzip \ 
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
    && curl -Ls -o /tmp/va.zip https://github.com/Pr-Mex/vanessa-automation/releases/download/${VA_VERSION}/vanessa-automation-single.${VA_VERSION}.zip \
    && curl -Ls -o /usr/lib/InitDB.epf https://github.com/astrizhachuk/Init-db-1c/releases/download/${INIT_DB_VERSION}/InitDB.epf \
    && unzip /tmp/va.zip -d /tmp \
    && mv /tmp/vanessa-automation-single.epf /usr/lib/vanessa-automation-single.epf \
    && ln -s /usr/lib/vanessa-automation-single.epf /va.epf \
    && ln -s /usr/lib/InitDB.epf /init.epf \
    && rm -rf /tmp/* \
    && chown -R usr1cv8:grp1cv8 /usr/lib/vanessa-automation-single.epf /va.epf /usr/lib/InitDB.epf /init.epf

ENV VA=/usr/lib/vanessa-automation-single.epf
ENV INIT_DB=/usr/lib/InitDB.epf

ENTRYPOINT ["/init"]
