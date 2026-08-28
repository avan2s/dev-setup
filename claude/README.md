# claude code

Run `../install-claude.sh` on a fresh machine. It installs the language
servers and symlinks the configs here into `~/.claude/`.

Plugins are not installed by the script — `settings.json` declares the
marketplace (`extraKnownMarketplaces`) and which plugins to enable
(`enabledPlugins`), and Claude Code installs them on next start.

Not versioned (machine state): `plugins/cache`, `projects`, `sessions`,
`history.jsonl`, `telemetry`.
