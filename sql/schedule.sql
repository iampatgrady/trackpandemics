MERGE public.hourly_export H
USING
(
  WITH
    raw_data AS (
      SELECT
        timestamp,
        receiveTimestamp,
        IFNULL(NULLIF(SPLIT(SPLIT(SPLIT(httpRequest.requestUrl, "?")[SAFE_OFFSET(1)] ,"&")[SAFE_OFFSET(0)],"=")[SAFE_OFFSET(1)],""),"0,0") as location,
        httpRequest.requestSize,
        httpRequest.responseSize,
        SHA256(concat(httpRequest.remoteIp,"<salt>")) AS ip_hash,
        httpRequest.cacheHit,
        CAST(SPLIT(SPLIT(SPLIT(httpRequest.requestUrl, "?")[SAFE_OFFSET(1)],"&")[SAFE_OFFSET(1)],"=")[SAFE_OFFSET(1)] AS BOOL) AS isFahrenheit,
        SPLIT(SPLIT(SPLIT(httpRequest.requestUrl, "?")[SAFE_OFFSET(1)],"&")[SAFE_OFFSET(2)],"=")[SAFE_OFFSET (1)] AS temperature,
        SPLIT(SPLIT(SPLIT(httpRequest.requestUrl, "?")[SAFE_OFFSET(1)],"&")[SAFE_OFFSET(3)],"=")[SAFE_OFFSET(1)] AS heartrate,
        SPLIT(SPLIT(SPLIT(httpRequest.requestUrl, "?")[SAFE_OFFSET(1)],"&")[SAFE_OFFSET(4)],"=")[SAFE_OFFSET(1)] AS oxygen_saturation
      FROM
        `pandemic-tracker.pandemics.requests` ),
    data AS (
      SELECT * except (location),
        SAFE_CAST(SPLIT(location,",")[SAFE_OFFSET(1)] AS NUMERIC) as long,
        SAFE_CAST(SPLIT(location,",")[SAFE_OFFSET(0)] AS NUMERIC) as lat,
      FROM raw_data )
  SELECT
    * ,
    ST_GeogPoint(long, lat) as geopoint
  FROM
    data
) N
ON H.timestamp = N.timestamp AND H.ip_hash = N.ip_hash
WHEN NOT MATCHED THEN
    INSERT (timestamp, receiveTimestamp, requestSize, responseSize, ip_hash, cacheHit, isFahrenheit, temperature, heartrate, oxygen_saturation, long, lat, geopoint)
        VALUES (timestamp, receiveTimestamp, requestSize, responseSize, ip_hash, cacheHit, isFahrenheit, temperature, heartrate, oxygen_saturation, long, lat, geopoint)
