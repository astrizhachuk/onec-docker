FROM alpine:latest as downloader

ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION
ENV installer_type=client
ENV downloads=downloads/platform83/${ONEC_VERSION}

COPY ./scripts/download_og.sh /download_og.sh

WORKDIR /tmp

COPY ./distr ./${downloads}
RUN rm ./${downloads}/.gitkeep \
  && rm -rf ${downloads}/deb*.tar.gz \
  && rm -rf ${downloads}/thin.client*.tar.gz \
  && rm -rf ${downloads}/1c_edt*.tar.gz \
  && if [ -z "$(ls -A ${downloads})" ]; then \
  apk --no-cache add bash curl grep tar \
  && chmod +x /download_og.sh \
  && sync; /download_og.sh; \
  fi \
  && rm -rf downloads/platform83/${ONEC_VERSION}/*thin*.tar.gz \
  && for file in ${downloads}/*.tar.gz; do tar -xzf "$file"; done \
  && find . -name "*-thin-*.deb" -delete \
  && rm -rf ${downloads}/*.*

FROM ubuntu:18.04 as base1

ARG ONEC_VERSION
ENV installer_type=client
ARG nls_enabled=false
ENV nls=$nls_enabled

COPY ./scripts/install.sh /install.sh
COPY --from=downloader /tmp/*.* /tmp/
WORKDIR /tmp

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libwebkitgtk-3.0-0

WORKDIR /tmp

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

FROM debian:bullseye-slim as client-vnc

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
    x11vnc \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xfce4 \
    # Additional GUI utilities, optional
    xfce4-goodies \
  && sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
  && echo "deb http://http.debian.net/debian/ bullseye main contrib non-free" > /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ bullseye-backports main" >> /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ bullseye-proposed-updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb http://security.debian.org/debian-security/ bullseye-security main contrib non-free" >> /etc/apt/sources.list \
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
      at-spi2-core \
      procps \
  # Install libpng12-0 from xenial
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 40976EAF437D05B5 \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main" > /etc/apt/sources.list.d/xenial-security.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libpng12-0 \
  && rm -rf  /etc/apt/sources.list.d/xenial-security.list \
  && apt-get update \
  # Install libwebkitgtk from stretch
  && echo "deb http://deb.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list.d/stretch.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libwebkitgtk-3.0-0 \
  && rm -rf  /etc/apt/sources.list.d/stretch.list \
  && apt-get update \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

# remove DST Root CA X3 cert if it exists
COPY ./scripts/remove-dst-root-ca-x3.sh /remove-dst-root-ca-x3.sh
RUN chmod +x /remove-dst-root-ca-x3.sh \
  && /remove-dst-root-ca-x3.sh \
  && rm /remove-dst-root-ca-x3.sh

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
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
