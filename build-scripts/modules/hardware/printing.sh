set -ouex pipefail

shopt -s nullglob

packages=(
  cups
  cups-browsed
  cups-filters
  cups-filters-driverless
  cups-ipptool
  cups-pk-helper
  system-config-printer
  system-config-printer-libs
  system-config-printer-udev

  sane-airscan
  sane-backends
  simple-scan

  avahi
  nss-mdns

  gutenprint
  gutenprint-cups
  hplip
  hplip-gui
  libsane-hpaio
  epson-inkjet-printer-escpr
  epson-inkjet-printer-escpr2
  printer-driver-brlaser
  ptouch-driver
)

dnf5 -y install "${packages[@]}"

systemctl enable avahi-daemon.service
systemctl enable cups.service
