---
name: snowflake-semantic-views
description: Create, alter, validate, audit, debug, and optimize Snowflake semantic views using Snowflake CLI (`snow`), SQL DDL, YAML semantic view specs, Cortex Analyst verified queries, and Snowflake validation procedures. Use when asked to build semantic views, troubleshoot CREATE/ALTER SEMANTIC VIEW or SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML failures, enrich comments/synonyms/metrics/filters/relationships, add or validate AI_VERIFIED_QUERIES, or test semantic views against Snowflake.
---

# Snowflake Semantic Views

## Required Setup

- Verify the Snowflake CLI with `snow --version`.
- Use the configured Snowflake connection for all Snowflake work. If the CLI cannot write to its log path in a sandbox, copy `~/.snowflake/config.toml` to a temp directory outside the repo, redirect `[cli.logs].path` there, and run commands with `SNOWFLAKE_HOME=<temp_dir>`.
- Prefer the user's requested connection. If multiple connections match, choose the one whose account/user matches the request and confirm the role, warehouse, database, and schema with:

```bash
snow sql -q "SELECT CURRENT_ACCOUNT(), CURRENT_USER(), CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA()" --connection <connection_name>
```

- Never commit credentials, downloaded semantic model YAML from customer accounts, local CORTEX skill copies, Snowflake logs, or temporary validation artifacts.

## Choose The Workflow

Use one of these paths based on the user's request:

- **New or replacement semantic view from tables/SQL**: prefer the FastGen-first YAML workflow when the account supports `SYSTEM$CORTEX_ANALYST_FAST_GENERATION`; otherwise use SQL DDL or manually authored YAML. YAML is preferred when the user wants Cortex Analyst compatibility, verified queries, or iterative editing. SQL DDL is fine for compact explicit definitions.
- **Existing semantic view**: retrieve the current definition first, inspect it, then make targeted changes. Use `SYSTEM$READ_YAML_FROM_SEMANTIC_VIEW` when YAML editing is more reliable than rewriting DDL.
- **Debug or audit**: reproduce the failure with a semantic view query or Cortex Analyst/VQR test, identify the smallest semantic-layer gap, patch it, and re-run the same test.
- **VQR, metric, filter, or relationship suggestions**: mine existing user SQL/query history only when available and authorized. Present suggestions for review before deploying.
- **dbt semantic view work**: see `references/dbt-semantic-views.md`.

## Workflow

1. **Set context**: confirm connection, role, warehouse, target database/schema, final semantic view name, and whether changes may be deployed.
2. **Choose creation/editing mode**:
   - For new Cortex Analyst-ready views, read `references/fastgen-workflow.md` and try FastGen first when supported.
   - For explicit SQL requests, use `references/semantic-view-sql.md`.
   - For YAML create/edit/deploy requests, use `references/semantic-view-yaml.md`.
   - For existing semantic views, retrieve current YAML before changing it.
3. **Inspect before changing**: use bounded Snowflake metadata queries and structured YAML inspection when available.
4. **Draft the smallest safe change**: preserve unrelated definitions and prefer explicit semantic elements over broad AI instructions.
5. **Validate before deploy**: use temporary DDL validation or YAML verify-only mode. For VQRs, use `references/vqr-validation.md`.
6. **Deploy only after validation succeeds and the user has allowed deployment**.
7. **Smoke test** with a semantic-view query, then clean up temporary validation objects.

## Stopping Points

Ask before:

- Creating or replacing the final semantic view.
- Mining account query history, Cortex Analyst events, or other user activity.
- Applying suggested comments, synonyms, metrics, filters, relationships, instructions, or VQRs that were inferred rather than provided by the user.
- Dropping any object other than a clearly named temporary validation object created during the same task.

## Output

Return:

- Target connection/context used.
- Files or SQL generated.
- Validation method and exact pass/fail result.
- Deployment status, if deployment was requested.
- Smoke-test query and result summary.
- Cleanup status for temporary objects.

## Core Rules

- Confirm target database, schema, role, warehouse, and final semantic view name before deploying.
- Model a star schema when possible: fact tables with conformed dimensions and explicit relationships.
- Distinguish logical semantic names from physical Snowflake objects. Semantic view YAML and DDL define logical table/column names, while generated SQL can reference physical base tables. Do not treat physical table references as a bug by itself.
- Treat comments, descriptions, and synonyms as required for useful Cortex Analyst behavior. Read existing Snowflake comments first; if they are missing, draft suggestions and ask for approval before inventing business terminology.
- Prefer explicit semantic elements over broad instructions: descriptions/synonyms first, then metrics/filters/relationships, then AI SQL generation instructions only when needed.
- Do not add physical dimensions/facts that are not backed by columns. You can add metrics, filters, relationships, verified queries, and instructions.
- Use `facts`, not deprecated `measures`, for new semantic view work unless maintaining an existing legacy YAML model.
- Keep temporary validation object names clearly scoped, for example `<name>__tmp_validate`, and clean them up.

## SQL DDL Workflow

1. Discover metadata with bounded queries:
   - `DESCRIBE TABLE <db>.<schema>.<table>`
   - `SHOW PRIMARY KEYS IN TABLE <db>.<schema>.<table>`
   - `SELECT ... LIMIT 1000` for relationship and value-shape checks.
2. Draft `CREATE OR REPLACE SEMANTIC VIEW` using official clause order: `TABLES`, `RELATIONSHIPS`, `FACTS`, `DIMENSIONS`, `METRICS`, `COMMENT`, `AI_SQL_GENERATION`, `AI_QUESTION_CATEGORIZATION`, `AI_VERIFIED_QUERIES`, `COPY GRANTS`.
3. Include primary keys or `UNIQUE` constraints on referenced columns. Relationship targets must be declared as a primary or unique key.
4. Include at least a small set of useful metrics for fact tables unless the user explicitly asks for dimensions/facts only.
5. Validate with a temporary view name first via `snow sql`.
6. If validation succeeds, apply the final DDL to the requested name.
7. Run at least one semantic-view query against the final object.
8. Drop any temporary validation semantic view.

See `references/semantic-view-sql.md` for syntax reminders and sample queries.

## YAML Workflow

Use YAML when creating or editing semantic views for Cortex Analyst, verified queries, or larger iterative changes.

1. Create or retrieve a YAML semantic view spec.
2. Inspect logical tables, relationships, dimensions, facts, metrics, filters, custom instructions, and verified queries. Prefer structured get/set helpers when available; otherwise perform careful YAML edits that preserve unrelated fields.
3. Edit the YAML with the smallest targeted change. Preserve unrelated fields and ordering.
4. Verify without creating/replacing the object:

```sql
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  '<database>.<schema>',
  $$
  <yaml content>
  $$,
  TRUE
);
```

5. Use `scripts/build_yaml_procedure_sql.py` to generate the call safely from a YAML file:

```bash
SKILL_DIR=<path-to-snowflake-semantic-views-skill>
python3 "$SKILL_DIR/scripts/build_yaml_procedure_sql.py" model.yaml --schema DB.SCHEMA --verify-only > verify.sql
snow sql -f verify.sql --connection <connection_name>
```

6. Deploy only after verify-only succeeds:

```bash
SKILL_DIR=<path-to-snowflake-semantic-views-skill>
python3 "$SKILL_DIR/scripts/build_yaml_procedure_sql.py" model.yaml --schema DB.SCHEMA > deploy.sql
snow sql -f deploy.sql --connection <connection_name>
```

7. Run a semantic-view query and, when VQRs are present, run VQR compile/equivalence checks. See `references/vqr-validation.md`.

See `references/semantic-view-yaml.md`.

## Query Validation

Semantic views can be queried in two supported ways:

```sql
SELECT * FROM SEMANTIC_VIEW(
  my_semantic_view
  DIMENSIONS customer.customer_market_segment
  METRICS orders.order_average_value
)
ORDER BY customer_market_segment;
```

or with the semantic view name in `FROM`:

```sql
SELECT customer_market_segment, AGG(order_average_value)
FROM my_semantic_view
GROUP BY customer_market_segment
ORDER BY customer_market_segment;
```

Validation rules:

- Include at least one `DIMENSIONS`, `FACTS`, or `METRICS` clause in `SEMANTIC_VIEW(...)`.
- Do not combine `FACTS` and `METRICS` in the same `SEMANTIC_VIEW(...)` clause.
- When selecting metrics from the semantic view name directly, wrap defined metrics in `AGG(...)`.
- When returning a metric by a dimension, verify the dimension table is related to the metric table and is at the same or lower granularity.
- Compare generated SQL to trusted SQL with exact result matching. Approximate or "close" results are failures.

## Verified Queries And Cortex Analyst

- Use `AI_VERIFIED_QUERIES` in SQL DDL or `verified_queries` in YAML when the user has trusted question/SQL pairs.
- Verified query SQL should use semantic view constructs and defined logical dimensions/metrics, not raw table columns.
- For each VQR, verify the SQL executes and returns expected results before deploying. Prefer `SYSTEM$CORTEX_ANALYST_SVA_TOOL` `validate_verified_queries` when available; see `references/vqr-validation.md`.
- When suggestions are requested, prefer observed query history, Cortex Analyst events, or user-supplied business questions over synthetic examples.
- Keep VQR changes separate from structural fixes unless the user asks for both.

## Audit And Debug

- For broad audits, check VQR behavior, duplicate or inconsistent semantic elements, missing relationships, and metric/filter coverage. See `references/audit-debug.md`.
- For targeted debug, reproduce the failing natural-language question or SQL, compare generated SQL to trusted SQL with exact result matching, identify the smallest semantic-layer gap, patch it, and re-test.

## Failure Handling

- If `CREATE SEMANTIC VIEW` fails, inspect the exact Snowflake error, then check clause order, identifiers, relationship key declarations, aggregation expressions, and unsupported/deprecated fields.
- If YAML verify-only fails, fix schema/name/relationship/syntax errors in YAML and verify again before deploy.
- If Cortex Analyst SQL is wrong, reproduce the natural language question, compare generated SQL to trusted SQL, identify the semantic-layer gap, patch only that gap, and re-test.
- If Snowflake CLI flags differ, run `snow sql --help` using the same `SNOWFLAKE_HOME`/connection context.

## References

- `references/semantic-view-sql.md`: SQL DDL syntax, query syntax, validation checklist.
- `references/semantic-view-yaml.md`: YAML creation/verification/deploy workflow.
- `references/fastgen-workflow.md`: FastGen-first creation workflow.
- `references/vqr-validation.md`: VQR compile and execution validation.
- `references/audit-debug.md`: Audit/debug workflow checklist.
- `references/dbt-semantic-views.md`: dbt semantic view materialization notes.
