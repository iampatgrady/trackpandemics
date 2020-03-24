with data as (
 SELECT
   f.ip_hash,
   SAFE_CAST(f.temperature as NUMERIC) as temp,
   f.long,
   f.lat,
   f.zipcode
 from  `pandemic-tracker.public.hourly_export` as f
 where isFahrenheit AND SAFE_CAST(f.temperature as NUMERIC) BETWEEN 90 and 110
 UNION ALL
  SELECT
   f.ip_hash,
   (SAFE_CAST(f.temperature as NUMERIC) * 9/5)+32 as temp,
   f.long,
   f.lat,
   f.zipcode
 from  `pandemic-tracker.public.hourly_export` as f
 where not isFahrenheit AND SAFE_CAST(f.temperature as NUMERIC) BETWEEN 32 and 43

), user_agg as (
 select
   ip_hash,
   CASE WHEN zipcode != "" THEN
    ( SELECT internal_point_geom from `bigquery-public-data.geo_us_boundaries.zip_codes` where zip_code = zipcode)
   ELSE ST_GEOGPOINT(AVG(long),AVG(lat))
   END as geopoint,
   AVG(temp) as temp
 from data
 group by ip_hash,zipcode
), county_agg as (
  select
   c.geo_id as county_id,
   c.county_name as county,
   s.state as st_abbr,

   AVG(ST_X(geopoint)) as long,
   AVG(ST_Y(geopoint)) as lat,
   AVG(temp) as temp,
   COUNT(*) records

  from user_agg
  inner join  `bigquery-public-data.geo_us_boundaries.counties` as c
         on ST_COVEREDBY(user_agg.geopoint,c.county_geom )
  inner join `bigquery-public-data.geo_us_boundaries.states` as s
        on s.state_fips_code = c.state_fips_code
  group by 1,2,3 )

select county_agg.* except(long,lat,county_id),
  c.county_geom

from county_agg INNER JOIN `bigquery-public-data.geo_us_boundaries.counties` as c
         on c.geo_id = county_id
