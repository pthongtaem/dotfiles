# 🐧 My Dotfiles

![Terminal](https://img.shields.io/badge/Terminal-WezTerm-orange?style=for-the-badge&logo=wezterm)
![Shell](https://img.shields.io/badge/Shell-Zsh-blue?style=for-the-badge&logo=zsh)
![WM](https://img.shields.io/badge/WM-AeroSpace-lightgrey?style=for-the-badge)
![Theme](https://img.shields.io/badge/Theme-Catppuccin-blue?style=for-the-badge&logo=catppuccin)

Personal configuration files (dotfiles) for macOS, managed with [chezmoi](https://www.chezmoi.io/). Optimized for speed, productivity, and aesthetics.

## ✨ Highlights

- 🚀 **Fast Shell**: Zsh optimized for Apple Silicon with lazy-loading completions.
- 🛠️ **Plugin Management**: Uses [Antidote](https://getantidote.github.io/) for high-performance Zsh plugins.
- 🎨 **Aesthetics**: Consistent [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) and [Tokyo Night](https://github.com/folke/tokyonight.nvim) themes.
- 🗔 **Window Management**: [AeroSpace](https://github.com/nikitabobko/AeroSpace) for i3-like tiling on macOS.
- 🤖 **AI Workflow**: Custom Gemini AI integration for smart commit messages (`gca`).
- 📟 **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/) for a modern, GPU-accelerated experience.

## 🛠️ Tech Stack

| Component | Tool | Description |
| :--- | :--- | :--- |
| **Dotfiles** | `chezmoi` | Secure and flexible dotfile management. |
| **Shell** | `Zsh` | With `Starship` prompt and `zoxide` (smart cd). |
| **Terminal** | `WezTerm` | Configured with MesloLGS Nerd Font. |
| **Multiplexer** | `Tmux` | Tokyo Night theme with TPM plugin manager. |
| **WM** | `AeroSpace` | Tiling window manager for macOS. |
| **Editor** | `Vim` | Default CLI editor. |
| **Package Manager** | `Homebrew` | The missing package manager for macOS. |

## 🚀 Quick Start

### 1. Prerequisites

Ensure you have [Homebrew](https://brew.sh/) installed, then install `chezmoi`:

```bash
brew install chezmoi
```

### 2. Installation

Initialize and apply the dotfiles:

```bash
# Initialize
chezmoi init <your-github-username>

# Apply changes
chezmoi apply
```

### 3. Setup Dependencies

Install the essential tools via Brew:

```bash
brew install starship zoxide fzf eza fnm bat fd antidote figlet lolcat
```

For **Tmux** plugins, press `Ctrl + Space` then `I` inside a tmux session.

## ⌨️ Custom Aliases & Shortcuts

| Alias | Command | Purpose |
| :--- | :--- | :--- |
| `cd` | `z` | Smart navigation with zoxide. |
| `ls` | `eza` | Modern alternative to `ls` with icons. |
| `l` | `eza -la` | Detailed list view. |
| `lt` | `eza --tree` | Directory tree view. |
| `gca` | `gemini ...` | **AI Commit**: Review changes and suggest a commit message. |
| `gst` | `git status` | Quick git status check. |

## 📐 Window Management (AeroSpace)

- `Alt + H/J/K/L`: Focus window.
- `Alt + Shift + H/J/K/L`: Move window.
- `Alt + 1-9`: Switch workspaces.
- `Alt + Tab`: Back and forth between workspaces.

---

*Generated with ❤️ by Gemini CLI*
