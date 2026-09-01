# code-navigation

Use the `LSP` tool (not grep) for

- Finding references to symbols (findReferences)
- Go-to-definition, go-to-implementation
- Call hierarchy (incomingCalls / outgoingCalls)
- Rename/hover/diagnostics
- Locating a symbol by name across the repo (workspaceSymbol)

# specs

in specs use fn.name if supported instead in case of rename

# database migration liquibase

prefer sqlFile with databaseType property isntead of plain <sql>..</sql>

# code quality

- follow SOLID-principles if it makes sense

Grep is for text search only.

# no comments if possible

- code reads by itself, comments only when absolutely needed
- if you comment functions or methods use multiline comments (esopecially in tsdocs)
