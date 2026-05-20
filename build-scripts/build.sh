#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-ace-os}"

echo "=== Building: $IMAGE ==="

modules=(
  "base.dnf"
  "base.kernel"
  "base.packages"
  "hardware.display"
  # "hardware.printing"
  "de.kde.packages"
  "base.system"
)

for mod in "${modules[@]}"; do
  path="/ctx/modules/${mod//./\/}.sh"
  echo "::group:: === $(basename "$path") ==="
  bash "$path"
  echo "::endgroup::"
done

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +
rm -rf /tmp/* || true
dnf5 clean all

echo "==> Build complete: $IMAGE"
