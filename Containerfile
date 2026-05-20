ARG FEDORA_VERSION=43
ARG ARCH=x86_64

ARG OS_NAME=ace-os
ARG DEFAULT_TAG=latest

FROM scratch AS ctx
COPY build-scripts /

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION} as base
ARG OS_NAME=ace-os
ARG DEFAULT_TAG=${DEFAULT_TAG}
ARG IMAGE=${OS_NAME}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
