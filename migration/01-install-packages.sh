#!/usr/bin/env bash
# =============================================================================
# 01-install-packages.sh — Install system equivalents of Nix-managed packages
#
# Run this BEFORE removing Nix so you have working tools during migration.
# Review each section and comment out anything you don't need.
# =============================================================================
set -euo pipefail

echo "=== Installing system packages ==="

# ── Packages available in Ubuntu repos ──────────────────────────────────────
sudo apt update
sudo apt install -y \
  zsh \
  git \
  bat \
  fd-find \
  ripgrep \
  fzf \
  jq \
  btop \
  curl \
  unzip

# Ubuntu ships bat as "batcat" and fd as "fdfind" — create symlinks
# so your aliases and scripts work unchanged.
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true

# ── Oh My Zsh ───────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ── zsh plugins (if not using Oh My Zsh bundled versions) ───────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ── Packages NOT in Ubuntu repos — install from GitHub releases ─────────────

# eza (modern ls replacement)
echo "Installing eza..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
sudo apt update && sudo apt install -y eza

# delta (git diff viewer)
echo "Installing delta..."
DELTA_VER=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.tag_name')
curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/git-delta_${DELTA_VER}_amd64.deb" -o /tmp/delta.deb
sudo dpkg -i /tmp/delta.deb
rm /tmp/delta.deb

# zoxide (smart cd)
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# GitHub CLI (gh)
echo "Installing GitHub CLI..."
(type -p wget >/dev/null || sudo apt install wget -y) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update && sudo apt install -y gh

# oh-my-posh
echo "Installing oh-my-posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s

# lazygit
echo "Installing lazygit..."
LAZYGIT_VER=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | sed 's/^v//')
curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VER}/lazygit_${LAZYGIT_VER}_Linux_x86_64.tar.gz" -o /tmp/lazygit.tar.gz
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin/lazygit
rm /tmp/lazygit /tmp/lazygit.tar.gz

# lazydocker
echo "Installing lazydocker..."
LAZYDOCKER_VER=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | jq -r '.tag_name' | sed 's/^v//')
curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VER}/lazydocker_${LAZYDOCKER_VER}_Linux_x86_64.tar.gz" -o /tmp/lazydocker.tar.gz
tar xf /tmp/lazydocker.tar.gz -C /tmp lazydocker
sudo install /tmp/lazydocker /usr/local/bin/lazydocker
rm /tmp/lazydocker /tmp/lazydocker.tar.gz

echo ""
echo "=== Package installation complete ==="
echo "Verify with: bat --version && eza --version && fd --version && rg --version && delta --version && oh-my-posh --version"
