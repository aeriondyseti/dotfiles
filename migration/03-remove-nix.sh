#!/usr/bin/env bash
# =============================================================================
# 03-remove-nix.sh — Remove home-manager and Nix entirely
#
# Run this AFTER:
#   - 01-install-packages.sh (system packages are installed)
#   - 02-migrate-configs.sh  (config files are real, not symlinks)
#
# This script removes home-manager, then Nix, then cleans up leftovers.
# =============================================================================
set -euo pipefail

echo "=== Removing home-manager and Nix ==="
echo ""
echo "This will:"
echo "  1. Remove home-manager generations"
echo "  2. Uninstall Nix (daemon or single-user)"
echo "  3. Clean up leftover files and PATH entries"
echo ""
read -p "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ── Step 1: Remove home-manager ─────────────────────────────────────────────
echo ""
echo "--- Removing home-manager ---"
if command -v home-manager &>/dev/null; then
  # Unlink all managed files first
  home-manager uninstall 2>/dev/null || echo "  home-manager uninstall returned non-zero (may be fine)"
  echo "  ✓ home-manager uninstalled"
else
  echo "  home-manager not found in PATH (may already be partially removed)"
  # Manual cleanup of the profile link
  if [ -L "$HOME/.nix-profile" ]; then
    rm "$HOME/.nix-profile"
    echo "  ✓ Removed ~/.nix-profile symlink"
  fi
fi

# Remove home-manager state/data
rm -rf "$HOME/.local/state/home-manager" 2>/dev/null || true
rm -rf "$HOME/.local/state/nix" 2>/dev/null || true

# ── Step 2: Uninstall Nix ───────────────────────────────────────────────────
echo ""
echo "--- Uninstalling Nix ---"

# Check if it's a multi-user (daemon) install
if [ -f /etc/nix/nix.conf ] || systemctl is-active --quiet nix-daemon 2>/dev/null; then
  echo "  Detected multi-user (daemon) Nix install"

  # Stop and disable the daemon
  sudo systemctl stop nix-daemon.service 2>/dev/null || true
  sudo systemctl stop nix-daemon.socket 2>/dev/null || true
  sudo systemctl disable nix-daemon.service 2>/dev/null || true
  sudo systemctl disable nix-daemon.socket 2>/dev/null || true
  echo "  ✓ Stopped nix-daemon"

  # Remove systemd unit files
  sudo rm -f /etc/systemd/system/nix-daemon.service
  sudo rm -f /etc/systemd/system/nix-daemon.socket
  sudo rm -f /usr/lib/systemd/system/nix-daemon.service
  sudo rm -f /usr/lib/systemd/system/nix-daemon.socket
  sudo systemctl daemon-reload

  # Remove the Nix store and daemon config
  sudo rm -rf /nix
  echo "  ✓ Removed /nix"

  # Remove nix build users and group
  for i in $(seq 1 32); do
    sudo userdel "nixbld$i" 2>/dev/null || true
  done
  sudo groupdel nixbld 2>/dev/null || true
  echo "  ✓ Removed nixbld users and group"

  # Remove daemon config
  sudo rm -rf /etc/nix
  echo "  ✓ Removed /etc/nix"

else
  echo "  Detected single-user Nix install"
  rm -rf /nix 2>/dev/null || sudo rm -rf /nix
  echo "  ✓ Removed /nix"
fi

# ── Step 3: Clean up user-level Nix files ───────────────────────────────────
echo ""
echo "--- Cleaning up user-level Nix files ---"

rm -rf "$HOME/.nix-profile" 2>/dev/null || true
rm -rf "$HOME/.nix-defexpr" 2>/dev/null || true
rm -rf "$HOME/.nix-channels" 2>/dev/null || true
rm -rf "$HOME/.cache/nix" 2>/dev/null || true
rm -rf "$HOME/.local/state/nix" 2>/dev/null || true
rm -rf "$HOME/.config/nix" 2>/dev/null || true
rm -rf "$HOME/.config/home-manager" 2>/dev/null || true
echo "  ✓ Removed ~/.nix-* and related directories"

# ── Step 4: Clean up shell profile sourcing ─────────────────────────────────
echo ""
echo "--- Cleaning Nix entries from shell profiles ---"

clean_file() {
  local f="$1"
  if [ -f "$f" ] && grep -q "nix" "$f" 2>/dev/null; then
    # Remove lines that source nix-daemon.sh or nix profile scripts
    sed -i '/# Nix$/d' "$f"
    sed -i '/nix-daemon\.sh/d' "$f"
    sed -i '/nix-profile/d' "$f"
    sed -i '/\.nix-profile/d' "$f"
    sed -i '/nix\.sh/d' "$f"
    # Remove the block that the Nix installer adds
    sed -i '/# added by Nix installer/,/^$/d' "$f"
    echo "  ✓ Cleaned $f"
  fi
}

clean_file "$HOME/.profile"
clean_file "$HOME/.bash_profile"
clean_file "$HOME/.bashrc"
clean_file "$HOME/.zprofile"
# Don't touch .zshrc — we replaced it in step 02

# Also check /etc
if grep -q "nix" /etc/profile 2>/dev/null; then
  sudo sed -i '/nix-daemon\.sh/d' /etc/profile
  echo "  ✓ Cleaned /etc/profile"
fi
if [ -f /etc/profile.d/nix.sh ]; then
  sudo rm -f /etc/profile.d/nix.sh
  echo "  ✓ Removed /etc/profile.d/nix.sh"
fi
if [ -f /etc/bash.bashrc ] && grep -q "nix" /etc/bash.bashrc 2>/dev/null; then
  sudo sed -i '/nix-daemon\.sh/d' /etc/bash.bashrc
  echo "  ✓ Cleaned /etc/bash.bashrc"
fi

# ── Step 5: Verify ──────────────────────────────────────────────────────────
echo ""
echo "=== Nix removal complete ==="
echo ""
echo "Verify:"
echo "  • No /nix directory:        ls -d /nix 2>/dev/null || echo 'gone'"
echo "  • No nix in PATH:           echo \$PATH | tr : '\\n' | grep nix"
echo "  • Shell is system zsh:      echo \$SHELL"
echo "  • Tools work:               bat --version && eza --version && git --version"
echo ""
echo "You may need to log out and back in (or reboot) for all PATH changes to take effect."
echo ""
echo "Your dotfiles repo at ~/Development/dotfiles is untouched — you can"
echo "keep it as a reference or repurpose it as a plain dotfiles repo."
