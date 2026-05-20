set -ouex pipefail

shopt -s nullglob

packages=(
  @kde-desktop-environment
)

dnf5 -y install "${packages[@]}" --allowerasing

systemctl enable sddm.service
systemctl set-default graphical.target
