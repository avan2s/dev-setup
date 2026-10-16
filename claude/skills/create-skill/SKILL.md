---
name: create-skill
description: Create or update a Claude skill with a minimal, high-signal SKILL.md. Use when asked to create, write, edit, condense, or optimize a skill.
---

# Create Skill

Token efficiency is a design constraint: maximize signal per token without dropping required behavior.

## Workflow

1. Define purpose, trigger, inputs, outputs, and boundaries.
   - Unless already stated, ask: may Claude invoke the skill on its own, or only the user via `/<name>`? Explicit-only → `disable-model-invocation: true`.
2. Check existing skills (`~/.claude/skills/`, `.claude/skills/`, plugins) for overlap; reuse or extend instead of duplicating.
3. Write the smallest complete instruction set covering purpose, trigger, workflow, constraints, and completion criteria.
4. Review each line: keep only if it changes behavior, clarifies a constraint, or prevents a realistic failure.
5. Check for ambiguity, missing requirements, duplication, and needless complexity.
6. Verify the skill is actionable and its `description` reliably triggers for intended tasks.

## Rules

- Use concise imperative bullets; no prose where bullets suffice.
- Use a precise kebab-case `name` and a concise `description` stating what it does and when to use it.
- Never remove a requirement just to save tokens.
- Don't restate instructions covered by referenced skills or CLAUDE.md.
- Add sections, examples, or supporting files only for a concrete need; prefer a single SKILL.md.
- Keep the skill self-contained unless referencing another skill clearly helps.
- Ask only when missing information materially blocks a good result; otherwise use sensible defaults.

## skill-creator

- Use `skill-creator` only for evals, benchmarking, or debugging unreliable triggering — not for simple skills.
- Apply these rules to its output.

## Done when

- Skill exists at the correct path with valid frontmatter.
- Reply briefly: skill path and important trade-offs.
