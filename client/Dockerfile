FROM alpine:latest as downloader

ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION
ENV installer_type=client

COPY ./scripts/download.sh /download.sh

WORKDIR /tmp

RUN apk --no-cache add bash curl grep \
  && chmod +x /download.sh \
  && sync; /download.sh \
  && for file in *.tar.gz; do tar -zxf "$file"; done \
  && rm -rf *.tar.gz \
  && rm ./*-thin-*.deb

FROM ubuntu:18.04 as base1

ARG nls_enabled=false
ENV nls=$nls_enabled

COPY --from=downloader /tmp/*.deb /tmp/

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libwebkitgtk-3.0-0

WORKDIR /tmp

SHELL ["/bin/bash", "-c"]
RUN set -xe; \
  if [ "$nls" = true ]; then \
    dpkg -i 1c-enterprise*-{common,server}_*.deb; \
    dpkg -i 1c-enterprise*-{common,client}*.deb; \
  else \
    dpkg -i 1c-enterprise*-{common,server,client}_*.deb; \
  fi

# create symlink to current 1c:enterprise directory
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh

COPY ./configs/client/current/ /opt/1cv8/current/

FROM ubuntu:18.04 as client
LABEL maintainer="Anton Kvashenkin <anton.jugatsu@gmail.com> (@jugatsu)"

ARG onec_uid="2001"
ARG onec_gid="2001"

COPY --from=base1 /opt /opt

RUN set -xe \
  && apt-get update \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
      ca-certificates \
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

RUN groupadd -r grp1cv8 --gid=$onec_gid \
  && useradd -r -g grp1cv8 --uid=$onec_uid --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8/

USER usr1cv8

CMD ["/opt/1C/v8.3/x86_64/1cv8"]

FROM client as base2

FROM debian:stretch-slim as client-vnc

ARG onec_uid="2001"
ARG onec_gid="2001"

COPY --from=base2 /opt /opt

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/

# RUN apt-get update \
#   && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#     dirmngr \
#     gnupg \
#   && echo "deb http://http.debian.net/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
#   && echo "deb http://http.debian.net/debian/ stretch-updates main contrib non-free" >> /etc/apt/sources.list \
#   && echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list \
#   && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
#   && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 \
#   && echo "deb http://security.ubuntu.com/ubuntu xenial-security main" > /etc/apt/sources.list.d/xenial-security.list \
#   && apt-get update \
#   && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#       ca-certificates \
#       git \
#       locales \
#       libwebkitgtk-3.0-0 \
#       ttf-mscorefonts-installer \
#       libfontconfig1 \
#       libgsf-1-114 \
#       libglib2.0-0 \
#       libodbc1 \
#       libpng12-0 \
#       libmagickwand-6.q16-3 \
#       dbus-x11 \
#       at-spi2-core \
#       procps \
#       xvfb \
#       x11vnc \
#   && rm -rf  \
#     /var/lib/apt/lists/* \
#     /var/cache/debconf \
#   && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
# ENV LANG ru_RU.UTF-8

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
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gtk3-engines-xfce \
    libgtk-3-bin \
    libpulse0 \
    mousepad \
    xfce4-notifyd \
    xfce4-taskmanager \
    xfce4-terminal \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xfce4-battery-plugin \
    xfce4-clipman-plugin \
    xfce4-cpufreq-plugin \
    xfce4-cpugraph-plugin \
    xfce4-diskperf-plugin \
    xfce4-datetime-plugin \
    xfce4-fsguard-plugin \
    xfce4-genmon-plugin \
    xfce4-indicator-plugin \
    xfce4-netload-plugin \
    xfce4-notes-plugin \
    xfce4-places-plugin \
    xfce4-sensors-plugin \
    xfce4-smartbookmark-plugin \
    xfce4-systemload-plugin \
    xfce4-timer-plugin \
    xfce4-verve-plugin \
    xfce4-weather-plugin \
    xfce4-whiskermenu-plugin \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libxv1 \
    mesa-utils \
    mesa-utils-extra \
  && sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
  && echo "deb http://http.debian.net/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ stretch-backports main" >> /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ stretch-updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      locales \
      libwebkitgtk-3.0-0 \
      ttf-mscorefonts-installer \
      libfontconfig1 \
      libgsf-1-114 \
      libglib2.0-0 \
      libodbc1 \
      libtcmalloc-minimal4 \
      libmagickwand-6.q16-3 \
      at-spi2-core \
      procps \
      x11vnc \
  # Install libpng12-0 from xenial
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main" > /etc/apt/sources.list.d/xenial-security.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libpng12-0 \
  # Install git from backports
  && DEBIAN_FRONTEND=noninteractive apt-get -t stretch-backports install -y --no-install-recommends \
    git \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && rm -rf /tmp/s6-overlay-amd64.tar.gz

RUN groupadd -r grp1cv8 --gid=$onec_gid \
  && useradd -r -g grp1cv8 --uid=$onec_uid --home-dir=/home/usr1cv8 --shell=/sbin/nologin usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && mkdir -p /home/usr1cv8/.1C/1cestart \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

COPY ./configs/client-vnc/rootfs/ /

ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1440
ENV DISPLAY_HEIGHT=900

EXPOSE 5900

ENTRYPOINT ["/init"]

FROM client-vnc as client-vnc-vas

ARG VAS_VERSION

RUN set -xe \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        unzip \ 
        inetutils-ping \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
    && curl -Ls -o /tmp/vas.zip https://github.com/Pr-Mex/vanessa-automation/releases/download/${VAS_VERSION}/vanessa-automation-single.${VAS_VERSION}.zip \
    && unzip /tmp/vas.zip -d /tmp \
    && mv /tmp/vanessa-automation-single.epf /usr/lib/vanessa-automation-single.epf \
    && ln -s /usr/lib/vanessa-automation-single.epf /home/usr1cv8/vas.epf \
    && chown -R usr1cv8:grp1cv8 /usr/lib/vanessa-automation-single.epf /home/usr1cv8/vas.epf \
    && rm -rf /tmp/*

ENV VAS=/usr/lib/vanessa-automation-single.epf

COPY ./configs/client-vnc/rootfs/ /

ENTRYPOINT ["/init"]
