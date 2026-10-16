---
name: intentional-implementation
description: Implement a requested code change with clear intent, minimal complexity, and consistency with the existing architecture. Use when implementing features, fixes, or other code changes.
---

# Intentional Implementation

- Understand the requirement and inspect relevant existing code before changing anything.
- Use expressive, domain-appropriate names.
- Follow existing conventions and architecture unless there is a concrete reason not to.
- Keep responsibilities clear and code easy to understand.
- KISS/YAGNI: build only what is needed now; no speculative features, abstractions, or generalization.
- Reuse existing functionality; avoid duplication without adding needless indirection.
- Keep the change focused; don't modify unrelated code.
- Add or update specs for changed behavior; run them.
- Ask for confirmation before every single commit; a previous approval never covers later commits.

## Done when

- The complete requirement is implemented, not just the obvious part, and the intended behavior works end to end.
