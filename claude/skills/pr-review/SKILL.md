---
name: pr-review
description: Review a PR (given number or the current branch's) via gh for design quality, DRY, unused or obsolete code, and optional acceptance criteria, then draft a short PR comment and post it only after confirmation.
disable-model-invocation: true
argument-hint: "[pr-number] [acceptance criteria]"
---

# PR Review

Arguments: $ARGUMENTS
A leading number (or `#number`, PR URL) is the PR; the rest are optional acceptance criteria. Without a number, use the current branch's PR.

## Workflow

1. Run `gh auth status`; if `gh` is missing or not logged in, stop and tell the user.
2. Run `gh pr view [number] --json number,title,body,baseRefName,headRefName,url`; if no PR is found, stop and tell the user.
3. Read the diff via `gh pr diff [number]`. For surrounding code, if the PR head isn't checked out, read it via `git fetch origin pull/<number>/head` and `git show FETCH_HEAD:<path>`, not the working tree.
4. Review the diff using the "Refine" and "Check the whole change" criteria from `~/.claude/skills/implementation-refinement/SKILL.md`; focus on code introduced by the PR (duplication, unused or dead code, needless complexity).
5. If acceptance criteria are given, mark each as met, partly met, or not met, with a brief reason.
6. Check that specs cover new or changed behavior and acceptance criteria; name missing cases. Check specs against `~/.claude/skills/implementation-refinement/references/specs.md`.
7. If the diff touches Liquibase changelogs/changesets or SQL files, read `~/.claude/skills/implementation-refinement/references/database.md` and apply it.
8. Flag clear bugs you notice, without doing a full bug hunt.

## Rules

- Don't modify code.
- Report only material findings; skip style preferences.

## Output

- A short, clear PR comment in the PR's language: one-line verdict, findings as bullets with `file:line`, and acceptance criteria status if given.
- Show the draft and ask whether to post it; on confirmation run `gh pr comment <number> --body-file <file>`.
