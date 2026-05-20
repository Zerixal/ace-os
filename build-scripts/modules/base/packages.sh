set -ouex pipefail

shopt -s nullglob

packages=(
  @networkmanager-submodules
  NetworkManager-wifi
  iwlegacy-firmware
  iwlwifi-dvm-firmware
  iwlwifi-mvm-firmware

  alsa-firmware
  alsa-sof-firmware
  alsa-tools-firmware

  audit
  audispd-plugins
  cifs-utils
  firewalld
  fprintd
  fprintd-pam
  fuse
  fuse-devel
  man-pages
  systemd-container
  unzip
  whois
  inotify-tools
  gum
  xdg-user-dirs
  xdg-terminal-exec
  xdg-user-dirs-gtk

  gvfs-mtp
  gvfs-smb
  ifuse
  jmtpfs

  libcamera
  libcamera-v4l2
  libcamera-gstreamer
  libcamera-tools
  libimobiledevice
  android-tools

  pipewire
  pipewire-pulseaudio
  pipewire-alsa
  pipewire-jack-audio-connection-kit
  wireplumber
  pipewire-plugin-libcamera

  git
  distrobox
  yq

  @multimedia
  ffmpeg
  gstreamer1-plugins-base
  gstreamer1-plugins-good
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-bad-free-libs
  qt6-qtmultimedia
  lame-libs
  libjxl
  ffmpegthumbnailer
  glycin-libs
  glycin-gtk4-libs
  glycin-loaders
  glycin-thumbnailer
  gdk-pixbuf2
  libopenraw

  @fonts
  glibc-all-langpacks
  jetbrains-mono-fonts
  fira-code-fonts
  dejavu-fonts-all
  nerd-fonts

  thermald
  power-profiles-daemon
  ksmtuned
  cachyos-ksm-settings
  cachyos-settings
  scx-scheds-git
  scx-tools-git
  scx-manager
  scxctl

  glx-utils
  mesa*
  *vulkan*

  flatpak

  plymouth
  plymouth-system-theme
)

dnf5 -y install "${packages[@]}" --exclude=scx-tools-nightly --exclude=scx-scheds-nightly
