/*Table with the longest MV episode (consecutive days of mechanical ventilation for six or more hours per day) for each stay_id. 23114 rows*/
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
    ROUND(((DATE_DIFF(endtime, starttime, minute))/60),2) AS hours_of_vent
  FROM
    `physionet-data.mimiciv_derived.ventilation`
  WHERE
    ventilation_status='InvasiveVent'),
  sq2 AS(/*hours OF ventilation grouped BY the same startday. 34331 ROWS grouped BY stay_id
    AND startday*/
  SELECT
    stay_id,
    startday,
    MIN(starttime) AS starttime,
    MAX(endday) AS endday,
    MAX(endtime) AS endtime,
    SUM(hours_of_vent) AS hours_of_vent
  FROM
    sq1
  GROUP BY
    stay_id,
    startday
  ORDER BY
    stay_id,
    startday),
  sq3 AS( --Filter BY hours_of_vent superior TO 6 hours. 29354 ROWS;
  SELECT
    *
  FROM
    sq2
  WHERE
    hours_of_vent>=6),
  sq4 AS(/*Creation of variable row_number and JOIN of icustays table. 29354 rows*/
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    startday,
    starttime,
    endday,
    endtime,
    hours_of_vent,
    ROW_NUMBER() OVER (ORDER BY subject_id, startday) AS row_num
  FROM
    sq3
  INNER JOIN
    `physionet-data.mimiciv_icu.icustays`
  USING
    (stay_id)
  ORDER BY
    subject_id,
    startday),
  sq5 AS(/*Creation of new variables with LAG and LEAD functions. 29354 rows*/
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    LAG(stay_id,1) OVER (ORDER BY row_num) AS prev_stay_id,
    starttime,
    startday,
    endtime,
    endday,
    LEAD (startday,1) OVER (PARTITION BY stay_id ORDER BY row_num) AS nextday_startepisode /*only appears when having the same stay_id*/,
    LAG (endday,1) OVER (PARTITION BY stay_id ORDER BY row_num) AS previousday_endepisode /*only appears when having the same stay_id*/,
    hours_of_vent,
    row_num
  FROM
    sq4
  ORDER BY
    row_num),
  sq6 AS(/*Creation of variable grp with groups of episodes>6hours on consecutive days. 29354 rows*/
  SELECT
    *,
    SUM(
      CASE
        WHEN (((nextday_startepisode IS NOT NULL AND previousday_endepisode IS NOT NULL) OR (DATE_DIFF(startday,previousday_endepisode,day) <= 1 AND nextday_startepisode IS NULL)) AND DATE_DIFF(startday,previousday_endepisode, day) <=1 AND (prev_stay_id = stay_id)) THEN 0
      ELSE
      1
    END
      ) OVER (ORDER BY row_num) AS grp
  FROM
    sq5),
  sq7 AS (/*Grouped by same grp number. 25247 rows*/
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    MIN(starttime) AS starttime,
    MAX (endtime) AS endtime,
    ROUND(SUM(hours_of_vent),2) AS consecutive_vm_hours,
    grp
  FROM
    sq6
  GROUP BY
    subject_id,
    hadm_id,
    stay_id,
    grp
  ORDER BY
    grp),
  sq8 AS(/*ranking episodes from each stay_id to select those with the highest consecutive_vm_days and, if there is a tie, with the highest consecutive_vm_hours. 25247 rows*/
  SELECT
    *,
    DENSE_RANK() OVER (PARTITION BY stay_id ORDER BY consecutive_vm_days DESC, consecutive_vm_hours DESC, starttime) AS ranking
  FROM (
    SELECT
      *,
      DATE_DIFF(endtime, starttime, day)+1 AS consecutive_vm_days /*to have full days we add 1 to the variable*/
    FROM
      sq7)
  ORDER BY
    subject_id,
    hadm_id,
    ranking) /*filtering by the longest episode. 23114 rows*/
SELECT
  *
FROM
  sq8
WHERE
  ranking=1
