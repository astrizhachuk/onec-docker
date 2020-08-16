ARG DOCKER_USERNAME=library
ARG BASE_IMAGE=debian
ARG BASE_TAG=stretch-slim

FROM ${DOCKER_USERNAME}/${BASE_IMAGE}:${BASE_TAG}

# Installing mono and oscript dependencies
ARG MONO_VERSION=6.8.0.105

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gnupg \
      dirmngr \
      unzip \
      wget \
      git \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian stable-stretch main" > /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    mono-runtime \
    ca-certificates-mono \
    libmono-i18n4.0-all \
    libmono-system-runtime-serialization4.0-cil \
  && cert-sync --user /etc/ssl/certs/ca-certificates.crt \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/*

# Installing oscript
ARG OVM_REPOSITORY_OWNER=oscript-library
ARG OVM_VERSION=v1.0.0-RC15
ARG ONESCRIPT_VERSION=dev
ARG ONESCRIPT_PACKAGES="logos"

RUN wget https://github.com/${OVM_REPOSITORY_OWNER}/ovm/releases/download/${OVM_VERSION}/ovm.exe \
  && mv ovm.exe /usr/local/bin/ \
  && echo 'mono /usr/local/bin/ovm.exe "$@"' | tee /usr/local/bin/ovm \
  && chmod +x /usr/local/bin/ovm \
  && ovm use --install ${ONESCRIPT_VERSION}

ENV OSCRIPTBIN=/root/.local/share/ovm/current/bin
ENV PATH="$OSCRIPTBIN:$PATH"

# Update and prepare oscript packages
# Bugfix opm для ${ONESCRIPT_VERSION} < 1.4.0
RUN wget -O /tmp/opm.ospx https://github.com/${OVM_REPOSITORY_OWNER}/opm/releases/download/v0.16.2/opm-0.16.2.ospx \
  && unzip /tmp/opm.ospx -d /tmp \
  && unzip -o ./tmp/content.zip -d /root/.local/share/ovm/current/lib/opm \
  && opm install -f /tmp/opm.ospx \
  && rm -rf /tmp/*

RUN opm update --all \
  && opm install ${ONESCRIPT_PACKAGES}

COPY ./oscript/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh \
  && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
