with data as (
  SELECT
    f.ip_hash,
    SAFE_CAST(f.temperature as NUMERIC) as temp,
    f.long,
    f.lat,
    isFahrenheit
  from  `pandemic-tracker.public.hourly_export` as f

), agg as (
  select
    ip_hash,
    ST_GEOGPOINT(AVG(long),AVG(lat)) as geopoint,
    MAX(temp) as temp
  from data
  group by 1
)

select
  ip_hash,
  geopoint,
  temp,
  z.zip_code as zip,
  z.state_name as state,
  z.state_code as st_abbr,
  z.zip_code_geom as zip_geom
from agg
inner join  `bigquery-public-data.geo_us_boundaries.zip_codes` as z
        on ST_COVEREDBY(agg.geopoint,z.zip_code_geom  )
