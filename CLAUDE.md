# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A chezmoi-managed dotfiles repository for macOS (Apple Silicon). Files prefixed with `dot_` map to `~/.<filename>` when applied. Files under `dot_config/` map to `~/.config/`.

## Applying Changes

```bash
# Apply all dotfiles to the home directory
chezmoi apply

# Preview what would change before applying
chezmoi diff

# Re-add a modified file back into the chezmoi source
chezmoi re-add ~/.zshrc
```

## File Mapping

| Repo file | Target path |
|---|---|
| `dot_zshrc` | `~/.zshrc` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `dot_wezterm.lua` | `~/.wezterm.lua` |
| `dot_config/aerospace/aerospace.toml` | `~/.config/aerospace/aerospace.toml` |
| `dot_config/starship.toml` | `~/.config/starship.toml` |
| `dot_config/ghostty/config` | `~/.config/ghostty/config` |

## Architecture

- **Shell (`dot_zshrc`)**: Zinit with turbo mode (`wait"0" lucid`) defers all plugin loading after prompt. Starship is loaded via Zinit from GitHub releases. Tool inits (zoxide, fnm, fzf, pyenv) are all deferred via `zdharma-continuum/null` shims to avoid blocking startup.
- **Prompt (`dot_config/starship.toml`)**: Catppuccin Mocha palette with a powerline-style segmented layout. Kubernetes context is shown when available.
- **Terminal (`dot_wezterm.lua`, `dot_config/ghostty/config`)**: Both terminals use MesloLGS Nerd Font Mono at 14pt with Catppuccin Mocha. WezTerm is the primary terminal; Ghostty is an alternative.
- **Multiplexer (`dot_tmux.conf`)**: Tokyo Night theme via TPM. Prefix is `Ctrl+Space`. Panes split with `prefix + v` (vertical) and `prefix + h` (horizontal). Nvim-aware pane resizing via `Alt+H/J/K/L`.
- **Window Manager (`dot_config/aerospace/aerospace.toml`)**: AeroSpace auto-assigns apps to workspaces: VS Code → `1`, Browsers → `B`, Terminals → `T`, Chat → `C`, Outlook → `O`.

## Key Aliases (`dot_zshrc`)

- `cd` → `z` (zoxide smart navigation)
- `ls` / `l` / `lt` / `ltree` → eza variants
- `gca` → Gemini AI commit message assistant

## Local Overrides

`~/.zshrc_local` is sourced at the end of `.zshrc` and is not tracked by chezmoi — use it for machine-specific secrets, paths, or overrides.
