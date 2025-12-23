# snowflake-semantic-view-skill

A skill for creating and enhancing snowflake semantic views in SQL.

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## Usage

Review the instructions of your IDE, to see how to invoke this skill, or any Skill.

You can read more about Skills in the [Skills documentation](https://agentskills.io/home).

For example:
You can use VScode with Codex IDE extension which support skills: [Custom skills](https://developers.openai.com/codex/skills/create-skill)
(this is the one I used)

Or you could use Claude Desktop which also supports skills: [Using Skills in Claude](https://support.claude.com/en/articles/12512180-using-skills-in-claude)

Each one is different, so please refer to the documentation of your IDE.

For VScode with Codex IDE extension,  just clone this repo and open it.

And click in the order shown here:

![alt text](image.png)
## Example 

For this prompt:

```log
I want to create a semantic view based on SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS and
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER and
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION
and
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER

```

For example the response with GPT 5.2-codex could be:

```SQL
CREATE OR REPLACE SEMANTIC VIEW CONTROL.PUBLIC.SEMVIEW_ORDER__tmp_validate
  TABLES (
    orders AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
      PRIMARY KEY (O_ORDERKEY)
      WITH SYNONYMS ('orders', 'order header')
      COMMENT = 'Orders fact table.',
    customer AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
      PRIMARY KEY (C_CUSTKEY)
      WITH SYNONYMS ('customers', 'customer master')
      COMMENT = 'Customers dimension table.',
    lineitem AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
      PRIMARY KEY (L_ORDERKEY, L_LINENUMBER)
      WITH SYNONYMS ('line items', 'order lines')
      COMMENT = 'Order line items fact table.',
    supplier AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER
      PRIMARY KEY (S_SUPPKEY)
      WITH SYNONYMS ('suppliers', 'vendors')
      COMMENT = 'Suppliers dimension table.',
    nation AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION
      PRIMARY KEY (N_NATIONKEY)
      WITH SYNONYMS ('nations', 'countries')
      COMMENT = 'Nations dimension table.',
    region AS SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION
      PRIMARY KEY (R_REGIONKEY)
      WITH SYNONYMS ('regions')
      COMMENT = 'Regions dimension table.'
  )
  RELATIONSHIPS (
    orders (O_CUSTKEY) REFERENCES customer (C_CUSTKEY),
    lineitem (L_ORDERKEY) REFERENCES orders (O_ORDERKEY),
    lineitem (L_SUPPKEY) REFERENCES supplier (S_SUPPKEY),
    customer (C_NATIONKEY) REFERENCES nation (N_NATIONKEY),
    supplier (S_NATIONKEY) REFERENCES nation (N_NATIONKEY),
    nation (N_REGIONKEY) REFERENCES region (R_REGIONKEY)
  )
  FACTS (
    orders.order_total_price AS orders.O_TOTALPRICE
      WITH SYNONYMS ('order total', 'total price')
      COMMENT = 'Total price of the order (order-level).',
    lineitem.line_quantity AS lineitem.L_QUANTITY
      WITH SYNONYMS ('quantity', 'line quantity')
      COMMENT = 'Quantity ordered on the line item.',
    lineitem.line_extended_price AS lineitem.L_EXTENDEDPRICE
      WITH SYNONYMS ('extended price', 'line extended price')
      COMMENT = 'Extended price for the line item.',
    lineitem.line_discount AS lineitem.L_DISCOUNT
      WITH SYNONYMS ('discount', 'line discount')
      COMMENT = 'Discount applied to the line item.',
    lineitem.line_tax AS lineitem.L_TAX
      WITH SYNONYMS ('tax', 'line tax')
      COMMENT = 'Tax applied to the line item.'
  )
  DIMENSIONS (
    orders.order_key AS orders.O_ORDERKEY
      WITH SYNONYMS ('order id', 'order number')
      COMMENT = 'Unique identifier for the order.',
    orders.order_date AS orders.O_ORDERDATE
      WITH SYNONYMS ('order date', 'purchase date')
      COMMENT = 'Date the order was placed.',
    orders.order_status AS orders.O_ORDERSTATUS
      WITH SYNONYMS ('status', 'order status')
      COMMENT = 'Status code for the order.',
    orders.order_priority AS orders.O_ORDERPRIORITY
      WITH SYNONYMS ('priority', 'order priority')
      COMMENT = 'Priority assigned to the order.',
    orders.ship_priority AS orders.O_SHIPPRIORITY
      WITH SYNONYMS ('ship priority', 'shipping priority')
      COMMENT = 'Shipping priority for the order.',
    orders.clerk AS orders.O_CLERK
      WITH SYNONYMS ('clerk', 'order clerk')
      COMMENT = 'Clerk responsible for the order.',
    customer.customer_key AS customer.C_CUSTKEY
      WITH SYNONYMS ('customer id', 'customer key')
      COMMENT = 'Unique identifier for the customer.',
    customer.customer_name AS customer.C_NAME
      WITH SYNONYMS ('customer name', 'name')
      COMMENT = 'Customer name.',
    customer.market_segment AS customer.C_MKTSEGMENT
      WITH SYNONYMS ('segment', 'market segment')
      COMMENT = 'Customer market segment.',
    customer.phone AS customer.C_PHONE
      WITH SYNONYMS ('phone', 'customer phone')
      COMMENT = 'Customer phone number.',
    supplier.supplier_key AS supplier.S_SUPPKEY
      WITH SYNONYMS ('supplier id', 'supplier key')
      COMMENT = 'Unique identifier for the supplier.',
    supplier.supplier_name AS supplier.S_NAME
      WITH SYNONYMS ('supplier name', 'vendor name')
      COMMENT = 'Supplier name.',
    nation.nation_name AS nation.N_NAME
      WITH SYNONYMS ('nation', 'country')
      COMMENT = 'Nation name.',
    region.region_name AS region.R_NAME
      WITH SYNONYMS ('region', 'region name')
      COMMENT = 'Region name.'
  )
  METRICS (
    orders.order_count AS COUNT(DISTINCT orders.O_ORDERKEY)
      WITH SYNONYMS ('order count', 'orders')
      COMMENT = 'Count of distinct orders.',
    orders.order_revenue AS SUM(orders.O_TOTALPRICE)
      WITH SYNONYMS ('order revenue', 'order total revenue')
      COMMENT = 'Sum of order total price (order-level).',
    orders.avg_order_value AS AVG(orders.O_TOTALPRICE)
      WITH SYNONYMS ('average order value', 'avg order value')
      COMMENT = 'Average order total price (order-level).',
    lineitem.total_quantity AS SUM(lineitem.L_QUANTITY)
      WITH SYNONYMS ('total quantity', 'units')
      COMMENT = 'Sum of line item quantities.',
    lineitem.total_extended_price AS SUM(lineitem.L_EXTENDEDPRICE)
      WITH SYNONYMS ('total extended price', 'gross sales')
      COMMENT = 'Sum of line item extended prices.',
    lineitem.total_discount_amount AS SUM(lineitem.L_EXTENDEDPRICE * lineitem.L_DISCOUNT)
      WITH SYNONYMS ('total discount', 'discount amount')
      COMMENT = 'Total discount amount across line items.',
    lineitem.net_revenue AS SUM(lineitem.L_EXTENDEDPRICE * (1 - lineitem.L_DISCOUNT))
      WITH SYNONYMS ('net revenue', 'net sales')
      COMMENT = 'Net revenue after discounts.'
  )
  COMMENT = 'Semantic view for TPCH orders with customer, supplier, and region context.';
```
