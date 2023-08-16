WITH respchart AS (
	SELECT *
	FROM `physionet-data.eicu_crd.respiratorycharting`
)

, nursechart AS (
	SELECT *
	FROM `physionet-data.eicu_crd.nursecharting`
)

, pat AS (
	SELECT *
	FROM `physionet-data.eicu_crd.patient`
)


-- Extract the type of oxygen therapy.
-- The categories are invasive ventilation,
-- noninvasive ventilation, and supplemental oxygen.
-- `oxygen_therapy_type = -1` indicates oxygen therapy,
-- i.e. more oxygen than in room air is administered.
, ventsettings0 AS (
	SELECT patientunitstayid AS icustay_id
		, charttime
		, CASE

			-- Invasive ventilation
			WHEN
				string IN (
					'plateau pressure',
					'postion at lip',
					'position at lip',
					'pressure control'
				)
				OR string LIKE '%set vt%'
				OR string LIKE '%sputum%'
				OR string LIKE '%rsbi%'
				OR string LIKE '%tube%'
				OR string LIKE '%ett%'
				OR string LIKE '%endotracheal%'
				OR string LIKE '%tracheal suctioning%'
				OR string LIKE '%tracheostomy%'
				OR string LIKE '%reintubation%'
				OR string LIKE '%assist controlled%'
				OR string LIKE '%volume controlled%'
				OR string LIKE '%pressure controlled%'
				OR string LIKE '%trach collar%'
			THEN 4

			-- Noninvasive ventilation
			WHEN
				string IN (
					'bi-pap',
					'ambubag'
				)
				OR string LIKE '%ipap%'
				OR string LIKE '%niv%'
				OR string LIKE '%epap%'
				OR string LIKE '%mask leak%'
				OR string LIKE '%volume assured%'
				OR string LIKE '%non-invasive ventilation%'
				OR string LIKE '%cpap%'
			THEN 3

			-- Either invasive or noninvasive ventilation:
			WHEN
				string IN (
					'flowtrigger',
					'peep',
					'tv/kg ibw',
					'mean airway pressure',
					'peak insp. pressure',
					'exhaled mv',
					'exhaled tv (machine)',
					'exhaled tv (patient)',
					'flow sensitivity',
					'peak flow',
					'f total',
					'pressure to trigger ps',
					'adult con setting set rr',
					'adult con setting set vt',
					'vti',
					'exhaled vt',
					'adult con alarms hi press alarm',
					'mve',
					'respiratory phase',
					'inspiratory pressure, set',
					'a1: high exhaled vt',
					'set fraction of inspired oxygen (fio2)',
					'insp flow (l/min)',
					'adult con setting spont exp vt',
					'spont tv',
					'pulse ox results vt',
					'vt spontaneous (ml)',
					'peak pressure',
					'ltv1200',
					'tc'
				)
				OR (
					string LIKE '%vent%'
					AND NOT string LIKE '%hyperventilat%'
				)
				OR string LIKE '%tidal%'
				OR string LIKE '%flow rate%'
				OR string LIKE '%minute volume%'
				OR string LIKE '%leak%'
				OR string LIKE '%pressure support%'
				OR string LIKE '%peep%'
				OR string LIKE '%tidal volume%'
			THEN 2

			-- Supplemental oxygen:
			WHEN
				string IN (
					't-piece',
					'blow-by',
					'oxyhood',
					'nc',
					'oxymizer',
					'hfnc',
					'oximizer',
					'high flow',
					'oxymask',
					'nch',
					'hi flow',
					'hiflow',
					'hhfnc',
					'nasal canula',
					'face tent',
					'high flow mask',
					'aerosol mask',
					'venturi mask',
					'cool aerosol mask',
					'simple mask',
					'face mask'
				)
				OR string LIKE '%nasal cannula%'
				OR string LIKE '%non-rebreather%'
				OR string LIKE '%nasal mask%'
				OR string LIKE '%face tent%'
			THEN 1

			-- Oxygen therapy but unknown what type:
			WHEN
				string IN (
					'pressure support',
					'rr spont',
					'ps',
					'insp cycle off (%)',
					'trach mask/collar'
				)
				OR string LIKE '%spontaneous%'
				OR string LIKE '%oxygen therapy%'
			THEN 0

			-- Supplemental oxygen therapy,
			-- i.e. more oxygen than in room air is administered.
			WHEN
				string IN (
					'lpm o2'
				)
			THEN -1

			ELSE NULL

		END AS oxygen_therapy_type
		, activeUponDischarge
	FROM (

		SELECT patientunitstayid
			, nursingChartOffset AS charttime
			, LOWER(nursingchartvalue) AS string
			, NULL AS activeUponDischarge
		FROM nursechart

		UNION ALL

		SELECT patientunitstayid
			, respchartoffset AS charttime
			, LOWER(respchartvaluelabel) AS string
			, NULL AS activeUponDischarge
		FROM respchart

		UNION ALL

		-- Oxygen device from respchart
		SELECT patientunitstayid
			, respchartoffset AS charttime
			, LOWER(respchartvalue) AS string
			, NULL AS activeUponDischarge
		FROM respchart
		WHERE LOWER(respchartvaluelabel) IN (
			'o2 device',
			'respiratory device',
			'ventilator type',
			'oxygen delivery method'
    	)

    	UNION ALL

    	-- The treatment table also contains info on oxygen therapy.
    	SELECT patientunitstayid
			, treatmentoffset AS charttime
			, LOWER(treatmentstring) AS string
			, activeUponDischarge
		FROM `physionet-data.eicu_crd.treatment`
	)
	WHERE charttime >= -60

	UNION ALL

	-- The following indicates oxygen therapy but unclear what type.
	SELECT patientunitstayid AS icustay_id
		, nursingchartoffset AS charttime
		, -1 AS oxygen_therapy_type
		, NULL AS activeUponDischarge
	FROM nursechart
	WHERE nursingchartoffset >= -60
		AND nursingchartcelltypevallabel = 'O2 L/%'
		AND SAFE_CAST(nursingChartValue AS INT64) > 0
		AND SAFE_CAST(nursingChartValue AS INT64) <= 100

	UNION ALL

	-- fraction of inspired oxygen (fiO2) outside of [.2, .22] and [20, 22]
	-- indicates oxygen therapy.
	SELECT patientunitstayid AS icustay_id
		, respchartoffset AS charttime
		, CASE
			WHEN SAFE_CAST(respchartvalue AS FLOAT64) <= 1 AND SAFE_CAST(respchartvalue AS FLOAT64) > .22 THEN -1
			WHEN SAFE_CAST(respchartvalue AS FLOAT64) > 22 THEN -1
			ELSE 0
		END AS oxygen_therapy_type
		, NULL AS activeUponDischarge
	FROM respchart
	WHERE respchartoffset >= -60
		AND LOWER(respchartvaluelabel) IN ('fio2', 'fio2 (%)')
		AND (
			SAFE_CAST(respchartvalue AS FLOAT64) < .2
			OR (
				SAFE_CAST(respchartvalue AS FLOAT64) > .22
				AND SAFE_CAST(respchartvalue AS FLOAT64) < 20
			)
			OR SAFE_CAST(respchartvalue AS FLOAT64) > 22
		)
)


-- Ensure charttime is unique
, ventsettings AS (
	SELECT icustay_id
		, charttime
		, MAX(oxygen_therapy_type) AS oxygen_therapy_type
		, MAX(activeUponDischarge) AS activeUponDischarge
		, COUNT(CASE WHEN oxygen_therapy_type = -1 THEN 1 END) > 0 AS supp_oxygen
	FROM ventsettings0
	-- If oxygen_therapy_type is NULL,
	-- then the record does not correspond with oxygen therapy.
	WHERE oxygen_therapy_type IS NOT NULL
	GROUP BY icustay_id, charttime
)


, vd0 as
(
  select
    *
    -- this carries over the previous charttime which had an oxygen therapy event
    , LAG(CHARTTIME, 1) OVER (partition by icustay_id order by charttime)
	as charttime_lag
  from ventsettings
)
, vd1 as
(
  select
      icustay_id
      , charttime
      , oxygen_therapy_type
      , activeUponDischarge
      , supp_oxygen

      -- If the time since the last oxygen therapy event is more than 24 hours,
	-- we consider that ventilation had ended in between.
	-- That is, the next ventilation record corresponds to a new ventilation session.
      , CASE
		WHEN charttime - charttime_lag > 24*60 THEN 1
		WHEN charttime_lag IS NULL THEN 1 -- No lag can be computed for the very first record
		ELSE 0
	END AS newvent
  -- use the staging table with only oxygen therapy records from chart events
  FROM vd0
)
, vd2 as
(
  select vd1.*
  -- create a cumulative sum of the instances of new ventilation
  -- this results in a monotonic integer assigned to each instance of ventilation
  , SUM( newvent )
      OVER ( partition by icustay_id order by charttime )
    as ventnum
  from vd1
)

--- now we convert CHARTTIME of ventilator settings into durations
-- create the durations for each oxygen therapy instance
-- We only keep the first oxygen therapy instance
, vd3 AS
(
	SELECT icustay_id
		, ventnum
		, CASE
			-- If activeUponDischarge, then the unit discharge time is vent_end
			WHEN (
				MAX(activeUponDischarge)
				-- vent_end cannot be later than the unit discharge time.
				-- However, unitdischargeoffset often seems too low.
				-- So, we only use it if it yields and extension of the
				-- ventilation time from ventsettings.
				AND MAX(charttime)+60 < MAX(pat.unitdischargeoffset)
			)
			THEN MAX(pat.unitdischargeoffset)
			-- End time is currently a charting time
			-- Since these are usually recorded hourly, ventilation is actually longer.
			-- We therefore add 60 minutes to the last time.
			ELSE MAX(charttime)+60
		END AS vent_end
		, MIN(charttime) AS vent_start
		, MAX(oxygen_therapy_type) AS oxygen_therapy_type
		, MAX(supp_oxygen) AS supp_oxygen
	FROM vd2
		LEFT JOIN pat
		ON vd2.icustay_id = pat.patientunitstayid
	GROUP BY icustay_id, ventnum
),
    vent_table AS(
    select vd3.*
	-- vent_duration is in hours.
	, (vent_end - vent_start) / 60 AS vent_duration
	, MIN(vent_start) OVER(PARTITION BY icustay_id) AS vent_start_first
from vd3),


    sq1 AS(/*New code begins here. Filter by invasive mechanical ventilation. 47857 rows*/
    SELECT
      *,
      PARSE_TIMESTAMP ('%Y-%m-%d %H:%M:%S', '2023-01-01 ' || unitadmittime24) AS icu_admit_time /*Assign the unit admit day to 2023-01-01 to operate with timestamp format*/
    FROM
      vent_table
    INNER JOIN
      `physionet-data.eicu_crd.patient` AS patient_table
    ON
      vent_table.icustay_id = patient_table.patientunitstayid
    WHERE
      oxygen_therapy_type=4),
    sq2 AS(/*Create ventilation times variables. 47857 rows*/
    SELECT
      uniquepid AS subject_id,
      patienthealthsystemstayid AS hadm_id,
      icustay_id AS stay_id,
      icu_admit_time,
      unitvisitnumber,
      ventnum,
      vent_start,
      starttime,
      EXTRACT (DATE
      FROM
        starttime) AS startday,
      vent_end,
      endtime,
      EXTRACT (DATE
      FROM
        endtime) AS endday,
      vent_duration AS hours_of_vent
    FROM (
      SELECT
        *,
        TIMESTAMP_ADD(icu_admit_time, INTERVAL vent_start MINUTE) AS starttime /*Add the minutes of ventilation start to icu_admit_time*/,
        TIMESTAMP_ADD(icu_admit_time, INTERVAL vent_end MINUTE) AS endtime /*Add the minutes of ventilation end to icu_admit_time*/
      FROM
        sq1)
    ORDER BY
      subject_id,
      hadm_id,
      unitvisitnumber,
      ventnum),
    sq3 AS(/*hours OF ventilation grouped BY the same startday. 47857 ROWS grouped BY stay_id
      AND startday*/
    SELECT
      subject_id,
      hadm_id,
      stay_id,
      MIN(starttime) AS starttime,
      startday,
      MAX(endtime) AS endtime,
      MAX(endday) AS endday,
      SUM(hours_of_vent) AS hours_of_vent
    FROM
      sq2
    GROUP BY
      subject_id,
      hadm_id,
      stay_id,
      startday
    ORDER BY
      subject_id,
      startday),
    sq4 AS(/*Filter BY hours_of_vent superior TO 6 hours. 44632 ROWS*/
    SELECT
      *
    FROM
      sq3
    WHERE
      hours_of_vent>=6),
    sq5 AS(/*Creation of variable row_number assigning a numeric order to all rows. 44632 rows*/
    SELECT
      *,
      ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, stay_id, startday) AS row_num
    FROM
      sq4
    ORDER BY
      subject_id,
      startday),
    sq6 AS(/*Creation of new variables with LAG and LEAD functions. 44632 rows*/
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
      sq5
    ORDER BY
      row_num),
    sq7 AS(/*Creation of variable grp assigning the same number for vent episodes>6hours on consecutive days. 44632 rows*/
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
      sq6),
    sq8 AS (/*Grouped by same grp number. 43623 rows*/
    SELECT
      subject_id,
      hadm_id,
      stay_id,
      MIN(starttime) AS starttime,
      MAX (endtime) AS endtime,
      ROUND(SUM(hours_of_vent),2) AS consecutive_vm_hours,
      grp
    FROM
      sq7
    GROUP BY
      subject_id,
      hadm_id,
      stay_id,
      grp
    ORDER BY
      grp),
    sq9 AS(/*ranking episodes from each stay_id to select those with the highest consecutive_vm_days and, if there is a tie, with the highest consecutive_vm_hours. 43623 rows*/
    SELECT
      *,
      DENSE_RANK() OVER (PARTITION BY stay_id ORDER BY consecutive_vm_days DESC, consecutive_vm_hours DESC, starttime) AS ranking
    FROM (
      SELECT
        *,
        DATE_DIFF(endtime, starttime, day)+1 AS consecutive_vm_days /*to have full days we add 1 to the variable*/
      FROM
        sq8)
    ORDER BY
      subject_id,
      hadm_id,
      ranking) /*filtering by the longest episode. 42586 rows*/
  SELECT
    stay_id, 
    starttime, 
    endtime, 
    consecutive_vm_days
  FROM
    sq9
  WHERE
    ranking=1
