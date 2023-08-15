WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S10____' OR icd9code LIKE 'S00____' OR icd9code LIKE 'S05____' OR icd9code LIKE 'S20____' OR icd9code LIKE 'S40____' OR icd9code LIKE 'S50____' OR icd9code LIKE 'S60____' OR icd9code LIKE 'S70____' OR icd9code LIKE 'S80____' OR icd9code LIKE 'S90____' OR icd9code BETWEEN '92%' AND '92499') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S')
      THEN 'YES'
      ELSE 'NO'
    END AS contusion_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S10____' OR icd9code LIKE 'S00____' OR icd9code LIKE 'S05____' OR icd9code LIKE 'S20____' OR icd9code LIKE 'S40____' OR icd9code LIKE 'S50____' OR icd9code LIKE 'S60____' OR icd9code LIKE 'S70____' OR icd9code LIKE 'S80____' OR icd9code LIKE 'S90____' OR icd9code BETWEEN '92%' AND '92499') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S')
           AND patientunitstayid IN (
                SELECT patientunitstayid
                FROM `physionet-data.eicu_crd.diagnosis`
                GROUP BY patientunitstayid
                HAVING COUNT(DISTINCT diagnosisoffset) > 1
           )
      THEN 'YES'
      ELSE 'NO'
    END AS contusion_any_diagnosisoffset
  FROM
    `physionet-data.eicu_crd.diagnosis`
)
SELECT
    patientunitstayid AS stay_id,
    diagnosisoffset,
    icd9code,
    contusion_min_diagnosisoffset,
    contusion_any_diagnosisoffset  
FROM sq1
WHERE diagnosisoffset = min_diagnosisoffset AND (contusion_min_diagnosisoffset = 'YES'  OR contusion_any_diagnosisoffset = 'YES')
ORDER BY patientunitstayid ASC;
