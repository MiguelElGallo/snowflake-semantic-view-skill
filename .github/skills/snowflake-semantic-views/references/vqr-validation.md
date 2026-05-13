# Verified Query Validation

Use this file when adding, editing, auditing, or compiling verified queries.

## Basic Checks

- The question is clear and maps to one trusted SQL answer.
- The SQL references semantic view logical dimensions, facts, and metrics rather than raw table columns.
- The SQL executes successfully against Snowflake.
- Results exactly match trusted SQL or expected output. Approximate matches are failures.

## SVA Compile Check

When available, use `SYSTEM$CORTEX_ANALYST_SVA_TOOL` with `validate_verified_queries` to compile-check VQR SQL against a semantic model.

Use `PARSE_JSON` plus `LATERAL FLATTEN` when you need one row per query result. Avoid relying only on a large raw JSON string result.

Payload shape:

```json
{
  "tool": "validate_verified_queries",
  "tool_input": {
    "semantic_model": "<yaml without verified_queries section>",
    "sqls": ["<verified query SQL>"],
    "is_semantic_view": true
  }
}
```

## Workflow

1. Strip `verified_queries` from the YAML payload used for validation.
2. Validate candidate SQL with `validate_verified_queries`.
3. Execute the SQL against the semantic view.
4. Compare output to trusted SQL with exact row/value matching.
5. Only then add the VQR to DDL or YAML.
