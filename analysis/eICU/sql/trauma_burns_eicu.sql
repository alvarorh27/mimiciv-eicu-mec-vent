WITH
  sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    CASE
      WHEN (((icd9code BETWEEN 'T20' AND 'T299') OR (icd9code BETWEEN 'T30' AND 'T329') OR (icd9code BETWEEN '94%' AND '94999')) AND icd9code NOT LIKE '9S' AND icd9code NOT LIKE '9D') AND diagnosisoffset = min_diagnosisoffset THEN 1
    ELSE
    0
  END
    AS burns_min_diagnosisoffset,
    CASE
      WHEN (((icd9code BETWEEN 'T20' AND 'T299') OR (icd9code BETWEEN 'T30' AND 'T329') OR (icd9code BETWEEN '94%' AND '94999')) AND icd9code NOT LIKE '9S' AND icd9code NOT LIKE '9D') THEN 1
    ELSE
    0
  END
    AS burns_any_diagnosisoffset
  FROM (
    SELECT
      *,
      MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset
    FROM
      `physionet-data.eicu_crd.diagnosis`) )
SELECT
  patientunitstayid AS stay_id,
  burns_min_diagnosisoffset,
  burns_any_diagnosisoffset
FROM
  sq1
WHERE
  burns_min_diagnosisoffset = 1
  OR burns_any_diagnosisoffset = 1
ORDER BY
  stay_id
