---
name: customer-partner-domains
description: Fill the domain and participant_to_domain tables for a customer's real partners with a multi-upsert Liquibase migration, deriving domains only from the partners' real mails (verified with the npm tmp-mails script) and from answers the user researches, as done for Fricke in CIS4-EDI2. Use when a customer needs its partners' domains seeded.
disable-model-invocation: true
argument-hint: "<customer>"
---

# Customer Partner Domains

Arguments: $ARGUMENTS (customer name; also the Liquibase context)

Repeat the Fricke migration for another customer. Work iteratively: domains from mails, test, commit, then hand the rest to the user for research. No Impressum or web search of your own. Ask only for real decisions (group domains, shared domains, conflicts).

## Reference

Read first, then mirror: commit "assign the fricke partner domains" on `chore/EDI2-4003-fill-participant-domains`:

- `liquibase/setup/fricke/20261015_fricke_assign_partner_domains.xml`
- `liquibase/scripts/postgres/EDI2-3951-fricke-assign-partner-domains.sql` and `...-intercompany-partner-domains.sql`
- include in the release changelog with `context="fricke"`

Create `liquibase/setup/<customer>/` XML with two changesets (`context="<customer>"`, `sqlFile` with `${databaseType}`, `splitStatements="false"`): real partners (`tenant_id IS NULL`), then intercompany partners (`tenant_id IS NOT NULL AND is_intercompany_partner = TRUE`), each with its own SQL file. Leave out the intercompany changeset when the customer has no intercompany partners (an empty `VALUES` list is invalid).

## SQL rules

- `VALUES (partner_name, domain_name)` list, sorted by partner then domain; resolve participants by NAME, never by id.
- Insert `domain` with `ON CONFLICT (name) DO NOTHING`, then `participant_to_domain` with `ON CONFLICT (participant_id, domain_id) DO NOTHING`; `created_by = 'SYSTEM'`.
- Inner join on the participant: missing partners are skipped, never an error; nothing is overwritten or deleted. Must be idempotent and safe per environment (qa and pro may differ).
- A domain may belong to several partners (groups, sister companies).

## Gathering domains (priority order)

1. Real mails: per partner the last 2 mails via `extracted_documents_summary.partner_participant_id` -> `inbound_mail` -> `document_file` (`mail_file_id`); blob name = `md5_checksum` without dashes + `_` + `filename`. Prefer summaries whose `user_task` status is COMPLETED, then newest. Also select the mail's `extracted_documents_summary.user_task_id`s (`string_agg(DISTINCT ...)`; a mail may have several).
   - Create gitignored `backend/test/resources/tmp-mails-blob.env` (`AZURE_STORAGE_CONNECTION_STRING`, `AZURE_STORAGE_CONTAINER`) and let the user fill it.
   - Back up and empty `backend/test/resources/tmp-mails/`; download read-only (`downloadToFile` only; production blob, never write or delete) as `<PARTNERNAME>__<blobname>`.
   - Run `npm run test:tmp-mails:domains` in `backend` (redirect to a file) and read each partner's `stored` domains. Ignore the customer's own and system sender domains, social media, Adobe, tracking and mail-provider domains.
   - Assign a domain to the partner by its label, falling back to the name: accept it when it fits; when the mail's real sender (also inside forwarded mails) belongs to another partner or company, it is a conflict, not an assignment.
2. Everything else goes to the user: no Impressum, WebSearch or agent research. Show the table of participants without a domain (see Reporting) so the user can research them, and work in their answers: only domains matching name or label.

## Acceptance rules

- Never guess. Nothing proven: leave empty.
- Domain name must fit the partner name or label. Skip domains that sound like another company, generic names, product names, tracking-link domains, mail providers.
- Group domains only with proof (mail or known group membership), else skip.
- Skip country copies with empty labels (`XYZ_AT`, `XYZ_DE`); they cannot be researched separately.
- Verify every domain the user brings back with DNS (`dig +short A`, `MX`, `NS` against 1.1.1.1 and 8.8.8.8); drop domains with no records (about 37 of 140 Google answers were invented).
- Include shared domains for sister partners; check near-duplicates (same brand, other TLD) and domains seen in mails of unrelated partners, and leave those out unless the user decides otherwise.

## Test

Use `test-environment/compose.yaml`, never a deleted or foreign DB:

- Create a scratch DB in `db-test`, run `lb-test` with `-e LB_DB_URL=jdbc:postgresql://db-test:5432/<scratch> -e LB_CONTEXTS=<customer>,pro`, or, when the dev DB holds the customer dump, clone it (`CREATE DATABASE <scratch> TEMPLATE cis4_edi2`) and run `lb` with `LB_DB_URL=jdbc:postgresql://db:5432/<scratch>` so the dev DB stays untouched.
- There is no local `psql`; use `docker exec -i <db container> psql`.
- Check: every changeset EXECUTED, no error with missing partners, second run changes nothing, DB pair count equals SQL pair count, no orphan domains. Drop the scratch DB afterwards.
- In ad-hoc test transactions always end with `ROLLBACK` and verify the row count afterwards.

## Reporting

As soon as the emls are analysed and the SQL holds the certain pairs (unsure ones stay out), give the user:

1. Unsure or conflicting partners (#, partner, label, domain(s), why unsure, eml) to decide by number.
   - Whenever an eml shows a strange or not clearly assignable domain (deviates too much from the participant name or label, other company as sender, platform/EDI sender), name the eml file followed by its task ids when the DB has them (`<PARTNERNAME>__<blobname> (Task 123, 124)`) in that row, in this table and in the table below, so the user can open it. Keep the downloaded emls in `tmp-mails/` and the selected mails (partner, mail date, blob name, task ids) in the scratchpad until cleanup, so the user can open them while evaluating.
2. One numbered table of every participant without a domain, one row per partner, never grouped: `# | Partner | Label | AI | Grund | eml` (eml with task ids only for strange or unassignable domains, else `–`). AI-marked (`is_trained_for_document_ai`) first, then the rest; the reason is short (e.g. "Mails kommen von schubert-tacke.de (Entscheidung #3)", "Keine Mails", "Keine Mails, kein Label", "Technischer Kanal", "Mails nur über EDI/Plattform").
3. Omitted domains with reason.

Ask the user to send researched domains by number. Work in their answers under the same rules.

## Cleanup and commit

- Commit the Liquibase files as soon as a test run passed; amend while the user still brings answers.
- Clean up only at the very end and only after the user confirms (ask: "Evaluierung fertig, darf ich aufräumen?"); never while the user is still evaluating. Then delete downloaded emls, restore the original test emls, blank the env file, empty the scratchpad.
- Commit only the Liquibase files; never emls, the env file or `compose.yaml`.

## Done when

The migration ran on a test DB without errors, tables are delivered, the Liquibase files are committed, and, after the user's confirmation, emlfiles and data used from evaluation (tmo-mails) are removed.
