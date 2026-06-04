{{ config(materialized='table') }}

with dates as (
    select distinct cast(reading_ts as date) as date_day
    from {{ ref('stg_readings') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_key,
    date_day,
    extract(year  from date_day) as year,
    extract(month from date_day) as month,
    extract(day   from date_day) as day,
    {{ dbt_date.day_name('date_day', short=false) }}     as weekday
from dates