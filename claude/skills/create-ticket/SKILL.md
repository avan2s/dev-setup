---
name: create-ticket
description: Create or update Jira tickets (Bug, Story or Task) from a description, error, or conversation context. Only on explicit user request.
disable-model-invocation: true
argument-hint: "[description | error | context]"
---

# Create / Update Ticket

Arguments: $ARGUMENTS

The `ticket-creator` agent owns all writing, field, label and update rules. This skill only collects facts and delegates.

1. Source: arguments (if given) as the primary issue, enriched from session context; otherwise session context. One ticket per distinct issue.
2. Delegate all tickets in one `ticket-creator` call; never use Jira tools in the main session.
3. Brief per ticket, raw facts only (no prose, nothing invented, unknowns left out):
   1. Kind hint, project key if known from context (branch, earlier tickets).
   2. What the session knows about the issue; error text verbatim.
   3. Update: existing key + exact change.
4. Write ticket text yourself only if the user asks; then pass it split per field.
5. Relay the agent's result lines and gaps. Missing plugin or project key → tell/ask the user, re-delegate.
6. Further separate issue spotted → recommend in one line, don't create it.
