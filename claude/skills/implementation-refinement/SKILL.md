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
- **Simplicity:** apply KISS, DRY, YAGNI pragmatically (DRY by default, but a different reason to change (SRP) may justify duplication in its own component); remove dead code, pointless indirection, redundant abstractions, and code without a present purpose.
- **Regexes:** well-named UPPER_CASE constants; short comment above only if complex.
- **Clean Code:** max. 2 parameters per function/method; group more into a named type (a local, non-exported type is fine if it improves readability).
- **Extraction:** before extracting into a new class/service, assess its actual reusability: is there a second concrete consumer now, and if not, how likely is it that another one would realistically benefit (or is the code specific to one caller, e.g. one selective query, a helper for a single method)? Without existing or likely reuse, keep it a private method or local function, unless the responsibility is clearly distinct and it reads better extracted. Inline needless extractions.
- **Existing utilities:** before keeping hand-written helpers (esp. string/array/object utilities), check whether an already installed dependency (e.g. es-toolkit for TypeScript) or one of our own libraries offers it; use it if it makes the code shorter and clearer. Don't add new dependencies for this.
- **SOLID:** fix SRP/OCP/LSP/ISP/DIP violations only where it improves the actual design; SRP never justifies splitting out code that has no reuse and hurts readability.
- **Composition:** favor composition over inheritance where it is practical and keeps the code readable.
- **Architecture:** check responsibilities, dependencies, boundaries, and consistency with surrounding code.
- **Scope:** stay within the focus; no speculative future-proofing.
- Apply justified improvements directly; don't refactor for stylistic preference or theoretical purity.
- Ask for confirmation before every single commit; a previous approval never covers later commits.

## Check the whole change

- The original requirement is fully addressed end to end.
- Names, responsibilities, abstractions, and design decisions are consistent across the change.
- No obsolete, duplicated, or speculative code remains, and refinement introduced no new inconsistencies.
- Fix concrete issues and re-check affected parts; stop when further changes would be subjective or immaterial.

## Done when

- Behavior is unchanged; relevant specs pass and match refactorings.
- Report only remaining material concerns, or state briefly that refinement is complete.
