ARG DOCKER_USERNAME
ARG BASE_IMAGE
ARG BASE_TAG

FROM ${DOCKER_USERNAME}/${BASE_IMAGE}:${BASE_TAG} as base

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
    && chown -R usr1cv8:usr1cv8 /usr/lib/vanessa-automation-single.epf /home/usr1cv8/vas.epf \
    && rm -rf /tmp/*

ENV VAS=/usr/lib/vanessa-automation-single.epf

COPY ./configs/client-vnc/rootfs/ /

ENTRYPOINT ["/init"]
