# dbt Semantic Views

Use this file when the user asks for Snowflake semantic views in a dbt project.

The `Snowflake-Labs/dbt_semantic_view` package provides a `semantic_view` materialization. The model body is the DDL body that follows `CREATE OR REPLACE SEMANTIC VIEW <name>`.

## Package

```yaml
packages:
  - package: Snowflake-Labs/dbt_semantic_view
    version: [">=1.0.0"]
```

## Model Shape

```sql
{{ config(materialized='semantic_view') }}

TABLES (
  orders AS {{ ref('fct_orders') }} PRIMARY KEY (order_id),
  customers AS {{ ref('dim_customers') }} PRIMARY KEY (customer_id)
)

RELATIONSHIPS (
  orders_to_customers AS orders(customer_id) REFERENCES customers(customer_id)
)

FACTS (
  orders.order_amount AS orders.amount
)

DIMENSIONS (
  customers.customer_name AS customers.customer_name
    WITH SYNONYMS = ('client name')
    COMMENT = 'Customer display name.'
)

METRICS (
  orders.total_revenue AS SUM(orders.order_amount)
    WITH SYNONYMS = ('sales', 'revenue')
    COMMENT = 'Total order revenue.'
)
```

## dbt-Specific Rules

- Use `{{ ref('model_name') }}` for base relations so dbt resolves dependencies.
- Keep semantic view clause order aligned with Snowflake DDL.
- Use `config(copy_grants=true)` or `COPY GRANTS` when replacing an existing object that has grants.
- Pass through `AI_SQL_GENERATION`, `AI_QUESTION_CATEGORIZATION`, and `AI_VERIFIED_QUERIES` in the model body when needed.
- Validate the compiled SQL in Snowflake before treating the dbt model as complete.
