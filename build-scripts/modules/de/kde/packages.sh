set -ouex pipefail

shopt -s nullglob

packages=(
  @kde-desktop-environment
  sddm
)

dnf5 -y install "${packages[@]}" --allowerasing

mkdir -p /usr/lib/systemd/system-preset
cat > /usr/lib/systemd/system-preset/80-ace-kde.preset <<'EOF'
enable sddm.service
EOF

if [ -L /etc/systemd/system/display-manager.service ]; then
  echo "display-manager.service already set; skipping sddm enable"
elif [ -f /usr/lib/systemd/system/sddm.service ] || [ -f /etc/systemd/system/sddm.service ]; then
  systemctl enable sddm.service
else
  echo "sddm.service not found; skipping enable"
fi
systemctl set-default graphical.target
