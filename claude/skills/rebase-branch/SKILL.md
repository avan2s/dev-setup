---
name: rebase-branch
description: Rebase a branch (current, given branch, or PR) onto its freshly updated target branch, resolving conflicts so both sides' changes are kept. Never pushes.
disable-model-invocation: true
argument-hint: "[pr-number | branch]"
---

# Rebase Branch

Arguments: $ARGUMENTS
A number (or `#number`, PR URL) is a PR, other text is a branch; default is the current branch.

## Workflow

1. Stop if the working tree is dirty or a rebase is already in progress.
2. Resolve the branch: PR via `gh pr checkout <number>`, branch via `git checkout <branch>`.
3. Target = the PR's base (`gh pr view --json baseRefName`). If none can be determined, ask which branch to use, suggesting `develop` or `main` (whichever exists on origin).
4. Stack check: if `gh extension list` contains `gh-stack`, run `gh stack view --json`; if the branch isn't tracked locally, try `gh stack checkout <branch>` to discover a remote stack. If the extension is missing, skip and note it in the plan.
5. Run `git fetch origin`; stop if the local branch is behind `origin/<branch>` (pushing later would drop remote commits).
6. Always show this plan and wait for confirmation before rebasing:
   - Rebase: `<branch>` (N commits) onto updated `<target>` (source: PR #n / user)
   - Stack: whole stack will be rebased (list branches) / none / "gh stack not installed, not checked"
   - Push afterwards: `gpf` or `gh stack push`
7. Run `git fetch origin <target>:<target>` (stop if it's not a fast-forward). Single branch: note its `HEAD` SHA, then run `git rebase <target>`. Stack: first back up every stack branch locally (`git branch backup/<branch>-<YYYYMMDD-HHMM> <branch>`), then run `gh stack rebase`.
8. For each conflict:
   - Understand the target's change and the branch commit; merge so both survive, never blindly take one side.
   - If the intent is unclear, stop and ask.
   - `git add` the files, then `GIT_EDITOR=true git rebase --continue` (stack: `gh stack rebase --continue`).
9. Only if the branch (or stack) introduces Liquibase changesets and the target added a changelog file for a newer version: move those changesets into it (content unchanged, includes updated); ask if the right file is unclear.
10. After the rebase, run typecheck/lint and the specs touching conflicted files; fix rebase-caused failures.

## Rules

- Never push or force-push; the user pushes.

## Done when

- The rebase is complete and checks pass.
- Report: target branch, conflicted files with how each was resolved, moved changesets, check results, pre-rebase SHA or backup branch names for recovery, and the exact push command to run: `gpf` or `gh stack push`.
