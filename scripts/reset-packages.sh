#!/bin/bash
# Remove apt-installed CLI tools that are now managed by Homebrew.
# Run this once, then delete this script.
set -euo pipefail

echo "═══════════════════════════════════════════════════"
echo "  Removing apt-installed packages (brew takes over)"
echo "═══════════════════════════════════════════════════"
echo ""

APT_PACKAGES=(
    bat
    btop
    fd-find
    fzf
    gh
    git-delta
    jq
    ripgrep
    zoxide
)

echo "The following apt packages will be removed:"
for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l "$pkg" &>/dev/null 2>&1; then
        echo "  - $pkg (installed)"
    else
        echo "  - $pkg (not installed, skipping)"
    fi
done

echo ""
read -p "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

echo ""
echo "Removing apt packages..."
sudo apt remove -y "${APT_PACKAGES[@]}" 2>/dev/null || true
sudo apt autoremove -y

# Remove symlinks we may have created for bat/fd
echo ""
echo "Cleaning up symlinks..."
[ -L "$HOME/.local/bin/bat" ] && rm -v "$HOME/.local/bin/bat"
[ -L "$HOME/.local/bin/fd" ] && rm -v "$HOME/.local/bin/fd"

# Remove any manually installed binaries
echo ""
echo "Checking for manual installs in /usr/local/bin..."
for bin in lazygit lazydocker; do
    if [ -f "/usr/local/bin/$bin" ]; then
        echo "  Removing /usr/local/bin/$bin"
        sudo rm -f "/usr/local/bin/$bin"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Done. Verify brew versions are active:"
echo "═══════════════════════════════════════════════════"
echo ""
for cmd in bat eza fd fzf delta btop lazygit lazydocker gh jq rg zoxide; do
    loc=$(command -v "$cmd" 2>/dev/null || echo "NOT FOUND")
    echo "  $cmd → $loc"
done
