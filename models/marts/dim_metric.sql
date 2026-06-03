{{ config(materialized='table') }}

with metrics as (
    select distinct metric from {{ ref('stg_readings') }}
)

select
    md5(metric) as metric_key,
    metric      as metric_name,
    case metric
        when 'temperature' then 'degC'
        when 'vibration'   then 'mm/s'
        else null
    end         as unit
from metrics