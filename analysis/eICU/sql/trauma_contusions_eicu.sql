WITH
  sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    CASE
      WHEN (icd9code LIKE 'S10____' OR icd9code LIKE 'S00____' OR icd9code LIKE 'S05____' OR icd9code LIKE 'S20____' OR icd9code LIKE 'S40____' OR icd9code LIKE 'S50____' OR icd9code LIKE 'S60____' OR icd9code LIKE 'S70____' OR icd9code LIKE 'S80____' OR icd9code LIKE 'S90____' OR icd9code BETWEEN '92%' AND '92499') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S') AND diagnosisoffset = min_diagnosisoffset THEN 1
    ELSE
    0
  END
    AS contusion_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S10____' OR icd9code LIKE 'S00____' OR icd9code LIKE 'S05____' OR icd9code LIKE 'S20____' OR icd9code LIKE 'S40____' OR icd9code LIKE 'S50____' OR icd9code LIKE 'S60____' OR icd9code LIKE 'S70____' OR icd9code LIKE 'S80____' OR icd9code LIKE 'S90____' OR icd9code BETWEEN '92%' AND '92499') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S') THEN 1
    ELSE
    0
  END
    AS contusion_any_diagnosisoffset
  FROM (
    SELECT
      *,
      MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset
    FROM
      `physionet-data.eicu_crd.diagnosis`) )
SELECT
  patientunitstayid AS stay_id,
  contusion_min_diagnosisoffset,
  contusion_any_diagnosisoffset
FROM
  sq1
WHERE
  contusion_min_diagnosisoffset = 1
  OR contusion_any_diagnosisoffset = 1
ORDER BY
  stay_id
