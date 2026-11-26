---
name: clean-history
description: Rewrite an existing branch's commit history into a few clean, logical milestone commits with clear messages, each type-check clean, with a tree identical to the original tip. Only on explicit user invocation.
disable-model-invocation: true
argument-hint: "[branch] [hint]"
---

# Clean History

Arguments: $ARGUMENTS
Target: the named branch (default: current). Rest is a hint.

Scope: only the branch's own commits (`merge-base..ORIG`). Never rewrite `main`, `master`, `develop`, `release/*`, the repo default branch, or any commit reachable from the base or another shared branch.

Goal: the branch reads as a traceable story of milestones.

**Hard rule, above everything else:** the new tip must contain exactly the same code as `ORIG`: same tree hash, so every file, deletion and file mode is byte-identical and everything works exactly as before. No exceptions, no "equivalent" changes. If this can't be achieved, abort and leave the branch untouched.

## Workflow

1. Preflight
   - Stop if the working tree is dirty or a rebase/merge is in progress.
   - Stop if the target is a shared branch (see Scope) or has no own commits.
   - Resolve base: PR base (`gh pr view --json baseRefName`), else `develop`, else `main`; use `git merge-base base ORIG`. If unclear, ask.
   - `git fetch origin`; stop if the local branch is behind `origin/<branch>`.
   - If other branches or open PRs build on this branch (`gh pr list --base <branch>`, `git branch --contains`), name them in the proposal: they would need a rebase after the rewrite.
   - Create backup ref `backup/<branch>-pre-clean-<YYYYMMDD-HHMM>` at `ORIG`; record `git rev-parse ORIG^{tree}`.
2. Analyze
   - Read `git log` with per-commit `--stat` and the net diff `merge-base..ORIG`.
   - Use old messages, branch/ticket names as hints for intent; match the repo's message convention (ticket prefix, language, style).
   - Plan from the net diff only: back-and-forth (A→B→A) or reverted experiments vanish; files whose final state equals base don't appear at all.
3. Plan milestones
   - Group by functional or technical cohesion: rename/move (mechanical, own commit), preparation/refactoring, new abstractions, migrations/schema, core logic, API/DTO, wiring/config, tests, docs.
   - Commit count: 5–10 as soft limit, fewer is fine for small branches; never a fine-grained history nobody can follow.
   - Size: ~30 changed files per commit as soft limit; exceed it for mechanical changes (renames, formatting, import moves) instead of mixing them with logic.
   - Splitting old commits by hunk and reordering are fine; dependencies must stay valid (a commit only uses what it or earlier commits provide).
   - Every commit must be type-check clean on its own. Avoid temporary shims; if unavoidable, name them in the proposal.
4. Propose, then wait
   - Print directly in the reply a table of the planned commits, oldest first. Columns: #, commit message, short description, files, source commits. Then list risks (hunks to split, oversized commits, shims) and what was dropped as back-and-forth.
   - Ask explicitly whether to proceed; adjust on feedback until the user says yes. Never rewrite before a yes.
5. Build (after the yes)
   - Create temp branch `<branch>-clean` at the merge-base; never touch the backup ref.
   - Per commit: bring in exactly its changes (`git checkout ORIG -- <paths>` for whole files, deletions via `git rm`, `git checkout -p ORIG`/`git apply` for partial hunks), commit with the approved message, then run the project's type check.
   - On type errors: fix by moving changes between commits, never by changing code semantics. If the plan must change materially, show the updated table and ask again.
6. Verify equivalence
   - `git diff --exit-code ORIG <branch>-clean` must be empty and `git rev-parse ORIG^{tree}` must equal `git rev-parse <branch>-clean^{tree}` and the recorded hash; otherwise find and fix the difference. Never swap with a mismatch.
   - Run the full type check (and the project's tests if they exist) on the final commit.
7. Swap and hand over
   - Point the branch to the new tip (`git checkout <branch> && git reset --hard <branch>-clean`), then re-check `git rev-parse HEAD^{tree}` equals the recorded hash and `git status` is clean; delete the temp branch.
   - Report: final commit table with file counts, verification results, backup ref.
   - Give the user the commands:
     - push: `git push --force-with-lease origin <branch>`
     - restore: `git reset --hard backup/<branch>-pre-clean-…`
     - drop backup when satisfied: `git branch -D backup/<branch>-pre-clean-…`

## Constraints

- Final tree hash must equal `ORIG`'s (see hard rule); no refactors, fixes, cleanups, comments, or files that weren't in `ORIG`, except user-approved shims.
- Never push or force-push; only the user does that.
- Never delete the backup ref.
- Don't spawn subagents except `test-runner`.
