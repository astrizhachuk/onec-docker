ARG DOCKER_USERNAME=library
ARG BASE_IMAGE=debian
ARG BASE_TAG=stretch-slim

FROM ${DOCKER_USERNAME}/${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Gryzlov <NikGryzlov@1bit.com>, FirstBit"

# Install OpenJDK
ARG OPENJDK_VERSION=14

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      git \
      gnupg \
      dirmngr \
      locales \
      software-properties-common \
      wget \
  && wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
  && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
  && apt-get update \
  # see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199#23
  && mkdir -p /usr/share/man/man1 \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      adoptopenjdk-${OPENJDK_VERSION}-hotspot \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG ru_RU.UTF-8