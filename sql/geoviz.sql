
--
select
	ip_hash,
	MAX(SAFE_CAST(temperature as NUMERIC)) as temp,
	MAX(SAFE_CAST(heartrate as NUMERIC)) as heart,
	ST_GEOGPOINT(AVG(long),AVG(lat)) as geopoint,
from `pandemic-tracker.public.hourly_export`
where lat != 0 AND isFahrenheit
group by ip_hash
having temp > 85
UNION ALL
select
	ip_hash,
	MAX((SAFE_CAST(temperature as NUMERIC)* 9/5)+32) as temp, --convert celsius to fahrenheit
	MAX(SAFE_CAST(heartrate as NUMERIC)) as heart,
	ST_GEOGPOINT(AVG(long),AVG(lat)) as geopoint,
from `pandemic-tracker.public.hourly_export`
where lat != 0 and not isFahrenheit
group by ip_hash
having temp < 50;

--
