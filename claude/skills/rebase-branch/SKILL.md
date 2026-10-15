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
4. Run `git fetch origin`; stop if the local branch is behind `origin/<branch>` (pushing later would drop remote commits).
5. Always show this plan and wait for confirmation before rebasing:
   - Branch: `<branch>` (N commits)
   - Target: `<target>` (source: PR #n / user)
   - Action: update `<target>` from origin, rebase `<branch>` onto it
6. Run `git fetch origin <target>:<target>` (stop if it's not a fast-forward), note the current `HEAD` SHA, then run `git rebase <target>`.
7. For each conflict:
   - Understand both sides: the target's change (`git log -p <target>` for the file) and the branch commit being applied.
   - Merge so the target's updates and the branch's intent both survive; never blindly take one side.
   - If the intent is unclear, stop and ask.
   - `git add` the files, then `GIT_EDITOR=true git rebase --continue`.
8. After the rebase, run typecheck/lint and the specs touching conflicted files; fix rebase-caused failures.

## Rules

- Never push or force-push; the user runs `gpf`.
- Use plain git commands; aliases aren't available.

## Done when

- The rebase is complete and checks pass.
- Report: target branch, conflicted files with how each was resolved, check results, pre-rebase SHA for recovery, and that it's ready for `gpf`.
