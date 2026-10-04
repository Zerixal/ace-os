#!/usr/bin/env bash

set -ouex pipefail

shopt -s nullglob

mkdir -p /var/tmp

KVER=$(ls /usr/lib/modules | head -n1)
INITRAMFS="/usr/lib/modules/$KVER/initramfs.img"

depmod -a "$KVER"

# Rebuild with a reproducible, host-independent image. The kernel package's own
# dracut run is hostonly and embeds build-host state, which breaks image
# reproducibility and leaks the build environment into every shipped image.
export DRACUT_NO_XATTR=1
dracut \
  --no-hostonly \
  --kver "$KVER" \
  --reproducible \
  --zstd \
  --add ostree \
  --add fido2 \
  -f "$INITRAMFS"

chmod 0600 "$INITRAMFS"
