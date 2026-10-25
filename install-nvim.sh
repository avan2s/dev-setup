#!/usr/bin/env bash
#
# Installs the Neovim environment this repo configures:
#   - neovim and git via Homebrew
#   - symlinks ~/.config/nvim to nvim/ in this repo (backing up an existing dir)
#   - bootstraps lazy.nvim and restores the plugins pinned in nvim/lazy-lock.json
#
# lazy.nvim itself is cloned by the bootstrap block at the top of nvim/init.lua.
#
# Idempotent: safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_SRC="$REPO_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

require_brew() {
  command -v brew >/dev/null 2>&1 && return 0
  warn "Homebrew not found. Install it from https://brew.sh, then re-run."
  exit 1
}

brew_install() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    info "Already installed: $formula"
    return
  fi
  info "Installing $formula"
  brew install "$formula"
}

link_config() {
  mkdir -p "$(dirname "$NVIM_DEST")"

  if [ -L "$NVIM_DEST" ] && [ "$(readlink "$NVIM_DEST")" = "$NVIM_SRC" ]; then
    info "Link already correct: ~/.config/nvim"
    return
  fi
  if [ -e "$NVIM_DEST" ] && [ ! -L "$NVIM_DEST" ]; then
    info "Backing up existing ~/.config/nvim to ~/.config/nvim.backup"
    rm -rf "$NVIM_DEST.backup"
    mv "$NVIM_DEST" "$NVIM_DEST.backup"
  fi
  info "Linking ~/.config/nvim -> $NVIM_SRC"
  ln -sfn "$NVIM_SRC" "$NVIM_DEST"
}

install_plugins() {
  info "Bootstrapping lazy.nvim and restoring pinned plugins"
  nvim --headless "+Lazy! restore" +qa
}

require_brew
brew_install git
brew_install neovim
link_config
install_plugins

info "Done. Start nvim and run :Lazy to inspect plugins."
