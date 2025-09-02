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
dbt ❯ dbt build
18:51:16  Running with dbt=1.10.1
18:51:20  Registered adapter: bigquery=1.9.2
18:51:20  Found 45 models, 1 test, 17 sources, 607 macros
18:51:20  
18:51:20  Concurrency: 4 threads (target='dev')
18:51:20  
18:51:22  1 of 45 START sql table model dl_bronze.brokerage_cash_transaction ............. [RUN]
18:51:22  2 of 45 START sql table model dl_bronze.brokerage_daily_market ................. [RUN]
18:51:22  3 of 45 START sql table model dl_bronze.brokerage_holding_history .............. [RUN]
18:51:22  4 of 45 START sql table model dl_bronze.brokerage_trade ........................ [RUN]
18:51:28  4 of 45 OK created sql table model dl_bronze.brokerage_trade ................... [CREATE TABLE (1.3m rows, 132.3 MiB processed) in 5.82s]
18:51:28  3 of 45 OK created sql table model dl_bronze.brokerage_holding_history ......... [CREATE TABLE (1.2m rows, 36.8 MiB processed) in 5.82s]
18:51:28  5 of 45 START sql table model dl_bronze.brokerage_trade_history ................ [RUN]
18:51:28  6 of 45 START sql table model dl_bronze.brokerage_watch_history ................ [RUN]
18:51:28  2 of 45 OK created sql table model dl_bronze.brokerage_daily_market ............ [CREATE TABLE (5.3m rows, 286.5 MiB processed) in 6.32s]
18:51:28  7 of 45 START sql table model dl_bronze.crm_customer_mgmt ...................... [RUN]
18:51:31  1 of 45 OK created sql table model dl_bronze.brokerage_cash_transaction ........ [CREATE TABLE (1.2m rows, 93.0 MiB processed) in 9.18s]
18:51:31  8 of 45 START sql table model dl_bronze.finwire_company ........................ [RUN]
18:51:32  7 of 45 OK created sql table model dl_bronze.crm_customer_mgmt ................. [CREATE TABLE (50.0k rows, 6.8 MiB processed) in 3.76s]
18:51:32  9 of 45 START sql table model dl_bronze.finwire_financial ...................... [RUN]
18:51:34  6 of 45 OK created sql table model dl_bronze.brokerage_watch_history ........... [CREATE TABLE (3.0m rows, 111.6 MiB processed) in 5.75s]
18:51:34  10 of 45 START sql table model dl_bronze.finwire_security ...................... [RUN]
18:51:34  5 of 45 OK created sql table model dl_bronze.brokerage_trade_history ........... [CREATE TABLE (3.3m rows, 68.6 MiB processed) in 5.97s]
18:51:34  11 of 45 START sql table model dl_bronze.hr_employee ........................... [RUN]
18:51:35  8 of 45 OK created sql table model dl_bronze.finwire_company ................... [CREATE TABLE (5.0k rows, 2.6 MiB processed) in 3.69s]
18:51:35  12 of 45 START sql table model dl_bronze.reference_date ........................ [RUN]
18:51:37  10 of 45 OK created sql table model dl_bronze.finwire_security ................. [CREATE TABLE (8.0k rows, 1.4 MiB processed) in 3.65s]
18:51:37  13 of 45 START sql table model dl_bronze.reference_industry .................... [RUN]
18:51:38  11 of 45 OK created sql table model dl_bronze.hr_employee ...................... [CREATE TABLE (50.0k rows, 4.5 MiB processed) in 4.15s]
18:51:38  14 of 45 START sql table model dl_bronze.reference_status_type ................. [RUN]
18:51:39  12 of 45 OK created sql table model dl_bronze.reference_date ................... [CREATE TABLE (25.9k rows, 3.7 MiB processed) in 3.60s]
18:51:39  15 of 45 START sql table model dl_bronze.reference_tax_rate .................... [RUN]
18:51:41  13 of 45 OK created sql table model dl_bronze.reference_industry ............... [CREATE TABLE (103.0 rows, 2.8 KiB processed) in 3.78s]
18:51:41  16 of 45 START sql table model dl_bronze.reference_trade_type .................. [RUN]
18:51:42  14 of 45 OK created sql table model dl_bronze.reference_status_type ............ [CREATE TABLE (7.0 rows, 111.0 Bytes processed) in 3.62s]
18:51:42  17 of 45 START sql table model dl_bronze.syndicated_prospect ................... [RUN]
18:51:42  9 of 45 OK created sql table model dl_bronze.finwire_financial ................. [CREATE TABLE (457.0k rows, 68.4 MiB processed) in 10.30s]
18:51:42  18 of 45 START sql table model dl_silver.daily_market .......................... [RUN]
18:51:42  15 of 45 OK created sql table model dl_bronze.reference_tax_rate ............... [CREATE TABLE (320.0 rows, 17.0 KiB processed) in 3.93s]
18:51:43  19 of 45 START sql table model dl_silver.employees ............................. [RUN]
18:51:44  16 of 45 OK created sql table model dl_bronze.reference_trade_type ............. [CREATE TABLE (5.0 rows, 94.0 Bytes processed) in 3.39s]
18:51:44  20 of 45 START sql table model dl_silver.date .................................. [RUN]
18:51:47  19 of 45 OK created sql table model dl_silver.employees ........................ [CREATE TABLE (50.0k rows, 4.5 MiB processed) in 4.11s]
18:51:47  21 of 45 START sql table model dl_silver.companies ............................. [RUN]
18:51:47  17 of 45 OK created sql table model dl_bronze.syndicated_prospect .............. [CREATE TABLE (49.9k rows, 11.7 MiB processed) in 5.10s]
18:51:47  22 of 45 START sql table model dl_silver.accounts .............................. [RUN]
18:51:48  20 of 45 OK created sql table model dl_silver.date ............................. [CREATE TABLE (25.9k rows, 3.9 MiB processed) in 3.48s]
18:51:48  23 of 45 START sql table model dl_silver.customers ............................. [RUN]
18:51:52  22 of 45 OK created sql table model dl_silver.accounts ......................... [CREATE TABLE (43.5k rows, 6.8 MiB processed) in 4.77s]
18:51:52  24 of 45 START sql table model dl_silver.trades_history ........................ [RUN]
18:51:52  18 of 45 OK created sql table model dl_silver.daily_market ..................... [CREATE TABLE (5.3m rows, 286.5 MiB processed) in 9.27s]
18:51:52  25 of 45 START sql table model dl_gold.dim_broker .............................. [RUN]
18:51:52  23 of 45 OK created sql table model dl_silver.customers ........................ [CREATE TABLE (21.8k rows, 5.4 MiB processed) in 4.25s]
18:51:52  26 of 45 START sql table model dl_gold.dim_date ................................ [RUN]
18:51:53  21 of 45 OK created sql table model dl_silver.companies ........................ [CREATE TABLE (5.0k rows, 2.6 MiB processed) in 6.01s]
18:51:53  27 of 45 START sql table model dl_silver.cash_transactions ..................... [RUN]
18:51:56  26 of 45 OK created sql table model dl_gold.dim_date ........................... [CREATE TABLE (25.9k rows, 3.9 MiB processed) in 3.99s]
18:51:56  25 of 45 OK created sql table model dl_gold.dim_broker ......................... [CREATE TABLE (50.0k rows, 4.5 MiB processed) in 4.09s]
18:51:56  28 of 45 START sql table model dl_gold.dim_customer ............................ [RUN]
18:51:56  29 of 45 START sql table model dl_gold.dim_company ............................. [RUN]
18:51:58  27 of 45 OK created sql table model dl_silver.cash_transactions ................ [CREATE TABLE (1.2m rows, 94.3 MiB processed) in 5.44s]
18:51:58  30 of 45 START sql table model dl_silver.financials ............................ [RUN]
18:51:58  24 of 45 OK created sql table model dl_silver.trades_history ................... [CREATE TABLE (3.3m rows, 200.9 MiB processed) in 6.68s]
18:51:58  31 of 45 START sql table model dl_silver.securities ............................ [RUN]
18:52:00  29 of 45 OK created sql table model dl_gold.dim_company ........................ [CREATE TABLE (5.0k rows, 2.8 MiB processed) in 4.13s]
18:52:00  32 of 45 START sql table model dl_gold.dim_trade ............................... [RUN]
18:52:01  28 of 45 OK created sql table model dl_gold.dim_customer ....................... [CREATE TABLE (21.8k rows, 10.6 MiB processed) in 4.61s]
18:52:01  33 of 45 START sql table model dl_silver.trades ................................ [RUN]
18:52:02  31 of 45 OK created sql table model dl_silver.securities ....................... [CREATE TABLE (8.0k rows, 1.8 MiB processed) in 3.61s]
18:52:02  34 of 45 START sql table model dl_gold.dim_account ............................. [RUN]
18:52:06  34 of 45 OK created sql table model dl_gold.dim_account ........................ [CREATE TABLE (37.5k rows, 6.9 MiB processed) in 4.19s]
18:52:06  35 of 45 START sql table model dl_gold.dim_security ............................ [RUN]
18:52:07  32 of 45 OK created sql table model dl_gold.dim_trade .......................... [CREATE TABLE (3.3m rows, 197.4 MiB processed) in 6.13s]
18:52:07  36 of 45 START sql table model dl_silver.watches_history ....................... [RUN]
18:52:07  30 of 45 OK created sql table model dl_silver.financials ....................... [CREATE TABLE (457.0k rows, 83.7 MiB processed) in 8.95s]
18:52:07  37 of 45 START sql table model dl_gold.fact_cash_transactions .................. [RUN]
18:52:09  33 of 45 OK created sql table model dl_silver.trades ........................... [CREATE TABLE (1.3m rows, 391.6 MiB processed) in 8.32s]
18:52:09  38 of 45 START sql table model dl_silver.holdings_history ...................... [RUN]
18:52:10  35 of 45 OK created sql table model dl_gold.dim_security ....................... [CREATE TABLE (8.0k rows, 1.6 MiB processed) in 3.57s]
18:52:10  39 of 45 START sql table model dl_gold.fact_market_history ..................... [RUN]
18:52:11  36 of 45 OK created sql table model dl_silver.watches_history .................. [CREATE TABLE (3.2m rows, 112.4 MiB processed) in 4.92s]
18:52:11  40 of 45 START sql table model dl_gold.fact_trade .............................. [RUN]
18:52:16  37 of 45 OK created sql table model dl_gold.fact_cash_transactions ............. [CREATE TABLE (767.7k rows, 96.3 MiB processed) in 8.54s]
18:52:16  41 of 45 START sql table model dl_silver.watches ............................... [RUN]
18:52:16  38 of 45 OK created sql table model dl_silver.holdings_history ................. [CREATE TABLE (1.2m rows, 135.1 MiB processed) in 7.03s]
18:52:16  42 of 45 START sql table model dl_gold.fact_cash_balances ...................... [RUN]
18:52:22  40 of 45 OK created sql table model dl_gold.fact_trade ......................... [CREATE TABLE (832.9k rows, 328.1 MiB processed) in 10.86s]
18:52:22  43 of 45 START sql table model dl_gold.fact_holdings ........................... [RUN]
18:52:23  41 of 45 OK created sql table model dl_silver.watches .......................... [CREATE TABLE (2.5m rows, 391.9 MiB processed) in 6.99s]
18:52:23  44 of 45 START test fact_trade__unique_trade ................................... [RUN]
18:52:25  44 of 45 PASS fact_trade__unique_trade ......................................... [PASS in 2.80s]
18:52:25  45 of 45 START sql table model dl_gold.fact_watches ............................ [RUN]
18:52:26  42 of 45 OK created sql table model dl_gold.fact_cash_balances ................. [CREATE TABLE (767.7k rows, 103.3 MiB processed) in 9.25s]
18:52:30  43 of 45 OK created sql table model dl_gold.fact_holdings ...................... [CREATE TABLE (5.4m rows, 236.9 MiB processed) in 7.33s]
18:52:31  45 of 45 OK created sql table model dl_gold.fact_watches ....................... [CREATE TABLE (2.5m rows, 86.6 MiB processed) in 5.72s]
18:53:11  39 of 45 OK created sql table model dl_gold.fact_market_history ................ [CREATE TABLE (760.6m rows, 455.4 MiB processed) in 61.49s]
18:53:11  
18:53:11  Finished running 44 table models, 1 test in 0 hours 1 minutes and 51.19 seconds (111.19s).
18:53:11  
18:53:11  Completed successfully
18:53:11  
18:53:11  Done. PASS=45 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=45
```
