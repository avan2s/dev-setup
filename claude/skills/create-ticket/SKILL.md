---
name: create-ticket
description: Create one or more Jira tickets (Bug or Story) from a description, error, or conversation context. Only on explicit user request.
disable-model-invocation: true
argument-hint: "[description | error | context]"
---

# Create Ticket

Arguments: $ARGUMENTS

## Workflow

1. Arguments are optional. Without them, derive the issue(s) from the session context. With them, use them as the primary issue and enrich from context. One ticket each per distinct issue.
2. Delegate to the `ticket-creator` subagent (one call, all tickets). It checks the Jira plugin and does all Jira API work itself; don't touch Jira tools here. Pass the project key only if known from context (e.g. branch name, earlier tickets).
3. Prompt = fact brief, not finished prose, per ticket:
   - Type hint (defect → Bug, else Story), project key.
   - Facts: use case or observed behavior, concrete repro inputs/steps, expected vs. actual, error text/stack trace verbatim.
   - Findings from this session: suspected cause, affected class/area, edge cases.
   - Tickets are always German; the brief may be in any language.
4. Don't write the tickets yourself unless the user asks, or the ticket needs a long analysis too nuanced for a brief; then pass the finished text and let the subagent only create it.
5. Relay the subagent's lines (`KEY – Title – URL`) and any reported gaps. If the subagent reports a missing plugin or project key, tell the user / ask for the key and re-delegate.
6. If the context suggests a further, separate issue not covered by the created tickets, name it in one line as a recommendation; don't create it without the user's go.

## Constraints

- Never invent facts in the brief; leave unknowns out.
