{{ config(materialized='table') }}

with readings as (
    select * from {{ ref('stg_readings') }}
)

select
    r.reading_id,
    d.device_key,
    m.metric_key,
    dt.date_key,
    r.reading_ts,
    r.value
from readings r
left join {{ ref('dim_device') }} d  on r.device = d.device_name
left join {{ ref('dim_metric') }} m  on r.metric = m.metric_name
left join {{ ref('dim_date') }}   dt on cast(r.reading_ts as date) = dt.date_day