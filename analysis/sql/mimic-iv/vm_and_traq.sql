WITH
  sq1 AS(/*Join ventilation and procedureevents tables and filter by InvasiveVent and tracheostomy. 2028 rows*/
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    vent.starttime AS vent_starttime,
    vent.endtime AS vent_endtime,
    DATE_DIFF(vent.endtime, vent.starttime, hour) AS vent_hours,
    event.starttime AS trach_time,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, vent.starttime, event.starttime) AS row_num /*numbers all rows sequentially*/
  FROM
    `physionet-data.mimiciv_derived.ventilation` AS vent
  INNER JOIN
    `physionet-data.mimiciv_icu.procedureevents` AS event
  USING
    (stay_id)
  WHERE
    /*filter by InvasiveVent in ventilation_status and codes 225448 (percutaneous tracheostomy) and 226237 (open tracheostomy) in icu.procedureevents*/ ventilation_status='InvasiveVent'AND (itemid=226237
      OR itemid=225448)
  ORDER BY
    row_num),
  sq2 AS (/*Creation of variable grp to identify continuous ventilation events in different rows within the same stay_id. In this dataset there are not continuous ventilation events. 2028 rows*/
  SELECT
    *,
    (SUM(CASE
          WHEN vent_starttime=prev_endtime AND stay_id=prev_stay_id THEN 0
        ELSE
        1
      END
        ) OVER (ORDER BY row_num)) AS grp
  FROM ( /*subquery to create variables prev_endtime and prev_stay_id*/
    SELECT
      *,
      LAG(vent_endtime) OVER (ORDER BY row_num) AS prev_endtime /*endtime from previous episode*/,
      LAG(stay_id) OVER (ORDER BY row_num) AS prev_stay_id /*previous stay_id*/
    FROM
      sq1
    ORDER BY
      row_num)),
  sq3 AS(/*Sum of continuous ventilation events and filter by prolonged mechanical ventilation criterion of 96h + tracheostomy at any time. 667 rows*/
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    MIN(vent_starttime) AS vent_starttime,
    MAX(vent_endtime) AS vent_endtime,
    SUM(vent_hours) AS total_vent_hours,
    MIN(trach_time) AS trach_time,
    grp
  FROM
    sq2
  GROUP BY
    subject_id,
    hadm_id,
    stay_id,
    grp
  HAVING
    total_vent_hours>=96
  ORDER BY
    grp)/*Remove stay_id duplicates, keeping the first ventilation and tracheostomy events. 488 rows*/
SELECT
  subject_id,
  hadm_id,
  stay_id,
  MIN(vent_starttime) AS vent_starttime,
  MIN(vent_endtime) AS vent_endtime,
  MIN(trach_time) AS trach_time,
  MIN(grp) AS grp
FROM
  sq3
GROUP BY
  subject_id,
  hadm_id,
  stay_id
ORDER BY
  grp
