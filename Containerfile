ARG FEDORA_VERSION=43
ARG ARCH=x86_64

ARG OS_NAME=ace-os
ARG DEFAULT_TAG=latest

FROM ghcr.io/bazzite-org/kernel-bazzite:6.17.7-ba19-f43-x86_64 AS kernel
FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION} as base
ARG DEFAULT_TAG=${DEFAULT_TAG}

# 00-base
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/00-base.sh

# 01-kernel
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=kernel,src=/,dst=/rpms/kernel \
    /ctx/01-kernel.sh


# 02-foundation
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/02-foundation.sh

# 03-de
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/03-de.sh

# 04-patch
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/04-patch.sh && \
#     /ctx/cleanup.sh

# # 05-Dank
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/05-dank.sh && \
#     /ctx/cleanup.sh

# # 06-config
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/06-config.sh && \
#     /ctx/cleanup.sh

# # 07-services
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/07-services.sh && \
#     /ctx/cleanup.sh

# # 08-initramfs
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/08-initramfs.sh && \
#     /ctx/cleanup.sh

# 99-final
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/99-final.sh

RUN bootc container lint
