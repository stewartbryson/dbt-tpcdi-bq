with s1 as (
    select *,
    SAFE_CAST(co_name_or_cik AS INT64) as try_cik
    from {{ source("finwire", "sec") }}
)
select  
    pts,
    symbol,
    issue_type,
    status,
    name,
    ex_id,
    CAST(sh_out AS INT64) as sh_out,
    PARSE_DATE('%Y%m%d', CAST(first_trade_date AS STRING)) as first_trade_date,
    PARSE_DATE('%Y%m%d', CAST(first_exchange_date AS STRING)) as first_exchange_date,
    CAST(dividend AS FLOAT64) as dividend,
    try_cik cik,
    CASE WHEN try_cik IS NULL THEN co_name_or_cik ELSE NULL END company_name
from s1