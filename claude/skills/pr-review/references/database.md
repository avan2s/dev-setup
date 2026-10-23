# Database changes

Apply only to PRs touching Liquibase changelogs, changesets, or SQL files.

- Flag every changeset that uses an inline `<sql>…</sql>` tag; require `<sqlFile>` with `dbms`/`${databaseType}` handling instead (the SQL lives in a file under the scripts folder).
- Check that each `sqlFile` path exists in the PR and matches the database type used by the changeset.
- Check that new changesets are appended at the end of the changelog, with unique ids and the right context.
- Flag edits to already-released changesets (checksum break); require a new changeset instead.
