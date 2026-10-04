#!/usr/bin/env bash

set -ouex pipefail

shopt -s nullglob

# ThinkPad X390 (8th gen, Intel UHD 620, no discrete GPU).
# Display/firmware/Wi-Fi are already covered by hardware/display.sh and
# base/packages.sh; this module covers the laptop-specific gaps.
packages=(
  # Bluetooth -- the X390 ships an Intel 9560 combo card and BT is how you use a
  # wireless mouse, headphones and the phone. Nothing else in the image pulls it in.
  bluez
  bluez-libs
  bluez-tools
  NetworkManager-bluetooth

  # Firmware updates over LVFS. Names verified against Fedora 44 Everything
  # x86_64 repodata: there is no fwupd-plugin-acpi or fwupd-plugin-servicing in
  # F44. fwupd-plugin-uefi-capsule-data carries the LVFS catalogue and
  # fwupd-efi the capsule apply helper, which is what a UEFI-only ThinkPad needs.
  fwupd
  fwupd-efi
  fwupd-plugin-uefi-capsule-data

  # Thunderbolt 3/4 USB-C docks. boltd authorises devices that present a security
  # level, which most docks do.
  bolt

  # NVMe health reporting and self-encrypting (Opal) drive unlock. The X390 ships
  # with an Opal-capable M.2 in some SKUs; without sed_opal it presents as a
  # locked disk and needs a one-time unlock.
  nvme-cli
  cryptsetup

  # Battery reporting
  plasma-pa
)

dnf5 -y install "${packages[@]}"

for svc in bluetooth.service fwupd.service power-profiles-daemon.service; do
  if systemctl list-unit-files "${svc}" >/dev/null 2>&1; then
    systemctl enable "${svc}"
  else
    echo "unit ${svc} not shipped; skipping"
  fi
done

# Battery charge thresholds. thinkpad_acpi exposes the ThinkPad's conserved-mode
# controls here; pinning the low threshold at 75% while allowing a full charge to
# 100% is the usual longevity setting and is what the manual calls Conservation
# Mode. Harmless on non-ThinkPad hardware: the sysfs files simply do not exist.
install -Dpm0644 /dev/stdin /usr/lib/systemd/system/ace-battery-threshold.service <<'EOF'
[Unit]
Description=Set ThinkPad battery charge thresholds
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=-/bin/sh -c 'for b in /sys/class/power_supply/BAT[0-9]*; do [ -w "$b/charge_control_end_threshold" ] || continue; echo 75 > "$b/charge_control_start_threshold"; echo 100 > "$b/charge_control_end_threshold"; done'

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ace-battery-threshold.service
