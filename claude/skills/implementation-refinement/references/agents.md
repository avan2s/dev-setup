# Agent delegation

Central rules for spawning subagents; skills reference this file.

## Rules

- Delegate only if the output is much larger than the needed answer, or tasks run in parallel. ≤3 tool calls: do it yourself.
- Always set `model`; never `fork`.
- Agents return facts (paths, error lines, exit codes), no judgments. Review every result.
- Brief precisely: goal, scope, expected output.
- Parallel only for independent tasks without shared writes; spawn in one message.
- Sonnet agents: max 2 in total per run across all profiles. If the session itself runs on Sonnet, spawn no Sonnet agents; use Haiku only, and only if Haiku can handle the task, otherwise do it yourself.
- Haiku/Sonnet agents never commit, push, or delete.

## Profiles

| Profile | Model | Max parallel | Use for |
|---|---|---|---|
| `search` | haiku | 5 | find files, symbols, usages; return `file:line` list |
| `run` | haiku | 5 | run specs/build/lint; return pass/fail + relevant failure lines |
| `mechanical` | haiku | 3 | fully specified renames/inlines/moves; return changed files |
| `read` | sonnet | 2 | read/summarize code for context; no verdicts |
| `review-pass` | sonnet | 2 | checklist review of one area; return findings with `file:line` |

## Do yourself

- Design, naming, trade-offs, complex code changes, unclear-cause debugging, merging results, final verdict.
