# code-navigation

use lsp-tool (not grep) for

- Finding references to symbols
- Go-to-definition
- Detecting type errors
- Rename/hover/diagnostics

# specs

in specs use fn.name if supported instead in case of rename

# database migration liquibase

prefer sqlFile with databaseType property isntead of plain <sql>..</sql>

# code quality

- follow SOLID-principles if it makes sense

Grep is for text search only.

# no comments if possible

- code reads by itself, comments only when absolutely needed
- if you comment functions method use multiline comments
