---
name: create-ticket
description: Create one or more Jira tickets (Bug or Story) from a description, error, or conversation context. Only on explicit user request.
disable-model-invocation: true
argument-hint: "[description | error | context]"
---

# Create Ticket

Arguments: $ARGUMENTS
Don't spawn subagents.

## Preconditions

- Check the Atlassian plugin tools (`mcp__plugin_atlassian_atlassian__*`) are available. If not, stop and tell the user to install/enable the Jira plugin.
- Resolve `cloudId` via `getAccessibleAtlassianResources` once. Ask for the project key only if not given or derivable from context.

## Workflow

1. Derive tickets from arguments/context. One ticket per distinct issue; split if the input contains several.
2. Choose type: defect/error/wrong behavior → `Bug`; everything else → `Story`.
3. Draft per rules below. Language: match the user's input language (default German); keep technical terms and code as-is.
4. Create via `createJiraIssue` with labels `tbd` and `ai-generated`.
5. Reply with one line per ticket: `KEY – Title – <browse URL>`. Nothing else.

## Writing rules (all tickets)

- Title: precise, names the concrete problem or capability. No generic words ("Fix", "Improve") without object.
- Concise. Focus on the use case, written in business/domain language, not implementation.
- Code, commands, payloads, and log lines go in fenced code blocks, written out completely.
- Mention technical hints in the description only where useful; don't dictate the solution.

## Story

Structure:

- **Als** `<Rolle>` **möchte ich** `<Funktion>`, **damit** `<Nutzen>`.
- **Beschreibung**: context and use case; optional hints.
- **Akzeptanzkriterien**: short bullets of observable outcomes. Leave room for the developer; no micro-specification.

(Use English equivalents if writing in English.)

## Bug

Structure:

- **Beschreibung**: what is wrong, one or two sentences, with business impact.
- **Schritte zur Reproduktion**: numbered, step by step, with concrete inputs/data/environment.
- **Erwartetes Verhalten**
- **Tatsächliches Verhalten**: include error message/stack trace in a code block if available.
- **Hinweise** (optional): suspected cause, affected area.

## Constraints

- Never invent facts (steps, versions, environments); ask or omit if unknown and material.
- Don't assign, set priority, or link epics unless asked.
