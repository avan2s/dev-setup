---
name: decomplexify
description: Simplify an existing function, class, module, or component without changing its runtime behavior - remove unnecessary API, type, implementation, and conceptual complexity after understanding its purpose and real usage.
disable-model-invocation: true
argument-hint: "<target: function, class, module, or file>"
---

# Decomplexify

Target: $ARGUMENTS

Goal: less cognitive load with identical runtime behavior, not fewest lines at any cost.
Subagents: per `~/.claude/skills/implementation-refinement/references/agents.md`; read it before spawning. For usage analysis, demand complete `file:line` lists (via LSP) and explicitly flagged uncertainties; verify behavior-critical findings yourself.

## 1. Understand

- Establish purpose, inputs/outputs, side effects, state, invariants, error handling, and edge cases; current code proves neither correctness nor intent.
- Check real usage via call sites, tests, and types: which arguments, options, and combinations are actually used, and by whom.
- Resolve ambiguity from surrounding code, tests, and history before assuming; if callers are unavailable, state the limits and never claim all use cases are preserved.

## 2. Simplify

Pick the smallest change with the biggest readability gain; often extracting or deleting is enough. Skip subjective or marginal changes.

- **Remove (YAGNI):** unused or never-varied parameters, options, flags, functions, dead code, and speculative generality, unless a concrete upcoming use is evident.
- **Interface:** derivable or always-correlated parameters, missing defaults, exposed internals.
- **Types:** needless generics/wrappers, mutually exclusive states as discriminated unions, duplicated or derivable state; keep useful type safety.
- **Structure:** flatten deep nesting (early returns, extracted functions); remove duplication, redundant calculations/conversions, and pointless indirection; split entangled or merge needlessly split responsibilities; prefer composition over inheritance where it simplifies.
- **Naming:** names state intent; rename when it spares reading the implementation.
- Complexity may sit in callers or boundaries; simplify there if it pays off.

## Rules

- Runtime behavior stays identical: same results, side effects, errors, ordering, and relevant performance.
- Propose instead of apply when a public API contract would change; name affected consumers.
- Update affected callers, types, and specs; run relevant specs.
- Never commit on your own; ask every time, a previous approval never covers later commits.

## Done when

- Unchanged behavior is verified (specs, types, call sites).
- Report briefly: what was simplified and why, what was deliberately left, open risks or analysis limits.
