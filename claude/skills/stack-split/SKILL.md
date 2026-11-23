---
name: stack-split
description: Split an existing branch (local or pushed) or an existing gh stack into logically separated, reviewable milestone PRs and rebuild it as a local gh stack with an identical final code state. Only on explicit user invocation.
disable-model-invocation: true
argument-hint: "[branch | stack | pr-number] [hint]"
---

# Stack Split

Arguments: $ARGUMENTS
Target: a branch (default: current), or the current/named gh stack whose PRs get split further. Rest is a hint.

Goal: make large changes understandable for reviewer and implementer as milestone PRs instead of hundreds of changed files. Only the final state counts: the tip of the new stack must be tree-identical to the original tip.

## Workflow

1. Preflight
   - Require a clean working tree; otherwise stop and ask.
   - Resolve base (stack trunk, else `develop`, else `main`) and original tip `ORIG` (for a stack: top branch).
   - Create safety ref `backup/<branch>-pre-split` at `ORIG`; record `git rev-parse ORIG^{tree}`.
2. Analyze the branch
   - Read commit history (`git log`, per-commit `--stat`) and the full diff `base...ORIG`; use commit messages and branch/ticket names as hints for the functional intent of each change.
   - Existing PR state (`gh pr list`, `gh stack view`, `gh pr view`):
     - gh stack exists: note its PRs/branches and order.
     - PRs stacked on each other (PR base = another PR's head branch) but no gh stack: check whether linking them into a gh stack on GitHub (`gh stack link <pr/branch...>`) is sensible; this keeps the PRs and avoids re-creating them.
     - Neither: plain branch.
   - Base check: if the branch is not based on the default branch (develop/main) but on another branch or PR (PR base, merge-base with other branches), identify that PR or PR chain. Right after the analysis, ask the user whether it should be included in the stack (as lower PRs, untouched or also split) or ignored (then it is the trunk). Don't assume.
3. Identify milestones
   - Group changes by functional or technical cohesion, e.g. rename/move (mechanical, own PR), refactoring/preparation, new abstractions/interfaces, migrations/schema, core logic, API/DTO layer, wiring/config, tests, docs.
   - Commits may be regrouped, reordered, or split by hunk. Moving a piece of logic into another milestone is fine when that makes the milestones more comprehensible; only the end state must match. Keep dependencies valid (a milestone only uses what it or earlier milestones provide).
   - Plan the commit history per milestone too: squash noisy commits (fixups, WIP, back-and-forth) and restructure into a few meaningful commits with clear messages, so the history reads as a traceable story within each PR. The goal is not one commit per PR: several logical commits are fine and wanted; together they form the one milestone of that PR in the stack.
   - Original milestone order may stay or change when better understanding suggests it. A better split is welcome even if it replaces existing PRs or branches.
   - Size guide: ~30 changed files per milestone; soft limit only. Never lose or alter logic to meet it; exceed it instead (e.g. mechanical renames, formatting, import moves as own PR rather than mixed with logic).
   - Each milestone must build and pass tests on its own, so it never blocks later PRs. Avoid temporary shims; if unavoidable, name them in the proposal.
4. Propose, then wait
   - Show the stack as a table, top to bottom, one row per PR, the bottom row being the base (`develop`, or `main` if `develop` doesn't exist). Columns: position, branch name, PR title, short description, file count, rationale for any reorder.
   - Print the table directly in the reply (not in a file), followed by one commit list per PR in the same top-to-bottom order with its planned commit messages (squashed/restructured) and the source commits/files they come from. Example:

     | # | Branch | PR title | Description | Files | Note |
     |---|---|---|---|---|---|
     | 3 | feat-x-3-api | API layer for X | endpoints and DTOs | 12 | |
     | 2 | feat-x-2-core | Core logic for X | service and persistence | 18 | moved before API |
     | 1 | feat-x-1-rename | Rename Y to Z | mechanical rename only | 64 | large, mechanical |
     | – | develop | base | | | |

     PR 3: `add X endpoints` · `add X response DTOs` (from abc123, def456)
   - State the stack situation: existing gh stack will be modified / a new stack will be formed / existing stacked PRs will be linked into a gh stack (no new PRs needed) / existing PRs get replaced by the new split.
   - Flag risks (hunks that must be split, unavoidable large milestones, shims).
   - Ask explicitly whether to proceed; adjust on feedback. Never start building before a yes.
5. Build (after the yes)
   - Work on new local branches off base, bottom to top: `<orig>-1-<slug>`, `<orig>-2-<slug>`, …; never touch `ORIG` or the backup.
   - Per milestone: bring in exactly its changes (`git checkout ORIG -- <paths>` for whole files, `git checkout -p`/`git apply` for partial hunks), commit as planned (one or several meaningful commits with clear messages, no WIP/fixup noise), then verify.
   - Verify each milestone via the `test-runner` subagent (build, lint/type check, tests); fix failures yourself by moving changes between milestones, never by altering semantics.
   - Register locally with `gh stack init <branches bottom to top>` (or `gh stack link` only if that was the approved plan).
6. Verify equivalence
   - `git diff ORIG <new-top-branch>` must be empty and tree hashes equal. If not, find and fix the diff; never finish with a mismatch.
   - Run the full test-runner suite on the top branch.
7. Hand over
   - Report: stack layout, per-PR file counts, verification results, backup ref and how to restore.
   - Tell the user the commands to continue, adapted to the situation:
     - inspect: `gh stack view`, `gh stack checkout <branch|pr|stack-nr>`
     - upload: `gh stack submit` (creates/updates PRs; first push of rewritten branches may need a force-push, accepted on feature branches), `gh stack push` for branches only
     - existing remote stack/PRs that are replaced: `gh stack unstack` first if needed
   - Offer `write-pr stack` for titles/descriptions afterwards.

## Constraints

- Final tree must equal `ORIG`; no refactors, fixes, or cleanups beyond redistribution of existing changes.
- No new comments, files, or code that wasn't in `ORIG`, except named temporary shims the user approved.
- Never push, submit, force-push, or unstack; the user does that. Only create local branches, commits, and local stack tracking.
- Don't spawn subagents except `test-runner`.
- Never delete the backup ref.
