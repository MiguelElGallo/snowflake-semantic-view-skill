# FastGen-First Creation

Use this file when creating a new Cortex Analyst-ready semantic view from tables, SQL, or business questions.

## Preferred Path

When the account supports it, call `SYSTEM$CORTEX_ANALYST_FAST_GENERATION` before falling back to manual DDL/YAML. FastGen can infer table metadata, primary keys, relationships, metrics, and verified-query candidates from user-supplied SQL and table context.

## Required Inputs

- Semantic view name.
- Target database and schema.
- Active warehouse.
- Source tables with columns, discovered through `DESCRIBE TABLE`.
- User-supplied SQL queries or business questions when available. Do not invent representative SQL without approval.

## Request Checklist

- Wrap the payload in `json_proto`.
- Use top-level `name`, `database`, and `schema`.
- Include `metadata.warehouse`.
- Include at least one table with `database`, `schema`, `table`, and `columnNames`.
- Use camelCase fields such as `columnNames`, `sqlSource`, `sqlText`, and `correspondingQuestion`.

## Execution Pattern

Execute FastGen once, then immediately store the query ID before running any other SQL:

```sql
SELECT SYSTEM$CORTEX_ANALYST_FAST_GENERATION('<request_json>') AS result;
SET fastgen_query_id = (SELECT LAST_QUERY_ID());
```

Use `RESULT_SCAN($fastgen_query_id)` for all result extraction. Do not rely on `LAST_QUERY_ID()` after additional queries.

## Validation

- Save the request JSON and generated YAML outside the repo unless the user explicitly wants artifacts committed.
- Validate the generated YAML with `SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(..., TRUE)`.
- Inspect warnings, errors, relationship suggestions, and primary-key suggestions.
- Fall back to manual SQL/YAML only if FastGen is unavailable or fails after a useful retry.
