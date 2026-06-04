# Telemetry Warehouse

A dimensional data warehouse for device telemetry, built with dbt and running on both **DuckDB** (local) and **Google BigQuery** (cloud) from the same models. Raw readings are modelled into a star schema — a `fct_readings` fact table surrounded by `dim_device`, `dim_metric`, and `dim_date` dimensions — and validated with referential-integrity and data-quality tests.

Companion to the Telemetry Data Platform (dbt + Airflow on Postgres) and the telemetry ingest API.

## Warehouse targets

These models are warehouse-portable and build from the same code on two engines:

- **DuckDB** (local dev) — `dbt build`
- **Google BigQuery** (cloud) — `dbt build --target bigquery`

Portability is enforced with dbt's cross-database macros (`generate_surrogate_key`, `extract`, `dbt_date.day_name`) rather than engine-specific SQL — so switching warehouses means changing the dbt target, not rewriting the models. Every model and all 16 data tests pass on both.

## Star schema

```
              dim_device
                  |
 dim_date --- fct_readings --- dim_metric
```

`fct_readings` — one row per measurement: the `value`, plus a surrogate-key foreign key into each dimension.

`dim_device` / `dim_metric` / `dim_date` — descriptive attributes (device_type, unit, weekday, ...), each with a surrogate key.

## Stack

- dbt (dbt-core 1.11) with the **duckdb** and **bigquery** adapters
- DuckDB — embedded analytical (OLAP) warehouse: a single file, no server (local dev)
- Google BigQuery — serverless cloud data warehouse (cloud target)
- Star-schema dimensional modelling

## Models

| Model | Type | Description |
|---|---|---|
| `stg_readings` | view | Cleaned staging layer over the seeded readings |
| `dim_device` | table | Device dimension (+ derived `device_type`) |
| `dim_metric` | table | Metric dimension (+ `unit`) |
| `dim_date` | table | Date dimension (year / month / day / weekday) |
| `fct_readings` | table | Fact: one row per reading, foreign keys to all dimensions |

## Tests

16 dbt tests: `not_null` / `unique` on every surrogate key; `relationships` tests proving every fact foreign key resolves to a real dimension row (referential integrity); and data-quality checks via `dbt_expectations` and `dbt_utils` (value ranges, row-count bounds, non-negative values).

## Run it

```bash
dbt seed                    # load the sample readings
dbt build                   # build the star schema and run all tests on DuckDB
dbt build --target bigquery # ...or build and test the same models in BigQuery
```

Then query it — e.g. average reading by device type, an attribute that exists only in the dimension:

```bash
dbt show --inline "select d.device_type, round(avg(f.value),3) as avg_value from fct_readings f join dim_device d on f.device_key = d.device_key group by 1"
```

## Notes

Learning / portfolio project on a small sample dataset — the focus is the dimensional model, its tests, and warehouse portability, not data volume. The local warehouse is a DuckDB file (`dev.duckdb`), git-ignored as a build artifact since `dbt build` regenerates it. The BigQuery target runs in a free sandbox.
