---
name: decomplexify
description: Analyze an existing function, class, module, or component and remove unnecessary complexity (API, types, implementation, concepts) while preserving required behavior. Understands purpose and real usage first.
disable-model-invocation: true
argument-hint: "<target: function, class, module, or file>"
---

# Decomplexify

Target: $ARGUMENTS

Understand first. Simplify second. Preserve required behavior throughout.
Goal: less implementation, API, and conceptual complexity and cognitive load, not fewest lines or parameters at any cost.
Subagents: allowed for small, narrowly scoped tasks (specific question or simplification, limited files) when only the result matters and it keeps the main context lean; keep them token-cheap.

## 1. Understand

- Establish purpose, responsibility, business rules, inputs/outputs, side effects, state, dependencies, invariants, error handling, and edge cases.
- Separate intended behavior from accidental complexity; the current code is neither proof of correctness nor of intent.
- Resolve ambiguity from surrounding code, tests, types, and history before assuming.

## 2. Analyze usage

- Inspect real call sites (via LSP references), tests, and types: actual argument values and combinations, options used, which caller needs which behavior.
- Look for options never varied or always correlated, information callers pass that the target could derive, leaked implementation details, and the same logic configured or implemented repeatedly elsewhere.
- If callers are unavailable, state the limits of the analysis; never claim all use cases are preserved when they weren't established.

## 3. Find unnecessary complexity

- **Interface:** redundant or derivable parameters, repeated parameter combinations, flags, overloads, options, missing defaults, exposed internals.
- **Types/data model:** overly broad or convoluted types, needless generics/wrappers/nesting, mutually exclusive states as discriminated unions, duplicated sources of truth, stored values that can be derived; keep useful type safety.
- **Implementation:** convoluted control flow, duplication, redundant state/calculations/conversions/transformations, overcomplicated algorithms (keep relevant performance), pointless abstraction/indirection/layers, entangled responsibilities (or needlessly split ones).
- **Concept:** things a reader must hold in mind that the domain doesn't require; dead code, speculative generality.
- Complexity may live in the surrounding design (callers, boundaries), not only in the target; simplify there if that is where it pays off.

## 4. Simplify

- Apply only simplifications that preserve required behavior; propose rather than apply when behavior or a public API contract would change, and say who is affected.
- Prefer the simplest change with the biggest cognitive-load reduction; skip subjective or marginal ones.
- Update callers, types, and specs affected by the change; run relevant specs.
- Ask for confirmation before every single commit; a previous approval never covers later commits.

## Done when

- Required behavior is preserved and verified (specs, types, call sites).
- Report briefly: what was simplified and why, what was deliberately left, and open risks or analysis limits.
