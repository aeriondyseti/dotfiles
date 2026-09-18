#!/bin/bash
# Re-copies the GRUB theme and grub.cfg into /boot. Run with sudo.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
rm -rf /boot/grub/themes/omarchy-green
cp -r "$SRC/omarchy-green" /boot/grub/themes/
install -m 644 "$SRC/grub.cfg" /boot/grub/grub.cfg
grep -q "^set gfxmode=" /boot/grub/grub.cfg
install -m 644 /boot/grub/grub.cfg "$SRC/grub.cfg.installed"
echo "Done."
