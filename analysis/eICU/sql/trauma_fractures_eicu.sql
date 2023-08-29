WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    CASE
      WHEN (icd9code LIKE 'S12____' OR icd9code LIKE 'S32____' OR icd9code LIKE 'S52____' OR icd9code LIKE 'S72____' OR icd9code LIKE 'S62____' OR icd9code LIKE 'S42____' OR icd9code LIKE 'S22____' OR icd9code LIKE 'S398___' OR icd9code LIKE 'S92____' OR icd9code LIKE 'S82____' OR icd9code LIKE 'S591___' OR icd9code LIKE 'S99____') AND (icd9code LIKE '______A' OR icd9code LIKE '______B' OR icd9code LIKE '______C') OR (icd9code BETWEEN '805' AND '82999') AND diagnosisoffset = min_diagnosisoffset
      THEN 1
      ELSE 0
    END AS fractures_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S12____' OR icd9code LIKE 'S32____' OR icd9code LIKE 'S52____' OR icd9code LIKE 'S72____' OR icd9code LIKE 'S62____' OR icd9code LIKE 'S42____' OR icd9code LIKE 'S22____' OR icd9code LIKE 'S398___' OR icd9code LIKE 'S92____' OR icd9code LIKE 'S82____' OR icd9code LIKE 'S591___' OR icd9code LIKE 'S99____') AND (icd9code LIKE '______A' OR icd9code LIKE '______B' OR icd9code LIKE '______C') OR (icd9code BETWEEN '805' AND '82999')
      THEN 1
      ELSE 0
    END AS fractures_any_diagnosisoffset
  FROM (
    SELECT * ,MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset
    FROM
    `physionet-data.eicu_crd.diagnosis`)
)
SELECT
    patientunitstayid AS stay_id,
    fractures_min_diagnosisoffset,
    fractures_any_diagnosisoffset
FROM sq1
ORDER BY patientunitstayid ASC;
