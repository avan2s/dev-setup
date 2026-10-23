# Spec conventions

- Reference names via `fn.name` instead of string literals, if supported, so renames don't break specs.
- Unit tests: use the `createUnitTest` helper if available.
- Mocks used in multiple specs (e.g. prisma mock): define them in the mocks section.
- Otherwise use the `getMocks` helper if available.
