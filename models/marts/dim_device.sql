{{ config(materialized='table') }}

with devices as (
    select distinct device from {{ ref('stg_readings') }}
)

select
    md5(device) as device_key,
    device      as device_name,
    case
        when device like 'pump%'       then 'pump'
        when device like 'compressor%' then 'compressor'
        else 'other'
    end         as device_type
from devices