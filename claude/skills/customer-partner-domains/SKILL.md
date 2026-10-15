---
name: customer-partner-domains
description: Fill the domain and participant_to_domain tables for a customer's real partners with a multi-upsert Liquibase migration, deriving domains from real mails, Impressum research and external answers, as done for Fricke in CIS4-EDI2. Use when a customer needs its partners' domains seeded.
disable-model-invocation: true
argument-hint: "<customer>"
---

# Customer Partner Domains

Arguments: $ARGUMENTS (customer name; also the Liquibase context)

Repeat the Fricke migration for another customer. Work iteratively: skeleton with proven domains, research, verification, test. Ask only for real decisions (group domains, shared domains).

## Reference

Read first, then mirror: commit "assign the fricke partner domains" on `chore/EDI2-4003-fill-participant-domains`:
- `liquibase/setup/fricke/20261015_fricke_assign_partner_domains.xml`
- `liquibase/scripts/postgres/EDI2-3951-fricke-assign-partner-domains.sql` and `...-intercompany-partner-domains.sql`
- include in the release changelog with `context="fricke"`

Create `liquibase/setup/<customer>/` XML with two changesets (`context="<customer>"`, `sqlFile` with `${databaseType}`, `splitStatements="false"`): real partners (`tenant_id IS NULL`), then intercompany partners (`tenant_id IS NOT NULL AND is_intercompany_partner = TRUE`), each with its own SQL file.

## SQL rules

- `VALUES (partner_name, domain_name)` list, sorted by partner then domain; resolve participants by NAME, never by id.
- Insert `domain` with `ON CONFLICT (name) DO NOTHING`, then `participant_to_domain` with `ON CONFLICT (participant_id, domain_id) DO NOTHING`; `created_by = 'SYSTEM'`.
- Inner join on the participant: missing partners are skipped, never an error; nothing is overwritten or deleted. Must be idempotent and safe per environment (qa and pro may differ).
- A domain may belong to several partners (groups, sister companies).

## Gathering domains (priority order)

1. Real mails: per partner the last 2 mails via `extracted_documents_summary.partner_participant_id` -> `inbound_mail` -> `document_file` (`mail_file_id`); blob name = `md5_checksum` without dashes + `_` + `filename`. Prefer summaries whose `user_task` status is COMPLETED, then newest.
   - Create gitignored `backend/test/resources/tmp-mails-blob.env` (`AZURE_STORAGE_CONNECTION_STRING`, `AZURE_STORAGE_CONTAINER`) and let the user fill it.
   - Back up and empty `backend/test/resources/tmp-mails/`; download read-only (`downloadToFile` only; production blob, never write or delete) as `<PARTNERNAME>__<blobname>`.
   - Run `npm run test:tmp-mails:domains` in `backend` (redirect to a file) and read each partner's `stored` domains. Ignore the customer's own and system sender domains, social media, Adobe, tracking and mail-provider domains.
2. Impressum/contact page of the company itself (agents sequentially, max 2 searches per partner; the session has a WebSearch budget of about 200 calls; no scraping of search engines via curl).
3. External answers (the user's Google): only domains matching name or label.

## Acceptance rules

- Never guess. Nothing proven: leave empty.
- Domain name must fit the partner name or label. Skip domains that sound like another company, generic names, product names, tracking-link domains, mail providers.
- Group domains only with proof (mail or known group membership), else skip.
- Skip country copies with empty labels (`XYZ_AT`, `XYZ_DE`); they cannot be researched separately.
- Verify every external domain with DNS (`dig +short A`, `MX`, `NS` against 1.1.1.1 and 8.8.8.8); drop domains with no records (about 37 of 140 Google answers were invented). Also check by `WebFetch` that the page names the company.
- Include shared domains for sister partners; check near-duplicates (same brand, other TLD) and domains seen in mails of unrelated partners, and leave those out unless the user decides otherwise.

## Test

Use `test-environment/compose.yaml`, never a deleted or foreign DB:
- Create a scratch DB in `db-test`, run `lb-test` with `-e LB_DB_URL=jdbc:postgresql://db-test:5432/<scratch> -e LB_CONTEXTS=<customer>,pro`, or use the dev DB with the customer dump.
- Check: both changesets EXECUTED, no error with missing partners, second run changes nothing, DB pair count equals SQL pair count, no orphan domains. Drop the scratch DB afterwards.
- In ad-hoc test transactions always end with `ROLLBACK` and verify the row count afterwards.

## Reporting

Give the user numbered tables: partners still without domain (#, partner, label, reason), split into AI-marked (`is_trained_for_document_ai`) and the rest, plus omitted domains with reason. Work in answers the user brings back under the same rules.

## Cleanup and commit

- Delete downloaded emls, restore the original test emls, blank the env file, empty the scratchpad.
- Commit only the Liquibase files; never emls or the env file.

## Done when

The migration ran on a test DB without errors, tables are delivered, production data is removed, and the Liquibase files are committed.
