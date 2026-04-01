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

### Color Strategy: ANSI Palette via Ghostty

**Ghostty is the source of truth for all colors.** Tools reference ANSI color names (0–15) instead of hardcoding hex values. Changing the Ghostty palette changes the look of every tool at once.

Both work and personal use Ghostty as their terminal emulator.

#### Personal Palette (dark teal + warm amber)

| Slot | ANSI Role | Hex | Notes |
|------|-----------|-----|-------|
| 0 | black | `#1c1c1c` | True dark |
| 1 | red | `#aa2020` | Deep red, high saturation |
| 2 | green | `#1a9050` | Emerald, complements teal |
| 3 | yellow | `#cca300` | Warm amber (anchor) |
| 4 | blue | `#2a6099` | Steel blue, distinct from cyan |
| 5 | magenta | `#7a29a3` | Purple (anchor) |
| 6 | cyan | `#277b8e` | Dark teal (anchor) |
| 7 | white | `#dcdcdc` | Normal foreground |
| 8 | bright black | `#555555` | Comments, muted text |
| 9 | bright red | `#e62020` | Error highlights |
| 10 | bright green | `#00e060` | Success, staged |
| 11 | bright yellow | `#d6d600` | Warning, modifications (anchor) |
| 12 | bright blue | `#0090ff` | Info, links, paths (anchor) |
| 13 | bright magenta | `#d600d6` | Keywords, special (anchor) |
| 14 | bright cyan | `#00e9e9` | Types, secondary info (anchor) |
| 15 | bright white | `#f5f5f5` | Bright foreground |

Background: `#000000`. Foreground: `#ffffff`.
Brightness ratio follows 3/11 and 6/14 pattern: normal variants ~60% sat at ~35–40% lightness, bright variants 100% sat at ~42–46% lightness.

#### Work Palette (blue/white)

TBD — will follow the same ANSI slot structure with a blue/white aesthetic. Define before starting Step 0.

#### Server Palette

Not applicable — servers typically use SSH from a local terminal, so the local Ghostty palette applies.

#### How each tool uses the palette

| Tool | Color method | Needs hex? | Chezmoi templating needed? |
|------|-------------|------------|---------------------------|
| **Ghostty** | Palette definition | Yes — the only place | Yes — per profile |
| **OMP** | ANSI names (`lightBlue`, `cyan`, etc.) | No | No (uses ANSI names directly) |
| **bat** | Built-in `ansi` theme | No | No (just set theme name) |
| **micro** | ANSI names (`brightblue`, `green`, etc.) | No | No (existing `omp-match.micro` already works) |
| **delta** | ANSI color names in gitconfig | No | No |
| **fzf** | `--color` flag with ANSI numbers | No | No |
| **eza** | Default ANSI colors | No | No |
| **btop** | Theme file or terminal colors | No | No (use TTY-aware mode) |
| **lazygit** | Theme in config YAML | No | No |

### Shell: Zsh + Oh My Zsh + Oh My Posh

- **One prompt engine: Oh My Posh.** Starship is removed entirely.
- **Oh My Zsh stays** as the plugin framework.
- OMP config uses ANSI color names — no chezmoi color templating needed.
- The Starship config (`config/starship.toml`) and module (`modules/linux-amd64/starship.sh`) should be deleted.

### Login Shell Setup

PATH additions and environment setup that should run once at login go in `.zprofile`, not `.zshrc`:
- PATH entries (`.local/bin`, tool-specific paths)
- XDG directory variables
- `LANG`/`LC_ALL`

Interactive-only settings (aliases, prompt, completions) stay in `.zshrc`.

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
kotlin = "2.3"
dotnet = "10"
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
| nerd fonts | | x | x |

Runtimes (python, node, bun, kotlin, dotnet) are installed via mise, not directly.

## Target File Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Profile selector + palette data (EXISTS)
├── CLAUDE.md                       # This file
│
├── dot_zprofile.tmpl               # Login shell: PATH, XDG, LANG
├── dot_zshrc.tmpl                  # Interactive shell: OMZ, OMP, completions
├── dot_gitconfig.tmpl              # Templated .gitconfig
│
├── dot_config/
│   ├── ghostty/
│   │   └── config.tmpl            # Templated with palette per profile
│   ├── zsh/
│   │   ├── aliases.zsh.tmpl       # Templated (OS-specific aliases)
│   │   ├── functions.zsh.tmpl     # Templated (docker/fzf sections by profile)
│   │   ├── env.zsh.tmpl           # Templated (EDITOR, VISUAL, PAGER, etc.)
│   │   └── poshcontext.zsh        # Personal only (Spotify via dbus, Linux-only)
│   ├── oh-my-posh/
│   │   └── config.toml            # Static — uses ANSI color names, no templating
│   ├── mise/
│   │   └── config.toml.tmpl       # Templated tool versions per profile
│   ├── micro/
│   │   ├── settings.json          # Static (colorscheme = omp-match)
│   │   ├── bindings.json          # Static
│   │   └── colorschemes/
│   │       └── omp-match.micro    # Static — uses ANSI color names
│   ├── bat/
│   │   └── config                 # Static (--theme="ansi")
│   ├── gh/
│   │   └── config.yml             # Static (protocol, aliases)
│   ├── btop/
│   │   └── btop.conf              # Static or minimal template
│   ├── claude/
│   │   ├── settings.json
│   │   ├── agents/                # AI agent persona files
│   │   └── mcp-servers/           # MCP server configs
│   └── kde/
│       └── DarkTeal.colors        # Personal only (Linux/KDE)
│
├── run_once_before_install-packages.sh.tmpl   # Package installation per OS/profile
├── run_once_before_install-fonts.sh.tmpl      # Nerd font installation (personal + work)
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

## Environment Variables

### All profiles

```bash
# Editors
EDITOR        # micro (personal), code (work), nano (server)
VISUAL        # code (personal + work), same as EDITOR (server)

# Pagers
PAGER="less"
LESS="-R -F -X"
MANROFFOPT="-c"
MANPAGER="sh -c 'col -bx | bat -l man -p'"

# XDG (all profiles — ensures consistent config paths everywhere)
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_CACHE_HOME="$HOME/.cache"
XDG_STATE_HOME="$HOME/.local/state"

# Locale
LANG="en_US.UTF-8"

# bat
BAT_THEME="ansi"

# Python
PYTHONDONTWRITEBYTECODE=1
PYTHONUNBUFFERED=1

# FZF
FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
```

### Personal + work only
```bash
HF_HUB_ENABLE_HF_TRANSFER=1
```

### Linux only
```bash
BROWSER="xdg-open"
SYSTEMD_LESS="$LESS"
```

### PATH entries (in .zprofile)
```bash
$HOME/.local/bin          # all profiles
$HOME/.spicetify          # personal only
$HOME/.lmstudio/bin       # personal only
```

Note: `.bun/bin` is removed — mise manages bun.

## Aliases — What to Keep

### Keep as-is (all profiles)
- General: `cls`, `path`, `now`
- Safety: `rm -i`, `mv -i`, `cp -i`, `rmrf`, `mvf`, `cpf`
- Networking: `ports`, `myip`, `localip` (note: `localip` uses `hostname -I`, Linux-only)
- bat: `cat='bat --paging=never'`, `catp='bat'`
- btop: `top='btop'`
- eza: `ls`, `ll`, `llm`, `lx`, `lt`
- fd: `f`, `ff`, `fh`
- zoxide: `cd='z'`, `cdi='zi'`
- Shell quick-edits (already fixed for zsh on personal):
  ```
  alias editshrc='$EDITOR ~/.zshrc'
  alias editshaliases='$EDITOR ~/.config/zsh/aliases.zsh'
  alias editshfuncs='$EDITOR ~/.config/zsh/functions.zsh'
  alias editshenv='$EDITOR ~/.config/zsh/env.zsh'
  alias shreload='source ~/.zshrc'
  ```

### Keep (personal + work only)
- bun: `b`, `br`, `bx`, `bi`, `ba`, `bad`
- Claude: `c`, `cc`, `c!`, `cc!`
- Docker: all `d*` and `dc*` aliases
- gemini: `gm`, `gmc`
- lazydocker: `lzd`
- lazygit: `lg`
- UV: `uvr`, `uvs`, `uva`, `uvad`, `uvp`

### Fix
- `alias rg='/usr/bin/rg ...'` → use `command rg` instead of hardcoded path
- `alias rgi='/usr/bin/rg ...'` → same fix

### Conditional by platform
- `sc`, `ssc` (systemctl) → Linux only
- `apt='nala'` → Linux only, only if nala is installed
- `localip` → Linux only (uses `hostname -I`)
- `ports` → Linux only (uses `ss`)

## Functions — What to Keep

All functions in `config/zsh/functions.zsh` are useful. Keep them all:
- `mkcd`, `extract`, `backupfile`/`bak`, `serve` — universal
- `dbash`, `dlogs`, `dstop`, `dclean`, `dnuke` — docker (personal + work)
- `fcd`, `fedit`, `fbranch`/`fbr`, `fkillProc`/`fkill`, `fgitlog`, `fkillport`/`fkp` — fzf-powered (personal + work)
- `jqpretty`/`jqp` — universal

Note: `fkillport` uses `ss` and `grep -oP` (Linux-only). Template-guard or rewrite for macOS.

## OMP Prompt

### Layout (work config as structural base)

```
╭─ :<path> <git> <tool versions...>                    <time>
╰─ user@host ❯
```

With transient prompt: `❯` (turns red on non-zero exit code)

### Git segment

Shows info only when relevant — quiet when clean:
```
 main                         # clean, up to date
 main ✓2 ~3 ⇡1 ⇣2            # full status
 main ~1                      # just uncommitted changes
 main ✓3 ⇡1                   # staged + ahead
 main [rebasing]              # operation in progress
```

- `✓N` (green) — staged changes count
- `~N` (yellow) — uncommitted changes count (includes untracked)
- `⇡N` (cyan) — commits ahead of origin
- `⇣N` (red) — commits behind origin
- `[rebasing]`, `[merging]`, `[cherry-pick]` (red) — in-progress operations

Template:
```
{{ .HEAD }}
{{- if gt (add .Staging.Added .Staging.Modified .Staging.Deleted) 0 }} <green>✓{{ add .Staging.Added .Staging.Modified .Staging.Deleted }}</>{{ end }}
{{- if gt (add .Working.Added .Working.Modified .Working.Deleted .Working.Untracked) 0 }} <yellow>~{{ add .Working.Added .Working.Modified .Working.Deleted .Working.Untracked }}</>{{ end }}
{{- if gt .Ahead 0 }} <cyan>⇡{{ .Ahead }}</>{{ end }}
{{- if gt .Behind 0 }} <red>⇣{{ .Behind }}</>{{ end }}
{{- if .Rebase }} <red>[rebasing]</>{{ end }}
{{- if .CherryPick }} <red>[cherry-pick]</>{{ end }}
{{- if .Merge }} <red>[merging]</>{{ end }}
```

### Session segment (two-tone)
```
foreground = "lightCyan"
template = "<b>{{ .UserName }}<cyan>@{{ .HostName }}</></b>"
```
Username in bright cyan, hostname in darker cyan — easy to identify the host when SSH'd.

### Tool version segments
All use nerd font icons and `yellow` foreground:
- dotnet: `\ue77f`, kotlin: `\ue634`, node: `\ue718`, python: `\ue73c`
- rust: `\ue7a8`, bun: `\ue76f`, npm: `\ue71e`, react: `\ue7ba`, docker: `\ue7b0`

### Spotify rprompt
Personal profile only. Uses `poshcontext.zsh` to poll Spotify via dbus.
The OMP precmd wrapping hack (from personal `.zshrc`) is cleaner than the sed approach (from work `.zshrc`). Use the precmd wrapping version.

## Git Config — Notes

The personal `.gitconfig` has conventional commit aliases (`feat`, `fix`, `chore`, etc.) with scope and attention flag support. The work `.gitconfig` is simpler (`s`, `d`, `l` only).

Template considerations:
- `user.name` and `user.email` → prompt during `chezmoi init`, store in chezmoi data
- `credential` helper uses `gh auth git-credential` — works on both macOS and Linux
- `core.pager = delta` — requires delta (all profiles except server)
- Conventional commit aliases → keep on all profiles (they're useful everywhere)
- `oh-my-zsh` section and `coderabbit` section → machine-specific, don't template

## Tool Configs to Capture

### bat (`~/.config/bat/config`)
```
--theme="ansi"
--pager="less -FR"
```
Static file, no templating. The `ansi` theme inherits terminal colors from Ghostty.

### micro (`~/.config/micro/`)
- `settings.json` — `{"colorscheme": "omp-match"}`
- `bindings.json` — `Alt-/` and `Ctrl-_` for comment toggle
- `colorschemes/omp-match.micro` — already uses ANSI color names, no changes needed
- Plugins (filemanager, detectindent, autofmt) — installed via micro plugin manager, not chezmoi

### gh (`~/.config/gh/config.yml`)
- `git_protocol: https`
- `aliases: { co: pr checkout }`
- Static file.

### btop (`~/.config/btop/btop.conf`)
- Uses `adapta` theme currently. Could use terminal colors with `force_tty = False`.
- Key settings: `graph_symbol = "block"`, `rounded_corners = False`
- Personal + work only.

### Ghostty (`~/.config/ghostty/config`)
- **Only file that needs hex color values** — this is the palette source of truth
- Templated per profile with chezmoi
- Background image is personal-only (path is machine-specific)
- Font configuration goes here

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
- `config/oh-my-posh.toml` — replaced by `dot_config/oh-my-posh/config.toml`
- `config/bat/themes/omp-match.tmTheme` — replaced by bat's built-in `ansi` theme
- `ROADMAP.md` — replaced by this document
- `dependencies.txt`, `debug*.txt` — development artifacts
- `terminal-colors.md` — reference only, palette is now in chezmoi data
- `preview-palette.sh` — development tool, not needed in final repo

Do NOT delete these until the chezmoi equivalents are in place and tested.

## Migration Order

Execute in this order. Each step should be independently committable and testable.

### Step 0: Finalize palette and chezmoi data
- Define work palette (blue/white) in the same ANSI slot structure as personal
- Update `.chezmoi.toml.tmpl` with full 16-color palettes per profile
- Add `gitName` and `gitEmail` prompts to `.chezmoi.toml.tmpl`
- Add `editor` and `visual` data per profile

### Step 1: Create dot_zprofile.tmpl
- XDG directory variables (all profiles)
- PATH entries (templated per profile)
- `LANG`/`LC_ALL`
- Ensure XDG dirs exist (`mkdir -p`)

### Step 2: Convert .zshrc → dot_zshrc.tmpl
- Template the OMZ plugin list by profile
- Template the OMP init (skip on server)
- Template the poshcontext precmd wrapping (personal only)
- Fix fzf completion paths (differ between macOS homebrew and Linux)
- Source `api-keys.zsh` if present (not checked in)
- Source `local.zsh` if present (not checked in)
- Remove cargo env line (mise handles runtimes)
- Remove `brew shellenv` (move to `.zprofile` for work profile)
- Test with `chezmoi diff` and `chezmoi apply --dry-run`

### Step 3: Convert config/zsh/ → dot_config/zsh/
- `aliases.zsh.tmpl` — template OS-specific aliases, fix rg hardcoded path, fix bash references
- `functions.zsh.tmpl` — template docker/fzf sections by profile
- `env.zsh.tmpl` — template EDITOR, VISUAL, PAGER, LESS, BROWSER, SYSTEMD_LESS, bat/fzf/python vars
- `poshcontext.zsh` — personal-only via `.chezmoiignore`

### Step 4: Create OMP config → dot_config/oh-my-posh/config.toml
- Use work layout as structural base
- Nerd font icons (from personal)
- New git segment template (✓/~/⇡/⇣, counts only when non-zero)
- Two-tone session segment
- Conditional Spotify rprompt (personal only)
- Static file — uses ANSI color names, no chezmoi templating

### Step 5: Add mise config → dot_config/mise/config.toml.tmpl
- Global tool versions per profile
- Test mise install on both macOS and Linux

### Step 6: Create run_once install scripts
- `run_once_before_install-packages.sh.tmpl` — OS detection, install core CLI tools
- `run_once_before_install-fonts.sh.tmpl` — install nerd fonts (personal + work)
- `run_once_before_install-omz.sh.tmpl` — install Oh My Zsh + community plugins
- `run_once_before_install-omp.sh.tmpl` — install Oh My Posh (skip server)
- `run_once_before_install-mise.sh.tmpl` — install mise + run `mise install`

### Step 7: Convert remaining configs
- `.gitconfig` → `dot_gitconfig.tmpl` (user.name/email from chezmoi data, conventional commit aliases)
- `config/bat/` → `dot_config/bat/config` (static, `ansi` theme)
- Ghostty → `dot_config/ghostty/config.tmpl` (palette per profile)
- micro → `dot_config/micro/` (settings, bindings, colorscheme — all static)
- gh → `dot_config/gh/config.yml` (static)
- btop → `dot_config/btop/btop.conf` (static, personal + work)
- `config/claude/` → `dot_config/claude/` (personal + work only)
- `config/kde/` → personal only via `.chezmoiignore`

### Step 8: Create .chezmoiignore
- Ignore old files (setup.sh, modules/, etc.) so chezmoi doesn't try to deploy them
- Ignore profile-specific files on wrong profiles:
  - KDE, poshcontext.zsh, Spotify rprompt → personal only
  - brew shellenv → work only
  - OMP, mise, docker configs → skip on server
  - Ghostty background image → personal only

### Step 9: Clean up
- Delete old system files (setup.sh, reset.sh, lib/, modules/, profiles/, nix/, migration/, etc.)
- Delete replaced config files (starship.toml, omp-match.tmTheme, etc.)
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
- Use the precmd wrapping approach for poshcontext (personal .zshrc), NOT the sed approach (work .zshrc).
- ANSI color names in tool configs, hex values ONLY in Ghostty config.
- bat uses the built-in `ansi` theme — no custom .tmTheme file needed.
