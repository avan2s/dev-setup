# Database changes

Apply only when the change touches Liquibase changelogs, changesets, or SQL files. Used by implementation-refinement and pr-review.

- Keep changelogs database-agnostic: prefer Liquibase's own XML change tags (`createTable`, `addColumn`, `createIndex`, …) wherever they express the change.
- Where raw SQL is unavoidable, never use inline `<sql>…</sql>`; use `<sqlFile>` with a `databaseType` property (`${databaseType}`) selecting the database-specific file under the scripts folder instead.
- No database-specific syntax in changelog XML (vendor functions, types, or `dbms`-bound inline SQL) where a Liquibase tag or a per-database `sqlFile` would avoid it.
- Each `sqlFile` path exists in the PR and matches the database type used by the changeset.
- New changesets are appended at the end of the changelog, with unique ids and the right context.
- Changesets already in the default branch (`develop`/`main`) are released: never edit them (checksum break), add a new changeset instead. Changesets not yet in the default branch (own branch or unmerged part of a stack) may still be edited.
