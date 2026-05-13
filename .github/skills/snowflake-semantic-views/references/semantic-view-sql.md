# Semantic View SQL Reference

Use this file when drafting or debugging `CREATE SEMANTIC VIEW` DDL.

Official references:

- `CREATE SEMANTIC VIEW`: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- Querying semantic views: https://docs.snowflake.com/en/user-guide/views-semantic/querying
- Verified query release note: https://docs.snowflake.com/en/release-notes/2026/other/2026-04-05-semantic-views-verified-queries

## Clause Order

Use this order unless Snowflake documentation changes:

```sql
CREATE OR REPLACE SEMANTIC VIEW <name>
  TABLES ( ... )
  RELATIONSHIPS ( ... )
  FACTS ( ... )
  DIMENSIONS ( ... )
  METRICS ( ... )
  COMMENT = '...'
  AI_SQL_GENERATION '...'
  AI_QUESTION_CATEGORIZATION '...'
  AI_VERIFIED_QUERIES ( ... )
  COPY GRANTS;
```

`TABLES` is required. Other sections depend on the model, but a Cortex Analyst-ready model should normally include relationships, dimensions, and metrics.

## Relationship Rules

- Define primary keys for logical tables whenever possible.
- If a relationship references a non-primary-key column, declare that target column as `UNIQUE`.
- Name relationships clearly, for example `orders_to_customer`.
- Use `USING (<relationship_name>)` in metrics when multiple relationship paths can reach the same logical table.

## Comments And Synonyms

Add comments and synonyms to logical tables, dimensions, facts, and metrics:

```sql
WITH SYNONYMS = ('sales', 'revenue')
COMMENT = 'Business definition of the element.'
```

Use existing Snowflake comments first. When comments are missing, draft but do not deploy invented business descriptions without user approval.

## Metrics

Include metrics for fact tables unless the user explicitly asks not to. Useful starting points:

- `COUNT(DISTINCT <business_key>)`
- `SUM(<amount>)`
- `AVG(<amount>)`
- ratio metrics that reference earlier metrics, where supported by the DDL.

Use `NON ADDITIVE BY` for semi-additive metrics and window-function metric syntax only when required by the business question.

## Query Checks

At least one of `DIMENSIONS`, `FACTS`, or `METRICS` must appear in `SEMANTIC_VIEW(...)`.

Do not combine `FACTS` and `METRICS` in the same `SEMANTIC_VIEW(...)`.

```sql
SELECT *
FROM SEMANTIC_VIEW(
  my_view
  DIMENSIONS customer.segment
  METRICS orders.total_revenue
)
ORDER BY segment;
```

When querying the semantic view name directly, wrap defined metrics in `AGG(...)`:

```sql
SELECT segment, AGG(total_revenue)
FROM my_view
GROUP BY segment;
```

## Validation Checklist

- The DDL runs successfully against a temporary semantic view name.
- The final DDL differs from the temporary DDL only by object name or expected deploy-only clauses.
- A semantic-view query runs against the final object.
- Temporary validation objects are dropped.
- Verified queries, if present, execute and use semantic-view constructs rather than raw table columns.
