#!/usr/bin/env bash
# =============================================================================
# 02-migrate-configs.sh — Replace home-manager symlinks with real files
#
# This script:
#   1. Backs up your current home-manager-managed files
#   2. Removes the symlinks
#   3. Places real config files in their correct locations
#   4. Copies Claude configs from your dotfiles repo
#   5. Fixes your login shell to use system zsh
#
# IMPORTANT: Run 01-install-packages.sh first!
# =============================================================================
set -euo pipefail

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Migrating home-manager configs to real files ==="
echo "Backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# ── Helper: back up and remove a symlink, then place the real file ──────────
place_file() {
  local target="$1"   # where the file should live (e.g. ~/.gitconfig)
  local source="$2"   # where we're copying from

  # Back up existing file/symlink
  if [ -e "$target" ] || [ -L "$target" ]; then
    local rel="${target#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    # Dereference symlinks so we keep the actual content
    cp -aL "$target" "$BACKUP_DIR/$rel" 2>/dev/null || true
    rm -f "$target"
  fi

  mkdir -p "$(dirname "$target")"
  cp -a "$source" "$target"
  echo "  ✓ $target"
}

# ── Shell config files ──────────────────────────────────────────────────────
echo ""
echo "--- Shell configs ---"
place_file "$HOME/.zshrc"                      "$DOTFILES/.zshrc"
place_file "$HOME/.config/zsh/env.zsh"         "$DOTFILES/config/zsh/env.zsh"
place_file "$HOME/.config/zsh/aliases.zsh"     "$DOTFILES/config/zsh/aliases.zsh"
place_file "$HOME/.config/zsh/functions.zsh"   "$DOTFILES/config/zsh/functions.zsh"

# ── Git ─────────────────────────────────────────────────────────────────────
echo ""
echo "--- Git config ---"
place_file "$HOME/.gitconfig" "$DOTFILES/.gitconfig"

echo ""
echo "NOTE: ~/.gitconfig does NOT include [user] name/email."
echo "      If home-manager wasn't setting these, add them now:"
echo '      git config --global user.name "Your Name"'
echo '      git config --global user.email "you@example.com"'

# ── Bat ─────────────────────────────────────────────────────────────────────
echo ""
echo "--- Bat config ---"
place_file "$HOME/.config/bat/config" "$DOTFILES/config/bat/config"

# ── Oh-my-posh ──────────────────────────────────────────────────────────────
echo ""
echo "--- Oh-my-posh config ---"
if [ -f "$DOTFILES/config/oh-my-posh.toml" ]; then
  place_file "$HOME/.config/oh-my-posh/config.toml" "$DOTFILES/config/oh-my-posh.toml"
elif [ -f "$DOTFILES/config/oh-my-posh/config.toml" ]; then
  place_file "$HOME/.config/oh-my-posh/config.toml" "$DOTFILES/config/oh-my-posh/config.toml"
else
  echo "  ⚠ Could not find oh-my-posh config in $DOTFILES/config/"
  echo "    You'll need to copy it manually."
fi

# ── Claude Code configs ─────────────────────────────────────────────────────
echo ""
echo "--- Claude Code configs ---"

# settings.json
if [ -f "$DOTFILES/config/claude/settings.json" ]; then
  place_file "$HOME/.claude/settings.json" "$DOTFILES/config/claude/settings.json"
fi

# MCP servers — merge base + desktop JSON
if [ -f "$DOTFILES/config/claude/mcp-servers/base.json" ] && [ -f "$DOTFILES/config/claude/mcp-servers/desktop.json" ]; then
  echo "  Merging MCP server configs (base + desktop)..."
  BASE_SERVERS=$(jq '.mcpServers' "$DOTFILES/config/claude/mcp-servers/base.json")
  DESKTOP_SERVERS=$(jq '.mcpServers' "$DOTFILES/config/claude/mcp-servers/desktop.json")
  echo "$BASE_SERVERS" "$DESKTOP_SERVERS" | jq -s '{"mcpServers": (.[0] * .[1])}' > /tmp/claude-merged.json

  if [ -e "$HOME/.claude.json" ] || [ -L "$HOME/.claude.json" ]; then
    cp -aL "$HOME/.claude.json" "$BACKUP_DIR/.claude.json" 2>/dev/null || true
    rm -f "$HOME/.claude.json"
  fi
  cp /tmp/claude-merged.json "$HOME/.claude.json"
  rm /tmp/claude-merged.json
  echo "  ✓ ~/.claude.json"
elif [ -f "$DOTFILES/config/claude/mcp-servers/base.json" ]; then
  place_file "$HOME/.claude.json" "$DOTFILES/config/claude/mcp-servers/base.json"
fi

# Agent files
if [ -d "$DOTFILES/config/claude/agents" ]; then
  mkdir -p "$HOME/.claude/agents"
  for f in "$DOTFILES/config/claude/agents"/*; do
    [ -f "$f" ] && place_file "$HOME/.claude/agents/$(basename "$f")" "$f"
  done
fi

# ── Fix login shell ─────────────────────────────────────────────────────────
echo ""
echo "--- Fixing login shell ---"

SYSTEM_ZSH="/usr/bin/zsh"
if [ -x "$SYSTEM_ZSH" ]; then
  CURRENT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
  if [ "$CURRENT_SHELL" != "$SYSTEM_ZSH" ]; then
    echo "  Changing login shell from $CURRENT_SHELL to $SYSTEM_ZSH"
    sudo usermod -s "$SYSTEM_ZSH" "$USER"
    echo "  ✓ Login shell set to $SYSTEM_ZSH"
  else
    echo "  ✓ Login shell already set to $SYSTEM_ZSH"
  fi

  # Clean up any Nix shell entries from /etc/shells
  if grep -q "nix-profile" /etc/shells 2>/dev/null; then
    echo "  Removing Nix shell entries from /etc/shells..."
    sudo sed -i '/nix-profile/d' /etc/shells
    echo "  ✓ Cleaned /etc/shells"
  fi
else
  echo "  ⚠ $SYSTEM_ZSH not found. Install zsh first: sudo apt install zsh"
fi

# ── Remove home-manager generation symlink ──────────────────────────────────
echo ""
echo "--- Cleaning up home-manager profile link ---"
if [ -L "$HOME/.nix-profile" ]; then
  echo "  (Will be removed when Nix is uninstalled)"
fi

echo ""
echo "=== Config migration complete ==="
echo "Backup saved to: $BACKUP_DIR"
echo ""
echo "Next step: run 03-remove-nix.sh to uninstall home-manager and Nix."
