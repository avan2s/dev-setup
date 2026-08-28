#!/usr/bin/env bash
#
# Installs the Claude Code environment this repo configures:
#   - the language servers the enabled LSP plugins spawn from PATH
#   - symlinks ~/.claude/{settings.json,CLAUDE.md,statusline-command.sh} into this repo
#
# The plugins themselves are declared in claude/settings.json
# (extraKnownMarketplaces + enabledPlugins) and install on next start.
#
# Idempotent: safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

require_bun() {
  command -v bun >/dev/null 2>&1 && return 0
  warn "bun not found. Install it from https://bun.sh, then re-run."
  exit 1
}

install_language_servers() {
  # vue-volar requires v2.x; it rejects 3.x, which needs tsserver request forwarding.
  info "Installing language servers"
  bun install -g \
    @vtsls/language-server \
    "@vue/language-server@2" \
    typescript
}

verify_language_servers() {
  local bin
  for bin in vtsls vue-language-server; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      warn "$bin is not on PATH. Add bun's global bin dir (usually ~/.bun/bin)."
      return
    fi
  done
  info "Language servers on PATH: vtsls $(vtsls --version), vue-language-server $(vue-language-server --version)"
}

link_config() {
  local name="$1"
  local src="$REPO_DIR/claude/$name" dest="$CLAUDE_DIR/$name"

  if [ ! -e "$src" ]; then
    warn "Missing in repo, skipping: claude/$name"
    return
  fi
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    info "Link already correct: ~/.claude/$name"
    return
  fi
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    info "Backing up existing ~/.claude/$name to ~/.claude/$name.backup"
    mv "$dest" "$dest.backup"
  fi
  info "Linking ~/.claude/$name -> $src"
  ln -sfn "$src" "$dest"
}

main() {
  require_bun
  install_language_servers
  verify_language_servers
  mkdir -p "$CLAUDE_DIR"
  link_config settings.json
  link_config CLAUDE.md
  link_config statusline-command.sh
  info "Done. Plugins install on the next 'claude' start."
}

main "$@"
