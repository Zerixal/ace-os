#!/usr/bin/env bash

set -ouex pipefail

shopt -s nullglob

dnf5 -y install @kde-desktop-environment sddm --allowerasing
