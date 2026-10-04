ARG FEDORA_VERSION=44
ARG ARCH=x86_64

ARG OS_NAME=ace-os
ARG DEFAULT_TAG=latest

FROM scratch AS ctx
COPY build-scripts /
COPY system-files/ /system-files

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION} AS base
ARG OS_NAME=ace-os
ARG DEFAULT_TAG=${DEFAULT_TAG}
ARG IMAGE=${OS_NAME}

# Base system files (udev rules, systemd presets, skel, ...). Keep this tree
# free of anything a module also writes, or the module will clobber it.
COPY system-files/common /

# Flavor overlay: IMAGE selects an optional system-files/<flavor>/ tree that is
# merged on top of common. IMAGE defaults to OS_NAME, which has no overlay, so
# the default build copies nothing.
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    if [ -d "/ctx/system-files/${IMAGE}" ]; then \
        echo "==> Applying flavor overlay: ${IMAGE}"; \
        cp -avf "/ctx/system-files/${IMAGE}/." / ; \
    fi

# --- base ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/dnf.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/kernel.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/packages.sh

# --- hardware ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/hardware/display.sh

# Printing pulls in a large driver set; enable it once the image is otherwise
# settled and the layer cost is acceptable.
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
#     /ctx/modules/hardware/printing.sh

# --- desktop environment ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/de/kde/packages.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/de/kde/services.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/base/system.sh

# --- initramfs ---
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    /ctx/modules/initramfs.sh

# --- final cleanup ---
RUN --mount=type=tmpfs,dst=/var --mount=type=tmpfs,dst=/tmp \
    if [ -d /usr/etc ]; then rm -rf /usr/etc; fi \
    && find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' \
        ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' \
        -exec rm -f {} + \
    && rm -rf /tmp/* \
    && dnf5 clean all

RUN bootc container lint
