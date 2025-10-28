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

FROM ubuntu:18.04 as base1

# Копируем скрипты и файлы установки
ARG ONEC_VERSION
ARG gosu_ver=1.11
ARG nls_enabled=false
ENV nls=$nls_enabled
ENV distrPath=/tmp/downloads/Platform83/${ONEC_VERSION}
ENV installer_type=client

RUN set -xe \
  && chmod 777 -R /tmp \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libwebkitgtk-3.0-0

COPY ./scripts/install_new.sh /install.sh
COPY --from=downloader /tmp/ /tmp/
WORKDIR ${distrPath}      

SHELL ["/bin/bash", "-c"]
RUN ls . \
  && chmod +x /install.sh \
  && sync; /install.sh

# create symlink to current 1c:enterprise directory
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh

COPY ./configs/client/current/ /opt/1cv8/current/

FROM ubuntu:18.04 as client
LABEL maintainer="Anton Kvashenkin <anton.jugatsu@gmail.com> (@jugatsu)"

ARG ONEC_UID="999"
ARG ONEC_GID="999"

COPY --from=base1 /opt /opt

RUN set -xe \
  && chmod 777 -R /tmp \
  && apt-get update \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
      ca-certificates \
      libgtk2.0-0 \
      libwebkitgtk-3.0-0 \
      ttf-mscorefonts-installer \
      libfontconfig1 \
      libgsf-1-114 \
      libglib2.0-0 \
      libodbc1 \
      libmagickwand-6.q16-3 \
      dbus-x11 \
      libglu1-mesa \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8/

USER usr1cv8

CMD ["/opt/1C/v8.3/x86_64/1cv8"]

FROM client as base2

FROM debian:bookworm-slim as client-vnc
ARG ONEC_VERSION
ARG ONEC_UID="999"
ARG ONEC_GID="999"

COPY --from=base2 /opt /opt

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/

RUN apt-get update \
  && apt-mark hold iptables \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dbus-x11 \
    psmisc \
    xdg-utils \
    x11-xserver-utils \
    x11-utils \
    xvfb \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
  && sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
  && echo "deb http://http.debian.net/debian/ bookworm main contrib non-free" > /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ bookworm-backports main" >> /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ bookworm-proposed-updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb http://security.debian.org/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      locales \
      ttf-mscorefonts-installer \
      libfontconfig1 \
      libgsf-1-114 \
      libglib2.0-0 \
      libgtk2.0-0 \
      libodbc1 \
      libtcmalloc-minimal4 \
      libmagickwand-6.q16-6 \
      libwebkit2gtk-4.0-37 \
      at-spi2-core \
      procps \
      x11vnc \
      iproute2 \
      libglu1-mesa \
  # Install libpng12-0 from debian-snapshot
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7638D0442B90D010 8B48AD6246925553 \
  && echo "deb http://snapshot.debian.org/archive/debian/20160413T160058Z/ unstable main" > /etc/apt/sources.list.d/debian-snapshot.list \
  && apt-get -o Acquire::AllowInsecureRepositories=true -o Acquire::Check-Valid-Until=false update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated --no-install-recommends \
      usrmerge \  
      libpng12-0 \
  && rm -rf  /etc/apt/sources.list.d/debian-snapshot.list \
  && apt-get update \
  # Install libwebkitgtk from stretch
  && echo "deb http://archive.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list.d/stretch.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libwebkitgtk-3.0-0 \
  && rm -rf  /etc/apt/sources.list.d/stretch.list \
  && apt-get update \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG=ru_RU.UTF-8

# remove DST Root CA X3 cert if it exists
COPY ./scripts/remove-dst-root-ca-x3.sh /remove-dst-root-ca-x3.sh
RUN chmod +x /remove-dst-root-ca-x3.sh \
  && /remove-dst-root-ca-x3.sh \
  && rm /remove-dst-root-ca-x3.sh

RUN tar xzfh /tmp/s6-overlay-amd64.tar.gz -C / \
  && rm -rf /tmp/s6-overlay-amd64.tar.gz

RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/sbin/nologin usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && mkdir -p /home/usr1cv8/.1C/1cestart \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

COPY ./configs/client-vnc/rootfs/ /

ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1440
ENV DISPLAY_HEIGHT=900

EXPOSE 5900

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

COPY ./configs/client-vnc/rootfs/ /

ENTRYPOINT ["/init"]
