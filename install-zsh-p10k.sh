#!/usr/bin/env bash
#
# Installs the zsh environment this repo configures:
#   - zsh, git, curl (via apt on Debian/Ubuntu, via brew on macOS)
#   - oh-my-zsh
#   - the plugins referenced by .zshrc: zsh-autosuggestions, zsh-syntax-highlighting
#   - the powerlevel10k theme + MesloLGS Nerd Font
#   - symlinks ~/.zshrc and ~/.p10k.zsh into this repo
#
# Idempotent: safe to re-run, updates existing clones instead of failing.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

require_packages() {
  local missing=()
  local pkg
  for pkg in zsh git curl; do
    command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done
  [ ${#missing[@]} -eq 0 ] && return 0

  info "Installing: ${missing[*]}"
  case "$(uname -s)" in
    Linux)
      if ! command -v apt-get >/dev/null 2>&1; then
        warn "No apt-get found. Install manually: ${missing[*]}"
        exit 1
      fi
      sudo apt-get update -qq
      sudo apt-get install -y "${missing[@]}"
      ;;
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        warn "Homebrew not found. Install it from https://brew.sh, then re-run."
        exit 1
      fi
      brew install "${missing[@]}"
      ;;
    *)
      warn "Unsupported OS: $(uname -s). Install manually: ${missing[*]}"
      exit 1
      ;;
  esac
}

install_oh_my_zsh() {
  if [ -d "$ZSH_DIR/.git" ]; then
    info "oh-my-zsh present, updating"
    git -C "$ZSH_DIR" pull --ff-only --quiet
    return
  fi
  info "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

clone_or_update() {
  local url="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    info "Updating $(basename "$dest")"
    git -C "$dest" pull --ff-only --quiet
  else
    info "Cloning $(basename "$dest")"
    git clone --depth=1 --quiet "$url" "$dest"
  fi
}

install_nerd_font() {
  local base="https://github.com/romkatv/powerlevel10k-media/raw/master"
  local variants=("Regular" "Bold" "Italic" "Bold%20Italic")

  case "$(uname -s)" in
    Darwin)
      if fc-list 2>/dev/null | grep -q "MesloLGS NF" || \
         ls "$HOME/Library/Fonts"/MesloLGS*NF*.ttf >/dev/null 2>&1; then
        info "MesloLGS Nerd Font already installed"
        return
      fi
      info "Installing MesloLGS Nerd Font"
      local v
      for v in "${variants[@]}"; do
        curl -fsSL "$base/MesloLGS%20NF%20${v}.ttf" \
          -o "$HOME/Library/Fonts/MesloLGS NF ${v//%20/ }.ttf"
      done
      ;;
    Linux)
      local font_dir="$HOME/.local/share/fonts"
      if ls "$font_dir"/MesloLGS*NF*.ttf >/dev/null 2>&1; then
        info "MesloLGS Nerd Font already installed"
        return
      fi
      info "Installing MesloLGS Nerd Font"
      mkdir -p "$font_dir"
      local v
      for v in "${variants[@]}"; do
        curl -fsSL "$base/MesloLGS%20NF%20${v}.ttf" \
          -o "$font_dir/MesloLGS NF ${v//%20/ }.ttf"
      done
      command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$font_dir" >/dev/null
      ;;
  esac
  warn "Set your terminal font to 'MesloLGS NF' for the prompt icons."
}

link_dotfile() {
  local name="$1"
  local src="$REPO_DIR/$name" dest="$HOME/$name"

  if [ ! -e "$src" ]; then
    warn "Missing in repo, skipping: $name"
    return
  fi
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    info "Link already correct: ~/$name"
    return
  fi
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    info "Backing up existing ~/$name to ~/$name.backup"
    mv "$dest" "$dest.backup"
  fi
  info "Linking ~/$name -> $src"
  ln -sfn "$src" "$dest"
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  case "${SHELL:-}" in
    *zsh) return ;;
  esac
  grep -qx "$zsh_path" /etc/shells 2>/dev/null || \
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  info "Setting zsh as the default shell (may ask for your password)"
  chsh -s "$zsh_path" || warn "chsh failed. Run manually: chsh -s $zsh_path"
}

main() {
  require_packages
  install_oh_my_zsh
  clone_or_update https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  clone_or_update https://github.com/romkatv/powerlevel10k \
    "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
  install_nerd_font
  link_dotfile .zshrc
  link_dotfile .p10k.zsh
  set_default_shell
  info "Done. Start a new shell or run: exec zsh"
}

main "$@"
