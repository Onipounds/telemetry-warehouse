{{ config(materialized='table') }}

with dates as (
    select distinct cast(reading_ts as date) as date_day
    from {{ ref('stg_readings') }}
)

select
    md5(cast(date_day as varchar)) as date_key,
    date_day,
    year(date_day)                 as year,
    month(date_day)                as month,
    day(date_day)                  as day,
    dayname(date_day)              as weekday
from dates