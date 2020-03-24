# Welcome to the Track Pandemics Project
https://www.trackpandemics.com  

## Project Overview
Project run by Pat Grady who is currently seeking contributors to the project. All ideas and feedback are welcome.  

## Making Submissions
Submit vitals for each member of your household. Ideally, this would happen daily for each participant.

### Batch Submissions:
Will soon have support for batch submissions. Prior to making batch submissions we need to be able to collect the GMT +0 EPOCH timestamp from the reading. This feature is currently not supported.

### Submitting via HTTPS GET
The endpoint that receives data is https://www.trackpandemics.com/p.gif  

This endpoint [has a logs router](https://cloud.google.com/logging/docs/routing/overview) connected to a BigQuery sink.  

The following demonstrates how to construct a submission-pixel with the appropriate URI parameters:
  ```javascript
  var elem = document.createElement("img");
  elem.setAttribute("src",
        "https://www.trackpandemics.com/p.gif?"
        + "loc=" + data.gps   // STRING   "lat,long"
        + "&uom=" + data.uom  // BOOLEAN  true
        + "&temp=" + d.temp   // DECIMAL  98.6
        + "&zip=" + d.zip     // STRING   "06001"
  );
  elem.setAttribute("height", "1");
  elem.setAttribute("width", "1");
  document.body.appendChild(elem);
  ```

## Data Collection
This project uses a serverless collection architecture following this pattern:  
https://cloud.google.com/solutions/serverless-pixel-tracking  

The data is collected anonymously and the location of the data is [restricted to 11-square kilometer fidelity (wiki:Degrees)](https://en.wikipedia.org/wiki/Decimal_degrees). This is about as accurate as a large city or district.

## Public Data
The data is warehoused using [Google Cloud BigQuery](https://cloud.google.com/bigquery). The tables storing the data are updated hourly with new submissions.

### Accessing Public Data:
 - You must have a Google Account
 - Visit
  - [https://console.cloud.google.com/bigquery?p=pandemic-tracker](https://console.cloud.google.com/bigquery?p=pandemic-tracker&d=public&t=hourly_export&page=table)
  - First time users:
    - Agree to terms
    - Create a project
 - Pin `pandemic-tracker` project for future reference
 - Select `pandemic-tracker:public.hourly_export` then `QUERY TABLE`
```SQL
SELECT SAFE_CAST(temperature as NUMERIC) as temp
FROM `pandemic-tracker.public.hourly_export`
WHERE DATE(timestamp) = "2020-03-23" LIMIT 10
```
