# Telemetry Warehouse

A dimensional data warehouse for device telemetry, built with **dbt** on **DuckDB**. Raw readings are modelled into a **star schema** — a `fct_readings` fact table surrounded by `dim_device`, `dim_metric`, and `dim_date` dimensions — and validated with referential-integrity tests.

Companion to the [Telemetry Data Platform](https://github.com/Onipounds/telemetry-data-platform) (dbt + Airflow on Postgres) and the [telemetry ingest API](https://github.com/Onipounds/telemetry-api).

## Star schema

```
              dim_device
                  |
 dim_date --- fct_readings --- dim_metric
```

- **fct_readings** — one row per measurement: the `value`, plus a surrogate-key foreign key into each dimension.
- **dim_device / dim_metric / dim_date** — descriptive attributes (device_type, unit, weekday, ...), each with an md5 surrogate key.

## Stack

- **dbt** (dbt-core 1.11, duckdb adapter)
- **DuckDB** — embedded analytical (OLAP) warehouse: a single file, no server
- Star-schema dimensional modelling

## Models

| Model | Type | Description |
|-------|------|-------------|
| `stg_readings` | view | Cleaned staging layer over the seeded readings |
| `dim_device` | table | Device dimension (+ derived `device_type`) |
| `dim_metric` | table | Metric dimension (+ `unit`) |
| `dim_date` | table | Date dimension (year / month / day / weekday) |
| `fct_readings` | table | Fact: one row per reading, foreign keys to all dimensions |

## Tests

12 dbt tests: `not_null` / `unique` on every surrogate key, plus `relationships` tests proving every fact foreign key resolves to a real dimension row — i.e. referential integrity.

## Run it

```bash
dbt seed     # load the sample readings into DuckDB
dbt build    # build the star schema and run all tests
```

Then query it — e.g. average reading by device type, an attribute that exists only in the dimension:

```bash
dbt show --inline "select d.device_type, round(avg(f.value),3) as avg_value from fct_readings f join dim_device d on f.device_key = d.device_key group by 1"
```

## Notes

Learning / portfolio project on a small sample dataset — the focus is the dimensional model and its tests, not data volume. The warehouse itself is a local DuckDB file (`dev.duckdb`), git-ignored as a build artifact since `dbt build` regenerates it.
