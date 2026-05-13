# Semantic View YAML Reference

Use this file when creating, retrieving, validating, or deploying semantic view YAML.

Official references:

- YAML specification: https://docs.snowflake.com/en/user-guide/views-semantic/semantic-view-yaml-spec
- `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML`: https://docs.snowflake.com/en/sql-reference/stored-procedures/system_create_semantic_view_from_yaml
- Verified query repository: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/verified-query-repository
- Suggestions: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/verified-query-suggestions

## When To Prefer YAML

Prefer YAML for:

- Cortex Analyst semantic views.
- Verified query repositories.
- Larger semantic views where DDL rewriting is error-prone.
- Existing semantic views that need targeted metadata, relationship, metric, filter, or VQR edits.

## Logical And Physical Names

Semantic YAML defines logical tables and columns over physical base tables:

```yaml
tables:
  - name: orders
    base_table:
      database: RAW
      schema: SALES
      table: ORDERS
```

Generated SQL can reference physical base tables. Do not treat physical table references as an issue unless the SQL is semantically wrong.

## Verify-Only Before Deploy

Always run verify-only before deployment:

```sql
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'DB.SCHEMA',
  $$
  name: my_view
  tables: []
  $$,
  TRUE
);
```

Use `scripts/build_yaml_procedure_sql.py` to avoid quoting mistakes:

```bash
SKILL_DIR=<path-to-snowflake-semantic-views-skill>
python3 "$SKILL_DIR/scripts/build_yaml_procedure_sql.py" model.yaml --schema DB.SCHEMA --verify-only > verify.sql
snow sql -f verify.sql --connection <connection_name>
```

Deploy by omitting `--verify-only` after verification succeeds.

## Editing Guidance

- Preserve existing YAML fields not related to the requested change.
- Prefer structured semantic-view YAML get/set helpers when they are available in the environment. If editing directly, keep the edit targeted and verify with Snowflake before deploy.
- Enhance existing dimensions/facts with descriptions, synonyms, and sample values.
- Add metrics, filters, relationships, verified queries, and instructions when the model lacks explicit semantic concepts.
- Avoid deprecated `measures` in new semantic views; use `facts`.
- Do not use deprecated relationship types such as `one_to_many` or `many_to_many`.

## Verified Queries

Verified queries should include:

- A descriptive name.
- The natural language question.
- SQL that references semantic view logical dimensions/metrics and uses semantic-view query syntax.
- Verification metadata when available.

Validate each VQR by executing the SQL and comparing to trusted results. For optimization work, keep VQR edits separate from relationship/metric/filter edits unless both are requested.
