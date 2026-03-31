# Dotfiles Refactor — Chezmoi Migration

## Overview

This repo is being refactored from a hand-rolled `setup.sh` + module system into a **Chezmoi-managed dotfiles** repository. The goal is a single `chezmoi init --apply aeriondyseti/dotfiles` command that sets up any machine within minutes.

**Owner:** Kevin Whiteside (GitHub: aeriondyseti, alias: kdub)

## Current State

Chezmoi has been initialized. The source directory is `~/.local/share/chezmoi` (this repo). A `.chezmoi.toml.tmpl` exists with a working profile selector and color palette data. No files have been converted to chezmoi-managed format yet — the old structure is still in place alongside the new template.

### What exists now (old system — to be replaced)
- `setup.sh` (755 lines) — monolithic install/config script with module loader
- `reset.sh` (335 lines) — uninstall/cleanup script
- `lib/common.sh` — shared helpers (platform detection, color output)
- `modules/linux-amd64/` — 24 tool install modules (one file per tool)
- `profiles/{desktop,server,work}.sh` — module lists per environment
- `config/` — raw config files (zsh/, oh-my-posh/, claude/, bat/, etc.)
- `.zshrc` — current Oh My Zsh + OMP zsh config
- `.gitconfig` — git configuration with delta, gh credential helper
- `nix/`, `migration/`, `flake.nix`, `flake.lock` — legacy Nix system (DELETE these)
- `ROADMAP.md` — old roadmap (REPLACE with this document)

### What exists now (new system — keep and build on)
- `.chezmoi.toml.tmpl` — profile selector + color palette data
- `~/.config/chezmoi/chezmoi.toml` — generated config (machine-local, not in repo)

## Design Decisions (confirmed with user)

### Profiles

Three profiles, selected interactively on `chezmoi init`:

| Profile | Target OS | Theme | Use Case |
|---------|-----------|-------|----------|
| `work` | macOS (darwin/arm64) | Blue/white, clean | Work MacBook |
| `personal` | Linux (amd64, WSL/Ubuntu/Arch) | Dark teal + warm amber | Personal desktops |
| `server` | Linux (any arch) | Minimal/none | Homelab servers, VPS |

### Color Palettes

**Personal** (dark teal + warm amber):
- Background: `#0D1A1D` to `#1E3338`
- Primary/accent: `#00BCD4` (teal)
- Warm highlights: `#F67400` (amber/orange)
- Foreground: `#E8EAED`
- Reference: `config/kde/DarkTeal.colors` has the full KDE palette

**Work** (blue/white):
- Background: `#1E2A38`
- Primary: `#4A90D9` (blue)
- Accent: `#FFFFFF` (white)
- Foreground: `#E8EAED`

These are exposed as chezmoi data variables (`{{ .colorPrimary }}`, `{{ .colorAccent }}`, `{{ .colorBg }}`, `{{ .colorFg }}`).

### Shell: Zsh + Oh My Zsh + Oh My Posh

- **One prompt engine: Oh My Posh.** Starship is removed entirely.
- **Oh My Zsh stays** as the plugin framework.
- OMP config to be templated with profile colors.
- The Starship config (`config/starship.toml`) and module (`modules/linux-amd64/starship.sh`) should be deleted.

### OMZ Plugin List (trimmed from 24 to ~17)

**All profiles:**
```
aliases, colored-man-pages, command-not-found, dotenv, extract,
fzf, gh, git, gitignore, ssh, sudo,
zsh-autosuggestions, zsh-syntax-highlighting, chezmoi
```

**Conditional (template logic):**
- `brew` — work only (macOS)
- `docker`, `docker-compose` — personal + work only (not server)
- `uv` — personal + work only
- `mise` — personal + work only
- `1password` — personal + work only

**Removed:**
- `alias-finder` — user finds it annoying, do NOT re-add
- `catimg` — unused
- `cp` — unused
- `dnote` — unused
- `kitty` — unused
- `nmap` — unused
- `git-commit` — redundant with git plugin
- `git-extras` — redundant with git plugin

### Runtime Management: mise-en-place

mise replaces per-tool version management. Instead of separate modules installing bun, python, node, etc., mise owns all runtimes.

**Global tool versions per profile:**

Personal / Work:
```toml
[tools]
python = "3.13"
node = "lts"
bun = "latest"
kotlin = "2.1"
dotnet = "9"
```

Server:
```toml
[tools]
python = "3.13"
```

- **uv stays** — it handles Python dependency/venv management; mise handles which Python version
- Per-project `.mise.toml` files override global versions
- The OMZ `mise` plugin provides shell integration

### Package Installation

Chezmoi `run_once_` scripts replace the old module system:

- **macOS (work):** Homebrew
- **Linux (personal/server):** apt + direct binary installs where needed

The `run_once_` scripts should be idempotent and fast on re-run.

**Tools to install per profile:**

| Tool | Server | Personal | Work |
|------|--------|----------|------|
| bat | x | x | x |
| eza | x | x | x |
| fd | x | x | x |
| git | x | x | x |
| jq | x | x | x |
| ripgrep | x | x | x |
| mise | | x | x |
| oh-my-posh | | x | x |
| fzf | | x | x |
| zoxide | | x | x |
| delta | | x | x |
| btop | | x | x |
| lazygit | | x | x |
| docker | | x | x |
| lazydocker | | x | x |
| claude | | x | x |
| gemini | | x | x |

Runtimes (python, node, bun, kotlin, dotnet) are installed via mise, not directly.

## Target File Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Profile selector + data (EXISTS)
├── CLAUDE.md                       # This file
│
├── dot_zshrc.tmpl                  # Templated .zshrc (OMZ plugins vary by profile)
├── dot_gitconfig.tmpl              # Templated .gitconfig (credential helper varies by OS)
│
├── dot_config/
│   ├── zsh/
│   │   ├── aliases.zsh.tmpl       # Templated (OS-specific aliases like nala/apt)
│   │   ├── functions.zsh          # Mostly universal (static file)
│   │   ├── env.zsh.tmpl           # Templated (EDITOR, BROWSER differ by OS)
│   │   └── poshcontext.zsh.tmpl   # Personal only (Spotify via dbus, Linux-only)
│   ├── oh-my-posh/
│   │   └── config.toml.tmpl       # Templated with color palette
│   ├── mise/
│   │   └── config.toml.tmpl       # Templated tool versions per profile
│   ├── claude/
│   │   ├── settings.json
│   │   ├── agents/                 # AI agent persona files
│   │   └── mcp-servers/            # MCP server configs
│   ├── bat/
│   │   └── config                  # Static
│   └── kde/
│       └── DarkTeal.colors         # Personal only (Linux/KDE)
│
├── run_once_before_install-packages.sh.tmpl   # Package installation per OS/profile
├── run_once_before_install-mise.sh.tmpl       # Install mise + global tool versions
├── run_once_before_install-omz.sh.tmpl        # Install Oh My Zsh + plugins
├── run_once_before_install-omp.sh.tmpl        # Install Oh My Posh
│
└── .chezmoiignore                  # Ignore old files during transition
```

### Chezmoi naming conventions
- `dot_` prefix → maps to `.` in target (e.g., `dot_zshrc` → `~/.zshrc`)
- `.tmpl` suffix → processed as Go template with chezmoi data
- `run_once_before_` prefix → runs once before file deployment
- `run_once_after_` prefix → runs once after file deployment
- `private_` prefix → file has 0600 permissions
- Directories: `dot_config/` → `~/.config/`

## Aliases — What to Keep

The current `config/zsh/aliases.zsh` has ~100 aliases. These should be preserved (with fixes noted):

### Keep as-is
- General: `cls`, `path`, `now`
- Safety: `rm -i`, `mv -i`, `cp -i`
- Networking: `ports`, `myip`, `localip` (note: `localip` uses `hostname -I`, Linux-only)
- bat: `cat='bat --paging=never'`, `catp='bat'`
- btop: `top='btop'`
- bun: `b`, `br`, `bx`, `bi`, `ba`, `bad`
- Claude: `c`, `cc`, `c!`, `cc!`
- Docker: all `d*` and `dc*` aliases
- eza: `ls`, `ll`, `llm`, `lx`, `lt`
- fd: `f`, `ff`, `fh`
- gemini: `gm`, `gmc`
- lazydocker: `lzd`
- lazygit: `lg`
- ripgrep: `rg` (but fix hardcoded path `/usr/bin/rg`), `rgi`
- UV: `uvr`, `uvs`, `uva`, `uvad`, `uvp`
- zoxide: `cd='z'`, `cdi='zi'`

### Fix
- `alias sc='systemctl'` / `ssc='sudo systemctl'` → Linux only (template guard)
- `alias apt='nala'` → Linux only, and only if nala is installed
- `alias rg='/usr/bin/rg ...'` → use `command rg` instead of hardcoded path
- Shell quick-edit aliases at bottom: still reference `.bashrc` and `bash/` paths — **rewrite for zsh**:
  ```
  alias editshrc='$EDITOR ~/.zshrc'
  alias editshaliases='$EDITOR ~/.config/zsh/aliases.zsh'
  alias editshfuncs='$EDITOR ~/.config/zsh/functions.zsh'
  alias editshenv='$EDITOR ~/.config/zsh/env.zsh'
  alias shreload='source ~/.zshrc'
  ```

### Conditional by profile
- Docker aliases → personal + work only
- bun aliases → personal + work only (managed by mise)
- Claude/gemini aliases → personal + work only
- systemctl aliases → Linux only
- nala alias → Linux only

## Functions — What to Keep

All functions in `config/zsh/functions.zsh` are useful. Keep them all:
- `mkcd`, `extract`, `backupfile`/`bak`, `serve` — universal
- `dbash`, `dlogs`, `dstop`, `dclean`, `dnuke` — docker (personal + work)
- `fcd`, `fedit`, `fbranch`/`fbr`, `fkillProc`/`fkill`, `fgitlog`, `fkillport`/`fkp` — fzf-powered (personal + work)
- `jqpretty`/`jqp` — universal

Note: `fkillport` uses `ss` and `grep -oP` (Linux-only). Template-guard or rewrite for macOS.

## Environment — What to Keep/Fix

From `config/zsh/env.zsh`:
- `EDITOR=code` → keep for work, but template: should be `code` on macOS, `code` on personal (WSL), `vim` or `nano` on server
- `BROWSER=xdg-open` → Linux only, remove on macOS (macOS uses `open` natively)
- `BAT_THEME="Dracula"` → keep, universal
- `MANPAGER` with bat → keep, universal
- `FZF_DEFAULT_OPTS` → keep, personal + work
- `PYTHONDONTWRITEBYTECODE=1`, `PYTHONUNBUFFERED=1` → keep, universal
- `HF_HUB_ENABLE_HF_TRANSFER=1` → keep, personal + work
- PATH entries: `.local/bin` (keep), `.spicetify` (personal only), `.bun/bin` (replaced by mise), `.lmstudio/bin` (personal only)

## OMP Prompt — What to Keep/Modify

The current `config/oh-my-posh.toml` layout is exactly what the user wants. Keep the structure:

```
╭─ :<path> <git> <tool versions...>                    <time>
╰─ user@host ❯
```

With transient prompt: `❯`

Changes needed:
- Template the color values using chezmoi data instead of hardcoded `blue`, `magenta`, etc.
- `poshcontext.zsh` (Spotify integration via dbus) is Linux/personal only — skip on work/server
- The Spotify rprompt segment should be conditional (personal profile only)
- The OMP init patching hack in `.zshrc` (sed on cached init file) should be personal-only

## Git Config — Notes

The `.gitconfig` is mostly universal. Template considerations:
- `credential` helper uses `gh auth git-credential` — works on both macOS and Linux if gh is installed
- `core.pager = delta` — requires delta to be installed (all profiles except maybe server)
- `user.name` and `user.email` are not set in the file — chezmoi should template these or they should be set via `chezmoi init` prompts

## Files to DELETE

These are vestiges of the old system and should be removed from the repo:

- `setup.sh` — replaced by chezmoi
- `reset.sh` — replaced by chezmoi
- `lib/` — replaced by chezmoi
- `modules/` — replaced by chezmoi + mise
- `profiles/` — replaced by `.chezmoi.toml.tmpl` data
- `nix/` — user confirmed Nix is gone
- `migration/` — Nix migration scripts, no longer needed
- `flake.nix`, `flake.lock` — Nix artifacts
- `config/starship.toml` — Starship is removed, OMP wins
- `ROADMAP.md` — replaced by this document
- `dependencies.txt`, `debug*.txt` — development artifacts
- `terminal-colors.md` — reference only, palette is now in chezmoi data

Do NOT delete these until the chezmoi equivalents are in place and tested.

## Migration Order

Execute in this order. Each step should be independently committable and testable.

### Step 1: Convert .zshrc → dot_zshrc.tmpl
- Rename to chezmoi format
- Template the OMZ plugin list by profile
- Template the OMP init (skip on server)
- Template the poshcontext patch (personal only)
- Fix fzf completion paths (differ between macOS homebrew and Linux)
- Remove cargo env line if not needed (mise handles runtimes)
- Test with `chezmoi diff` and `chezmoi apply --dry-run`

### Step 2: Convert config/zsh/ → dot_config/zsh/
- `aliases.zsh.tmpl` — template OS-specific aliases, fix bash references
- `functions.zsh` — keep static, or template docker/fzf sections by profile
- `env.zsh.tmpl` — template EDITOR, BROWSER, PATH entries by profile
- `poshcontext.zsh` — mark as personal-only via `.chezmoiignore`

### Step 3: Convert OMP config → dot_config/oh-my-posh/config.toml.tmpl
- Template color values from chezmoi data
- Conditional Spotify rprompt (personal only)
- Skip OMP entirely on server profile (via `.chezmoiignore`)

### Step 4: Add mise config → dot_config/mise/config.toml.tmpl
- Global tool versions per profile
- Test mise install on both macOS and Linux

### Step 5: Create run_once install scripts
- `run_once_before_install-packages.sh.tmpl` — OS detection, install core CLI tools
- `run_once_before_install-omz.sh.tmpl` — install Oh My Zsh + community plugins
- `run_once_before_install-omp.sh.tmpl` — install Oh My Posh (skip server)
- `run_once_before_install-mise.sh.tmpl` — install mise + run `mise install`

### Step 6: Convert remaining configs
- `.gitconfig` → `dot_gitconfig.tmpl`
- `config/bat/` → `dot_config/bat/`
- `config/claude/` → `dot_config/claude/` (personal + work only)
- `config/kde/` → personal only via `.chezmoiignore`

### Step 7: Create .chezmoiignore
- Ignore old files (setup.sh, modules/, etc.) so chezmoi doesn't try to deploy them
- Ignore profile-specific files on wrong profiles (KDE on macOS, brew on Linux, etc.)

### Step 8: Clean up
- Delete old system files (setup.sh, reset.sh, lib/, modules/, profiles/, nix/, migration/, etc.)
- Update README.md with new usage instructions
- Test full `chezmoi init --apply` from scratch

## Testing

Before considering a step complete:
1. `chezmoi diff` — shows what would change
2. `chezmoi apply --dry-run` — simulates apply
3. `chezmoi apply` — actually apply
4. Open a new terminal and verify everything works

For cross-platform testing:
- Work profile: test on macOS directly
- Personal profile: test in WSL or Linux VM
- Server profile: test on a fresh Ubuntu server (or Docker container)

## Notes for Claude

- The user prefers concise, direct communication. No trailing summaries.
- The user wants to fully understand every file — don't over-abstract. Simple templates > clever ones.
- When in doubt, keep it simple. The user values maintainability above all else.
- Do NOT re-add `alias-finder` to OMZ plugins. The user explicitly removed it.
- The old module system was well-designed but too complex. Chezmoi should feel simpler.
- `uv` is for Python packages/venvs; `mise` manages the Python version itself. They coexist.
- The poshcontext.zsh Spotify hack uses dbus (Linux-only). It's a personal-profile feature.
