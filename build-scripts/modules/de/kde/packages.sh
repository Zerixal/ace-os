set -ouex pipefail

shopt -s nullglob

packages=(
  @kde-desktop-environment
)

dnf5 -y install "${packages[@]}" --allowerasing

mkdir -p /usr/lib/systemd/system-preset
cat > /usr/lib/systemd/system-preset/80-ace-kde.preset <<'EOF'
enable sddm.service
EOF

systemctl enable sddm.service
systemctl set-default graphical.target
