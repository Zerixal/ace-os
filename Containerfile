ARG FEDORA_VERSION=43
ARG ARCH=x86_64

ARG OS_NAME=ace-os
ARG DEFAULT_TAG=latest

FROM ghcr.io/bazzite-org/kernel-bazzite:6.17.7-ba19-f43-x86_64 AS kernel
FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION} as base
ARG DEFAULT_TAG=${DEFAULT_TAG}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
