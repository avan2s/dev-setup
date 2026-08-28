#!/bin/bash
# Claude Code status line: cwd | git branch(dirty) | model | context usage %

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"
dir="${cwd/#$HOME/\~}"

model=$(echo "$input" | jq -r '.model.display_name // empty')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      git_segment="${branch}*"
    else
      git_segment="$branch"
    fi
  fi
fi

output="$dir"
[ -n "$git_segment" ] && output="$output | $git_segment"
[ -n "$model" ] && output="$output | $model"
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  output="$output | $(printf '%.0f' "$used_pct")% ctx"
fi

printf '%s\n' "$output"
