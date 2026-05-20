set -ouex pipefail

shopt -s nullglob

packages=(
  intel-gpu-firmware
  linux-firmware
  intel-media-driver
  libva
  libva-utils
  mesa-dri-drivers
  mesa-va-drivers
  mesa-vdpau-drivers
  switcheroo-control
  vulkan-loader
  vulkan-tools
  vulkan-validation-layers
  xrandr
  xset
)

dnf5 -y install "${packages[@]}"

systemctl enable switcheroo-control.service
