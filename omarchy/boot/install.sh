#!/bin/bash
# Installs GRUB (themed menu) in front of Limine. Run with sudo.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
STAMP=$(date +%Y%m%d-%H%M%S)

echo "== Backups =="
cp /boot/limine.conf /boot/limine.conf.pre-grub
efibootmgr > "$SRC/efibootmgr-before.txt"
if [ -e /boot/grub ]; then mv /boot/grub "/boot/grub.bak-$STAMP"; echo "Moved old /boot/grub aside"; fi

echo "== Installing GRUB to the Omarchy boot partition =="
grub-install --target=x86_64-efi --efi-directory=/boot --boot-directory=/boot --bootloader-id=GRUB
mkdir -p /boot/grub/themes
cp -r "$SRC/omarchy-green" /boot/grub/themes/
install -m 644 "$SRC/grub.cfg" /boot/grub/grub.cfg

echo "== Making Limine a silent pass-through to Omarchy =="
sed -i -e 's|^timeout: .*|timeout: 0.5|' -e 's|^default_entry: .*|default_entry: Omarchy Linux/linux-omarchy|' /boot/limine.conf
grep -q '^quiet: yes' /boot/limine.conf || sed -i 's|^timeout: 0.5$|timeout: 0.5\nquiet: yes|' /boot/limine.conf

echo "== Checks =="
test -f /boot/EFI/GRUB/grubx64.efi
test -f /boot/EFI/limine/limine_x64.efi
test -f /boot/grub/themes/omarchy-green/theme.txt
grep -q '^default_entry: Omarchy Linux/linux-omarchy$' /boot/limine.conf
grep -q '^quiet: yes$' /boot/limine.conf
install -m 644 /boot/limine.conf "$SRC/limine.conf.copy"
install -m 644 /boot/grub/grub.cfg "$SRC/grub.cfg.installed"
efibootmgr
echo "Done."
