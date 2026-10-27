---
name: opinion
description: Give a senior-developer opinion on a described problem or design decision - evaluate given alternatives and pros/cons, add missing points or an own proposal, estimate effort, and recommend one option. Read-only, no code changes.
disable-model-invocation: true
argument-hint: "<problem, alternatives, known pros/cons>"
---

# Opinion

Problem: $ARGUMENTS

Read-only: never edit files, write code, or run mutating commands. Opinion only.

Subagents: avoid by default; use one only when the investigation is broad enough that it would flood the main context with tokens. Give it a narrowly scoped, small task (specific question, limited files/areas); it only gathers facts, the evaluation stays with you. Max. 2 subagents per run; tasks of ≤3 tool calls do yourself. Subagents only with `model: "sonnet"`, never `fork` (it ignores the model and runs on Opus).

## Investigate

- Inspect the relevant code to ground the opinion in the actual architecture, not assumptions.
- Identify components that already own the responsibility; reuse them (DRY). Propose new components only where no existing one fits.
- Resolve open questions yourself from domain logic and senior-developer judgment. Ask domain questions only when the topic is deep and the answer materially changes the recommendation.
- If DB migrations are involved, read `~/.claude/skills/implementation-refinement/references/database.md` and apply it; check whether the affected changesets are already in the default branch (`develop` or `main`, e.g. `git log <default>..HEAD -- <changelog-path>`); on the own branch or in an unmerged part of a gh stack they are not:
  - Not yet in default branch → changesets may still be edited freely.
  - Already in default branch → assume productive existing data; require new changesets and data migration.

## Evaluate

- Take the user's alternatives and pros/cons as input; add missing pros/cons, risks, and alternatives.
- Own proposal allowed if it beats the given options.
- Criteria, by priority:
  1. Maintainability, readability, and understandability for human developers.
  2. SOLID, especially Open/Closed and SRP; DRY; YAGNI (no speculative abstractions or generalization); composition over inheritance, hierarchies only where truly sensible.
  3. Effort and risk.
- Name required or advisable refactorings with effort (S/M/L) and roughly affected files/areas.

## Output

Per alternative (concise):
- Approach in 1-2 sentences.
- Pros / cons (mark points you added).
- Affected components/files, refactorings, effort, migration impact.

Then:
- **Empfehlung:** the chosen option with a short reason why.

## Done when

- Every alternative is assessed, a clear recommendation is given, and no code was changed.
