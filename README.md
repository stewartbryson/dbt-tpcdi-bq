# What is this?
This is a [dbt](https://www.getdbt.com/) project using BigQuery for building the data warehouse defined in the TPC-DI specification.


![Figure 1.2–1 from the TPC-DI specification describes the ETL process.](images/tpc-di-etl-diagram.png)


![Figure 1.4–1 from the TPC-DI specification describes the target logical model. More on DimTrade later.](images/tpc-di-logical-model.png)


I took a few liberties with the TPC-DI specification to update it a bit for BigQuery.
First, I replaced `CamelCase` names with `SNAKE_CASE`, mostly out of irritation with readability.
Secondly, I just couldn't stand for having the `DimTrade` table be "both a dimension table and a fact table, depending on how it is being used" as it was designed by TPC-DI.
This decision was clearly made during an era when storage and compute were constrained, so in my design, I created both `DIM_TRADE` and `FACT_TRADE` tables.
Finally, I used a Medallion Lakehouse Architecture with Bronze, Silver, and Gold zones, with the logical model above materialized in the Gold zone.

# Building a Medallion Architecture with dbt

In the Medallion architecture, we typically append raw data in their original format into Bronze, business entities modeled in Silver, and our highly curated facts and dimensions in Gold.

The dbt DAG looks like this:

![dbt DAG](images/dbt-dag.png)

```bash
❯ dbt build
16:55:34  Running with dbt=1.7.2
16:55:34  Registered adapter: snowflake=1.7.0
16:55:34  Found 45 models, 1 test, 17 sources, 0 exposures, 0 metrics, 544 macros, 0 groups, 0 semantic models
16:55:34  
16:55:36  Concurrency: 20 threads (target='dev')
16:55:36  
16:55:36  1 of 45 START sql dynamic_table model dl_bronze.brokerage_cash_transaction ..... [RUN]
16:55:36  2 of 45 START sql dynamic_table model dl_bronze.brokerage_daily_market ......... [RUN]
16:55:36  3 of 45 START sql dynamic_table model dl_bronze.brokerage_holding_history ...... [RUN]
16:55:36  4 of 45 START sql dynamic_table model dl_bronze.brokerage_trade ................ [RUN]
16:55:36  5 of 45 START sql dynamic_table model dl_bronze.brokerage_trade_history ........ [RUN]
16:55:36  6 of 45 START sql dynamic_table model dl_bronze.brokerage_watch_history ........ [RUN]
16:55:36  7 of 45 START sql dynamic_table model dl_bronze.crm_customer_mgmt .............. [RUN]
16:55:36  8 of 45 START sql dynamic_table model dl_bronze.finwire_company ................ [RUN]
16:55:36  9 of 45 START sql dynamic_table model dl_bronze.finwire_financial .............. [RUN]
16:55:36  10 of 45 START sql dynamic_table model dl_bronze.finwire_security .............. [RUN]
16:55:36  11 of 45 START sql dynamic_table model dl_bronze.hr_employee ................... [RUN]
16:55:36  12 of 45 START sql dynamic_table model dl_bronze.reference_date ................ [RUN]
16:55:36  13 of 45 START sql dynamic_table model dl_bronze.reference_industry ............ [RUN]
16:55:36  14 of 45 START sql dynamic_table model dl_bronze.reference_status_type ......... [RUN]
16:55:36  15 of 45 START sql dynamic_table model dl_bronze.reference_tax_rate ............ [RUN]
16:55:36  16 of 45 START sql dynamic_table model dl_bronze.reference_trade_type .......... [RUN]
16:55:36  17 of 45 START sql dynamic_table model dl_bronze.syndicated_prospect ........... [RUN]
16:55:38  13 of 45 OK created sql dynamic_table model dl_bronze.reference_industry ....... [SUCCESS 1 in 2.54s]
16:55:39  12 of 45 OK created sql dynamic_table model dl_bronze.reference_date ........... [SUCCESS 1 in 2.85s]
16:55:39  18 of 45 START sql dynamic_table model dl_silver.date .......................... [RUN]
16:55:39  14 of 45 OK created sql dynamic_table model dl_bronze.reference_status_type .... [SUCCESS 1 in 3.09s]
16:55:39  15 of 45 OK created sql dynamic_table model dl_bronze.reference_tax_rate ....... [SUCCESS 1 in 3.09s]
16:55:39  16 of 45 OK created sql dynamic_table model dl_bronze.reference_trade_type ..... [SUCCESS 1 in 3.21s]
16:55:39  9 of 45 OK created sql dynamic_table model dl_bronze.finwire_financial ......... [SUCCESS 1 in 3.57s]
16:55:40  8 of 45 OK created sql dynamic_table model dl_bronze.finwire_company ........... [SUCCESS 1 in 4.08s]
16:55:40  11 of 45 OK created sql dynamic_table model dl_bronze.hr_employee .............. [SUCCESS 1 in 4.08s]
16:55:40  19 of 45 START sql dynamic_table model dl_silver.companies ..................... [RUN]
16:55:40  20 of 45 START sql dynamic_table model dl_silver.employees ..................... [RUN]
16:55:40  10 of 45 OK created sql dynamic_table model dl_bronze.finwire_security ......... [SUCCESS 1 in 4.18s]
16:55:40  7 of 45 OK created sql dynamic_table model dl_bronze.crm_customer_mgmt ......... [SUCCESS 1 in 4.32s]
16:55:40  21 of 45 START sql dynamic_table model dl_silver.accounts ...................... [RUN]
16:55:40  22 of 45 START sql dynamic_table model dl_silver.customers ..................... [RUN]
16:55:41  18 of 45 OK created sql dynamic_table model dl_silver.date ..................... [SUCCESS 1 in 2.45s]
16:55:41  23 of 45 START sql dynamic_table model dl_gold.dim_date ........................ [RUN]
16:55:41  17 of 45 OK created sql dynamic_table model dl_bronze.syndicated_prospect ...... [SUCCESS 1 in 5.55s]
16:55:42  1 of 45 OK created sql dynamic_table model dl_bronze.brokerage_cash_transaction  [SUCCESS 1 in 6.55s]
16:55:43  21 of 45 OK created sql dynamic_table model dl_silver.accounts ................. [SUCCESS 1 in 2.52s]
16:55:43  24 of 45 START sql dynamic_table model dl_silver.cash_transactions ............. [RUN]
16:55:43  19 of 45 OK created sql dynamic_table model dl_silver.companies ................ [SUCCESS 1 in 2.77s]
16:55:43  26 of 45 START sql dynamic_table model dl_silver.financials .................... [RUN]
16:55:43  25 of 45 START sql dynamic_table model dl_gold.dim_company ..................... [RUN]
16:55:43  27 of 45 START sql dynamic_table model dl_silver.securities .................... [RUN]
16:55:44  22 of 45 OK created sql dynamic_table model dl_silver.customers ................ [SUCCESS 1 in 3.64s]
16:55:44  28 of 45 START sql dynamic_table model dl_gold.dim_customer .................... [RUN]
16:55:44  20 of 45 OK created sql dynamic_table model dl_silver.employees ................ [SUCCESS 1 in 4.11s]
16:55:44  29 of 45 START sql dynamic_table model dl_gold.dim_broker ...................... [RUN]
16:55:44  4 of 45 OK created sql dynamic_table model dl_bronze.brokerage_trade ........... [SUCCESS 1 in 8.22s]
16:55:44  2 of 45 OK created sql dynamic_table model dl_bronze.brokerage_daily_market .... [SUCCESS 1 in 8.23s]
16:55:44  30 of 45 START sql dynamic_table model dl_silver.daily_market .................. [RUN]
16:55:44  23 of 45 OK created sql dynamic_table model dl_gold.dim_date ................... [SUCCESS 1 in 2.94s]
16:55:44  3 of 45 OK created sql dynamic_table model dl_bronze.brokerage_holding_history . [SUCCESS 1 in 8.49s]
16:55:46  25 of 45 OK created sql dynamic_table model dl_gold.dim_company ................ [SUCCESS 1 in 3.33s]
16:55:47  6 of 45 OK created sql dynamic_table model dl_bronze.brokerage_watch_history ... [SUCCESS 1 in 10.86s]
16:55:47  29 of 45 OK created sql dynamic_table model dl_gold.dim_broker ................. [SUCCESS 1 in 2.98s]
16:55:47  27 of 45 OK created sql dynamic_table model dl_silver.securities ............... [SUCCESS 1 in 4.76s]
16:55:47  31 of 45 START sql dynamic_table model dl_gold.dim_security .................... [RUN]
16:55:47  32 of 45 START sql dynamic_table model dl_silver.watches_history ............... [RUN]
16:55:48  5 of 45 OK created sql dynamic_table model dl_bronze.brokerage_trade_history ... [SUCCESS 1 in 11.82s]
16:55:48  33 of 45 START sql dynamic_table model dl_silver.trades_history ................ [RUN]
16:55:48  28 of 45 OK created sql dynamic_table model dl_gold.dim_customer ............... [SUCCESS 1 in 4.58s]
16:55:48  34 of 45 START sql dynamic_table model dl_gold.dim_account ..................... [RUN]
16:55:49  24 of 45 OK created sql dynamic_table model dl_silver.cash_transactions ........ [SUCCESS 1 in 5.91s]
16:55:49  30 of 45 OK created sql dynamic_table model dl_silver.daily_market ............. [SUCCESS 1 in 4.63s]
16:55:50  26 of 45 OK created sql dynamic_table model dl_silver.financials ............... [SUCCESS 1 in 7.20s]
16:55:51  31 of 45 OK created sql dynamic_table model dl_gold.dim_security ............... [SUCCESS 1 in 3.81s]
16:55:51  35 of 45 START sql dynamic_table model dl_gold.fact_market_history ............. [RUN]
16:55:52  34 of 45 OK created sql dynamic_table model dl_gold.dim_account ................ [SUCCESS 1 in 3.71s]
16:55:52  36 of 45 START sql dynamic_table model dl_gold.fact_cash_transactions .......... [RUN]
16:55:54  32 of 45 OK created sql dynamic_table model dl_silver.watches_history .......... [SUCCESS 1 in 6.08s]
16:55:54  37 of 45 START sql dynamic_table model dl_silver.watches ....................... [RUN]
16:55:58  36 of 45 OK created sql dynamic_table model dl_gold.fact_cash_transactions ..... [SUCCESS 1 in 5.65s]
16:55:58  38 of 45 START sql dynamic_table model dl_gold.fact_cash_balances .............. [RUN]
16:56:00  37 of 45 OK created sql dynamic_table model dl_silver.watches .................. [SUCCESS 1 in 6.13s]
16:56:00  39 of 45 START sql dynamic_table model dl_gold.fact_watches .................... [RUN]
16:56:00  33 of 45 OK created sql dynamic_table model dl_silver.trades_history ........... [SUCCESS 1 in 12.60s]
16:56:00  40 of 45 START sql dynamic_table model dl_gold.dim_trade ....................... [RUN]
16:56:00  41 of 45 START sql dynamic_table model dl_silver.trades ........................ [RUN]
16:56:03  38 of 45 OK created sql dynamic_table model dl_gold.fact_cash_balances ......... [SUCCESS 1 in 5.45s]
16:56:05  40 of 45 OK created sql dynamic_table model dl_gold.dim_trade .................. [SUCCESS 1 in 4.51s]
16:56:06  39 of 45 OK created sql dynamic_table model dl_gold.fact_watches ............... [SUCCESS 1 in 6.40s]
16:56:08  41 of 45 OK created sql dynamic_table model dl_silver.trades ................... [SUCCESS 1 in 7.40s]
16:56:08  42 of 45 START sql dynamic_table model dl_silver.holdings_history .............. [RUN]
16:56:08  43 of 45 START sql dynamic_table model dl_gold.fact_trade ...................... [RUN]
16:56:15  42 of 45 OK created sql dynamic_table model dl_silver.holdings_history ......... [SUCCESS 1 in 7.03s]
16:56:15  44 of 45 START sql dynamic_table model dl_gold.fact_holdings ................... [RUN]
16:56:22  43 of 45 OK created sql dynamic_table model dl_gold.fact_trade ................. [SUCCESS 1 in 14.53s]
16:56:22  45 of 45 START test fact_trade__unique_trade ................................... [RUN]
16:56:23  45 of 45 PASS fact_trade__unique_trade ......................................... [PASS in 1.30s]
16:56:25  44 of 45 OK created sql dynamic_table model dl_gold.fact_holdings .............. [SUCCESS 1 in 9.95s]
16:56:44  35 of 45 OK created sql dynamic_table model dl_gold.fact_market_history ........ [SUCCESS 1 in 53.21s]
16:56:44  
16:56:44  Finished running 44 dynamic_table models, 1 test in 0 hours 1 minutes and 10.51 seconds (70.51s).
16:56:45  
16:56:45  Completed successfully
16:56:45  
16:56:45  Done. PASS=45 WARN=0 ERROR=0 SKIP=0 TOTAL=45
```

# Future Enhancements
Although it wasn't my goal, it would be cool to enhance this project so that it could be used to run and measure the benchmark. 
These are my thoughts on where to take this next:

1. Complete `Batch2` and `Batch3` using dbt incremental models, and put the audit queries in as dbt tests.
2. Refactor tpcdi.py to only upload the files and do that concurrently, then put all the Snowpark transformations into procedures so they can be executed as concurrent tasks.
3. Maybe take another pass at credential handling, using the `config.toml` from [Snowflake CLI](https://github.com/snowflake-labs/snowcli#cli-tour-and-quickstart).
Provide a command-line option `--schema` so it can be specified during loading, instead of using `CURRENT_SCHEMA`.

If you are interested in contributing, jump on board. You don't need my permission, or even incredible skill, clearly. 
Just open a pull request.
