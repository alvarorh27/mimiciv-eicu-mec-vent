  /*Table with the total consecutive or non-consecutive days of mechanical ventilation for six or more hours per day for each stay_id. 23114 rows*/
WITH
  sq1 AS(/*Filter OF InvasiveVent IN ventilation_status. FROM 111300 to 34805 ROWS*/
  SELECT
    stay_id,
    EXTRACT (DATE
    FROM
      starttime) AS startday,
    starttime,
    EXTRACT (DATE
    FROM
      endtime) AS endday,
    endtime,
    ROUND(((DATE_DIFF(endtime, starttime, minute))/60),2) AS total_vm_hours
  FROM
    `physionet-data.mimiciv_derived.ventilation`
  WHERE
    ventilation_status='InvasiveVent'),
  sq2 AS(/* hours OF ventilation grouped BY the stay_id and startday, filtered >6 hours. 34331 ROWS*/
  SELECT
    stay_id,
    startday,
    MIN(starttime) AS starttime,
    MAX(endday) AS endday,
    MAX(endtime) AS endtime,
    SUM(total_vm_hours) AS total_vm_hours
  FROM
    sq1
  GROUP BY
    stay_id,
    startday
  HAVING
    total_vm_hours>=6
  ORDER BY
    stay_id,
    startday),
  sq3 AS(/*group by stay_id. 23114 rows*/
  SELECT
    stay_id,
    MIN(startday) AS startday,
    MIN(starttime) AS starttime,
    MAX(endday) AS endday,
    MAX(endtime) AS endtime,
    SUM(total_vm_hours) AS total_vm_hours,
    SUM(total_vm_days) AS total_vm_days
  FROM (
    SELECT
      *,
      DATE_DIFF(endtime, starttime, day)+1 AS total_vm_days /*to have full days we add 1 to the variable*/
    FROM
      sq2)
  GROUP BY
    stay_id) /*JOIN of icustays table. 23114 rows*/
SELECT
  subject_id,
  hadm_id,
  stay_id,
  startday,
  starttime,
  endday,
  endtime,
  total_vm_hours,
  total_vm_days
FROM
  sq3
INNER JOIN
  `physionet-data.mimiciv_icu.icustays`
USING
  (stay_id)
ORDER BY
  subject_id,
  startday
