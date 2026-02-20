#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(

  @kde-desktop-environment
)

dnf5 -y install "${packages[@]}"


dnf5 groupinstall "KDE Plasma Workspaces"
