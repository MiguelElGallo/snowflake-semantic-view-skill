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

**VScode with Github Copilot users:** Support for skills is only available in VsCodeInsisders edition. More details available here: [Skills in VSCodeInsiders](https://code.visualstudio.com/docs/copilot/customization/agent-skills#_create-a-skill)

For VScode with Codex IDE extension,  just clone this repo and open it.

And click in the order shown here:

![alt text](image.png)
## Example output 

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
create or replace semantic view CONTROL.PUBLIC.SEMVIEW1
	tables (
		SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS primary key (O_ORDERKEY) with synonyms=('orders','order header') comment='Orders fact table (TPC-H).',
		SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER primary key (C_CUSTKEY) with synonyms=('customers','customer master') comment='Customers dimension table (TPC-H).',
		SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM primary key (L_ORDERKEY,L_LINENUMBER) with synonyms=('line items','order lines') comment='Line items fact table (TPC-H).',
		SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER primary key (S_SUPPKEY) with synonyms=('suppliers','vendors') comment='Suppliers dimension table (TPC-H).',
		SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION primary key (N_NATIONKEY) with synonyms=('nations','countries') comment='Nations dimension table (TPC-H).',
		SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION primary key (R_REGIONKEY) with synonyms=('regions') comment='Regions dimension table (TPC-H).'
	)
	relationships (
		ORDERS(O_CUSTKEY) references CUSTOMER(C_CUSTKEY),
		CUSTOMER(C_NATIONKEY) references NATION(N_NATIONKEY),
		LINEITEM(L_ORDERKEY) references ORDERS(O_ORDERKEY),
		LINEITEM(L_SUPPKEY) references SUPPLIER(S_SUPPKEY),
		SUPPLIER(S_NATIONKEY) references NATION(N_NATIONKEY),
		NATION(N_REGIONKEY) references REGION(R_REGIONKEY)
	)
	facts (
		ORDERS.ORDER_TOTAL_PRICE as orders.O_TOTALPRICE with synonyms=('order total','total price') comment='Total price of the order.',
		LINEITEM.LINE_QUANTITY as lineitem.L_QUANTITY with synonyms=('quantity','line quantity') comment='Quantity ordered on the line item.',
		LINEITEM.LINE_EXTENDED_PRICE as lineitem.L_EXTENDEDPRICE with synonyms=('extended price','line extended price') comment='Extended price for the line item.',
		LINEITEM.LINE_DISCOUNT as lineitem.L_DISCOUNT with synonyms=('discount','line discount') comment='Discount applied to the line item.',
		LINEITEM.LINE_TAX as lineitem.L_TAX with synonyms=('tax','line tax') comment='Tax applied to the line item.'
	)
	dimensions (
		ORDERS.ORDER_KEY as orders.O_ORDERKEY with synonyms=('order id','order number') comment='Unique identifier for the order.',
		ORDERS.ORDER_DATE as orders.O_ORDERDATE with synonyms=('order date','purchase date') comment='Date the order was placed.',
		ORDERS.ORDER_STATUS as orders.O_ORDERSTATUS with synonyms=('status','order status') comment='Status code for the order.',
		ORDERS.ORDER_PRIORITY as orders.O_ORDERPRIORITY with synonyms=('priority','order priority') comment='Priority assigned to the order.',
		ORDERS.SHIP_PRIORITY as orders.O_SHIPPRIORITY with synonyms=('ship priority','shipping priority') comment='Shipping priority for the order.',
		ORDERS.CLERK as orders.O_CLERK with synonyms=('clerk','order clerk') comment='Clerk responsible for the order.',
		CUSTOMER.CUSTOMER_KEY as customer.C_CUSTKEY with synonyms=('customer id','customer key') comment='Unique identifier for the customer.',
		CUSTOMER.CUSTOMER_NAME as customer.C_NAME with synonyms=('customer name','name') comment='Customer name.',
		CUSTOMER.MARKET_SEGMENT as customer.C_MKTSEGMENT with synonyms=('segment','market segment') comment='Customer market segment.',
		CUSTOMER.PHONE as customer.C_PHONE with synonyms=('phone','customer phone') comment='Customer phone number.',
		LINEITEM.LINE_NUMBER as lineitem.L_LINENUMBER with synonyms=('line number','line item number') comment='Line number on the order.',
		SUPPLIER.SUPPLIER_KEY as supplier.S_SUPPKEY with synonyms=('supplier id','supplier key') comment='Unique identifier for the supplier.',
		SUPPLIER.SUPPLIER_NAME as supplier.S_NAME with synonyms=('supplier name','vendor name') comment='Supplier name.',
		SUPPLIER.PHONE as supplier.S_PHONE with synonyms=('supplier phone','vendor phone') comment='Supplier phone number.',
		NATION.NATION_NAME as nation.N_NAME with synonyms=('nation','country') comment='Nation name.',
		REGION.REGION_NAME as region.R_NAME with synonyms=('region','region name') comment='Region name.'
	)
	metrics (
		ORDERS.ORDER_COUNT as COUNT(DISTINCT orders.O_ORDERKEY) with synonyms=('order count','orders') comment='Count of distinct orders.',
		ORDERS.ORDER_REVENUE as SUM(orders.O_TOTALPRICE) with synonyms=('order revenue','order total revenue') comment='Sum of order total price.',
		ORDERS.AVG_ORDER_VALUE as AVG(orders.O_TOTALPRICE) with synonyms=('average order value','avg order value') comment='Average order total price.',
		LINEITEM.TOTAL_QUANTITY as SUM(lineitem.L_QUANTITY) with synonyms=('total quantity','units') comment='Sum of line item quantities.',
		LINEITEM.TOTAL_EXTENDED_PRICE as SUM(lineitem.L_EXTENDEDPRICE) with synonyms=('total extended price','gross sales') comment='Sum of line item extended prices.',
		LINEITEM.TOTAL_DISCOUNT_AMOUNT as SUM(lineitem.L_EXTENDEDPRICE * lineitem.L_DISCOUNT) with synonyms=('total discount','discount amount') comment='Total discount amount across line items.',
		LINEITEM.NET_REVENUE as SUM(lineitem.L_EXTENDEDPRICE * (1 - lineitem.L_DISCOUNT)) with synonyms=('net revenue','net sales') comment='Net revenue after discounts.'
	)
	comment='Semantic view for TPCH orders with customer, supplier, and region context.';
```
