# Dotfiles

A modern, multi-profile dotfiles system managed by [chezmoi](https://www.chezmoi.io/). Designed for seamless setup across macOS (Work), Linux (Personal), and Minimal Linux (Server) environments.

## Quick Start

To initialize and apply these dotfiles on a new machine, run:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply aeriondyseti
```

*Note: You will be prompted to select a profile (`work`, `personal`, or `server`) and provide your Git credentials.*

## Core Architecture

### Profiles

| Profile | Target OS | Theme | Use Case |
|---------|-----------|-------|----------|
| `work` | macOS (darwin/arm64) | Blue/white | Corporate MacBook |
| `personal` | Linux (amd64, WSL/Ubuntu) | Dark Teal + Amber | Personal desktop/laptop |
| `server` | Linux (any arch) | Minimal | Homelab, VPS, Headless |

### Key Components

- **Shell:** Zsh with [Oh My Zsh](https://ohmyz.sh/) and [Oh My Posh](https://ohmyposh.dev/) (ANSI-based themes).
- **Runtimes:** [mise-en-place](https://mise.jdx.dev/) manages Python, Node.js, Bun, Kotlin, and .NET.
- **Terminal:** [Ghostty](https://ghostty.org/) (Source of truth for colors).
- **CLI Tools:** `bat`, `eza`, `fd`, `ripgrep`, `fzf`, `zoxide`, `delta`, `btop`, `lazygit`, `lazydocker`.
- **AI Agents:** Pre-configured settings for `claude` and `gemini` CLI tools.

### Color Strategy: ANSI Palette via Ghostty

**Ghostty is the source of truth for all colors.** To maintain consistency across tools without hardcoding hex values:
1. Hex colors are defined *only* in the Ghostty configuration (`dot_config/ghostty/config.tmpl`).
2. All other tools (Oh My Posh, bat, micro, delta) use standard ANSI color names (0–15).
3. Changing the Ghostty palette instantly updates the theme for every tool.

## Maintenance

### Apply Changes
After modifying templates in your local chezmoi source directory (`~/.local/share/chezmoi`):

```bash
chezmoi apply
```

### Update Dotfiles
To pull the latest changes from GitHub and apply them:

```bash
chezmoi update
```

### Edit Configuration
Use chezmoi's built-in edit command to handle templates correctly:

```bash
chezmoi edit <file>
```

## Acknowledgments
Built with ❤️ by [Kevin Whiteside](https://github.com/aeriondyseti).
