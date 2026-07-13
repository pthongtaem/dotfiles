#!/bin/sh
set -eu

zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [ -r "$zinit_home/zinit.zsh" ]; then
    exit 0
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Cannot install Zinit: git is not available" >&2
    exit 1
fi

mkdir -p "$(dirname "$zinit_home")"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$zinit_home"
