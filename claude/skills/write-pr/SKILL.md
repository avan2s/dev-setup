---
name: write-pr
description: Write, improve, or extend the title and description of GitHub pull requests (existing PR, current branch's PR, or all PRs of a gh stack), and create a PR or stack when asked. Use when the user explicitly asks to create/open a PR or to write/update/extend a PR description (e.g. "pr anlegen", "pr beschreibung ergänzen", "stack erstellen"); never on mere mentions.
argument-hint: "[pr-number | url | stack] [hint]"
---

# Write PR

Arguments: $ARGUMENTS
A number, `#number` or PR URL targets that PR; `stack` targets all PRs of the current gh stack; otherwise the current branch's PR (created if none exists and the user asked for creation). The rest is a hint.

## Workflow

1. Delegate to the `pr-writer` subagent (one call). It reads PR, diff, and commits, writes title/description, and does all `gh` / `gh stack` work itself; don't run `gh` or read diffs here.
2. Prompt = brief from this session, not finished prose:
   - Mode: update existing / create / create stack (and `draft` only if the user asked); `rewrite` only if the user asked to replace the description, otherwise it extends.
   - Target PR number/URL if given.
   - Intent: use case / problem solved and why.
   - Ticket key or URL, if known (also from branch name).
   - Design decisions, trade-offs, risky areas, how to test.
3. Pushing: creating a PR needs a pushed branch; `gh stack submit` pushes all stack branches. Ask the user for a go before either; pass "user approved push" in the brief only after a yes.
4. Relay PR URL(s), the per-PR change summary, and reported gaps.

## Constraints

- Never invent facts in the brief; leave unknowns out.
- Never push without the user's go.
- Don't restructure the stack (init/add/modify/unstack/sync); the user does that.
