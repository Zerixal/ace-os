#!/usr/bin/env bash

set -ouex pipefail

shopt -s nullglob

# CPU frequency and turbo policy via TLP.
#
# TLP and power-profiles-daemon both write EPP and PLATFORM_PROFILE, so only one
# can own CPU policy. This module gives it to TLP because PPD has no concept of a
# frequency cap or of disabling turbo, which is what this config is for. Note
# that Fedora has no `tlp-ppd` package (that is Debian/Ubuntu), so there is no
# supported way to keep both.
#
# This is deliberately not TLP's stock 700-line /etc/tlp.conf. Only the settings
# that are actually wanted are set; everything unlisted keeps its intrinsic
# default.

packages=(
  tlp
)

dnf5 -y install "${packages[@]}"

# The tlp package ships its own /etc/tlp.conf, so it has to be written AFTER the
# install or rpm would overwrite it. That is also why it cannot live in
# system-files/, which is copied in before the module RUNs.
cat > /etc/tlp.conf <<'EOF'
TLP_ENABLE=1

# intel_pstate in active mode is required for PERF/BOOST/EPP to take effect.
# In passive mode the governor/frequency knobs below are silently ignored.
CPU_DRIVER_OPMODE_ON_AC=active
CPU_DRIVER_OPMODE_ON_BAT=active

# Turbo off, as requested. Works under intel_pstate active.
CPU_BOOST_ON_AC=0
CPU_BOOST_ON_BAT=0

# Frequency limits, expressed as a percentage of the available range. On
# intel_pstate active these are the CPU_MIN/MAX_PERF knobs; the older
# CPU_SCALING_GOVERNOR and CPU_*_MIN/MAX_FREQ knobs do nothing in this mode and
# are deliberately not set, because having them present is misleading.
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=10
CPU_MAX_PERF_ON_BAT=70

# Energy performance preference.
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# Platform profile. Requires intel_pstate passive or a driver that exposes it;
# harmless otherwise.
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=low-power

# WiFi power saving must stay off for Intel cards: iwlwifi powersave=1 causes
# packet loss and dropped connections. The default is off on AC and on on BAT,
# so pin both.
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=off

# Do not disable radios on battery. The default for this key is empty, but
# DEVICES_TO_DISABLE_ON_STARTUP is NOT set either -- disabling nfc/wwan/wifi at
# startup would leave the machine offline on first boot.
DEVICES_TO_DISABLE_ON_BAT=""

# Battery charge thresholds are intentionally NOT set here: TLP and
# ace-battery-threshold.service would both write the same thinkpad_acpi sysfs
# files. The systemd service owns them.
EOF

# TLP owns CPU policy, so the daemon that would fight it is masked. Persistent
# mask on purpose -- a --runtime mask lives in /run and evaporates on first boot.
if systemctl list-unit-files power-profiles-daemon.service >/dev/null 2>&1; then
  systemctl mask power-profiles-daemon.service
else
  echo "power-profiles-daemon not present; nothing to mask"
fi

systemctl enable tlp.service
