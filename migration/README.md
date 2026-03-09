# Nix → Native Migration

Three scripts, run in order from this directory. Each is safe to review and run independently.

## Quick Start

```bash
cd ~/Development/dotfiles/migration

# 1. Install system equivalents of all Nix-managed packages
./01-install-packages.sh

# 2. Replace home-manager symlinks with real config files
#    (backs up everything to ~/.config-backup-YYYYMMDD-HHMMSS first)
./02-migrate-configs.sh

# 3. Remove home-manager, Nix daemon, /nix store, and clean PATH
./03-remove-nix.sh
```

## Repo layout after migration

The config files now live in the main dotfiles repo:

```
dotfiles/
├── .zshrc                         # → ~/.zshrc
├── .gitconfig                     # → ~/.gitconfig
├── config/
│   ├── zsh/
│   │   ├── env.zsh                # → ~/.config/zsh/env.zsh
│   │   ├── aliases.zsh            # → ~/.config/zsh/aliases.zsh
│   │   └── functions.zsh          # → ~/.config/zsh/functions.zsh
│   ├── bat/config                 # → ~/.config/bat/config
│   ├── oh-my-posh.toml            # → ~/.config/oh-my-posh/config.toml
│   └── claude/                    # → ~/.claude/ and ~/.claude.json
├── migration/                     # ← you are here
│   ├── 01-install-packages.sh
│   ├── 02-migrate-configs.sh
│   └── 03-remove-nix.sh
└── nix/                           # kept for reference
```

`02-migrate-configs.sh` resolves all paths relative to the repo root, so
oh-my-posh and Claude configs are pulled from `config/` directly.

## After migration

- Log out and back in (or reboot) so PATH is fully clean
- Run `bat --version && eza --version && oh-my-posh --version` to verify
- Add `[user] name/email` to `~/.gitconfig` if not already set
- The `nix/` directory is untouched — delete it when you're confident
