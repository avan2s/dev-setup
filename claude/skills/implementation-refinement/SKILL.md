---
name: implementation-refinement
description: Refine the current change or a given code area for design quality, naming, readability, and unnecessary complexity (not bug hunting), then check the whole change for consistency.
disable-model-invocation: true
argument-hint: "[focus area or intent]"
---

# Implementation Refinement

Focus: $ARGUMENTS
If no focus is given, refine the current change (`git diff`).

Re-evaluate independently; working code or a "finished" verdict from implementation is not evidence of good design.

## Refine

- **Naming:** names express intent and domain meaning, not implementation details.
- **Readability:** code is understandable without unnecessary mental effort.
- **Simplicity:** apply KISS, DRY, YAGNI pragmatically; remove dead code, pointless indirection, redundant abstractions, and code without a present purpose.
- **SOLID:** fix SRP/OCP/LSP/ISP/DIP violations only where it improves the actual design.
- **Architecture:** check responsibilities, dependencies, boundaries, and consistency with surrounding code.
- **Scope:** stay within the focus; no speculative future-proofing.
- Apply justified improvements directly; don't refactor for stylistic preference or theoretical purity.
- Never commit without asking for confirmation first.

## Check the whole change

- The original requirement is fully addressed end to end.
- Names, responsibilities, abstractions, and design decisions are consistent across the change.
- No obsolete, duplicated, or speculative code remains, and refinement introduced no new inconsistencies.
- Fix concrete issues and re-check affected parts; stop when further changes would be subjective or immaterial.

## Done when

- Behavior is unchanged; relevant specs pass and match refactorings.
- Report only remaining material concerns, or state briefly that refinement is complete.
