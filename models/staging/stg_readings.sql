{{ config(materialized='view') }}

with source as (
    select * from {{ ref('readings') }}
)

select
    id                     as reading_id,
    device,
    metric,
    value,
    cast(ts as timestamp)  as reading_ts
from source