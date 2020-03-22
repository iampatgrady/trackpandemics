CREATE TABLE
   public.hourly_export (
     timestamp TIMESTAMP,
     receiveTimestamp TIMESTAMP,
     requestSize INT64,
     responseSize INT64,
     ip_hash BYTES,
     cacheHit BOOL,
     isFahrenheit BOOL,
     temperature STRING,
     heartrate STRING,
     oxygen_saturation STRING,
     long NUMERIC,
     lat NUMERIC,
     geopoint GEOGRAPHY
   )
 PARTITION BY
   DATE(timestamp)
