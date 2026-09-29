# code-navigation

Use the `LSP` tool (not grep) for

- Finding references to symbols (findReferences)
- Go-to-definition, go-to-implementation
- Call hierarchy (incomingCalls / outgoingCalls)
- Rename/hover/diagnostics
- Locating a symbol by name across the repo (workspaceSymbol)

# specs

- in specs use fn.name if supported instead in case of rename
- for unit test use createUnitTest helper function if available - define mocks in the mocks section in case you have to use oprisma mock or mocks, which you want to access in multiple specs, otherwise you could use also getMocks helper function if available

# database migration liquibase

prefer sqlFile with databaseType property isntead of plain <sql>..</sql>

# code quality

- follow SOLID-principles if it makes sense

Grep is for text search only.

# no comments if possible

- code reads by itself, comments only when absolutely needed for exported functions prefered
- if you comment functions or methods use multiline comments (esopecially in tsdocs)
