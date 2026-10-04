#!/usr/bin/env bash

set -ouex pipefail

shopt -s nullglob

# sddm.service is also enabled via the 80-ace-kde.preset shipped in
# system-files/common; this is the explicit path for images built without it.
if [ -L /etc/systemd/system/display-manager.service ]; then
  echo "display-manager.service already set; skipping sddm enable"
elif [ -f /usr/lib/systemd/system/sddm.service ] || [ -f /etc/systemd/system/sddm.service ]; then
  systemctl enable sddm.service
else
  echo "sddm.service not found; skipping enable"
fi

systemctl set-default graphical.target
