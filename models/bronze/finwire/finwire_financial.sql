
with s1 as (
    select 
        *,
        SAFE_CAST(co_name_or_cik as numeric) as try_cik
    from {{ source("finwire", "fin") }}
)
select 
    pts,
    cast(year as numeric) as year,
    cast(quarter as numeric) as quarter,
    parse_date('%Y%m%d', cast(quarter_start_date as string)) as quarter_start_date,
    parse_date('%Y%m%d', cast(posting_date as string)) as posting_date,
    cast(revenue as float64) as revenue,
    cast(earnings as float64) as earnings,
    cast(eps as float64) as eps,
    cast(diluted_eps as float64) as diluted_eps,
    cast(margin as float64) as margin,
    cast(inventory as float64) as inventory,
    cast(assets as float64) as assets,
    cast(liabilities as float64) as liabilities,
    cast(sh_out as numeric) as sh_out,
    cast(diluted_sh_out as numeric) as diluted_sh_out,
    try_cik cik,
    case when try_cik is null then co_name_or_cik else null end company_name
from s1