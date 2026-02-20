#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

RELEASE="$(rpm -E %fedora)"
DATE=$(date +%Y%m%d)

echo "ace" | tee "/etc/hostname"
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Ace\"|
s|^ID=.*|ID=\"ace\"|
s|^VERSION=.*|VERSION=\"${RELEASE}.${DATE}\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Ace ${RELEASE}.${DATE}\"|
s|^LOGO=.*|LOGO=\"cachyos\"|
s|^HOME_URL=.*|HOME_URL=\"https://github.com/aceday/ace-os\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"https://github.com/aceday/ace-os/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"https://github.com/aceday/ace-os/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:aceday:ace\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"https://github.com/aceday/ace-os\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="ace"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +
rm -rf /tmp/* || true
dnf5 clean all

echo "::endgroup::"