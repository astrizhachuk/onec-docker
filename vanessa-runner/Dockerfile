ARG DOCKER_USERNAME
ARG BASE_IMAGE=client-oscript-1.2.0
ARG BASE_TAG

FROM ${DOCKER_USERNAME}/${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Alexander Strizhachuk <a.strizhachuk@yandex.ru>"

ARG RUNNER_VER=1.10.0

RUN opm install vanessa-runner@${RUNNER_VER}

ENTRYPOINT ["runner"]
CMD ["help"]
