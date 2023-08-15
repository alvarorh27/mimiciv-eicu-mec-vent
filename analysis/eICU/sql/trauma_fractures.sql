WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S12____' OR icd9code LIKE 'S32____' OR icd9code LIKE 'S52____' OR icd9code LIKE 'S72____' OR icd9code LIKE 'S62____' OR icd9code LIKE 'S42____' OR icd9code LIKE 'S22____' OR icd9code LIKE 'S398___' OR icd9code LIKE 'S92____' OR icd9code LIKE 'S82____' OR icd9code LIKE 'S591___' OR icd9code LIKE 'S99____') AND (icd9code LIKE '______A' OR icd9code LIKE '______B' OR icd9code LIKE '______C') OR (icd9code BETWEEN '805' AND '82999')
      THEN 'YES'
      ELSE 'NO'
    END AS fractures_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S12____' OR icd9code LIKE 'S32____' OR icd9code LIKE 'S52____' OR icd9code LIKE 'S72____' OR icd9code LIKE 'S62____' OR icd9code LIKE 'S42____' OR icd9code LIKE 'S22____' OR icd9code LIKE 'S398___' OR icd9code LIKE 'S92____' OR icd9code LIKE 'S82____' OR icd9code LIKE 'S591___' OR icd9code LIKE 'S99____') AND (icd9code LIKE '______A' OR icd9code LIKE '______B' OR icd9code LIKE '______C') OR (icd9code BETWEEN '805' AND '82999')
           AND patientunitstayid IN (
                SELECT patientunitstayid
                FROM `physionet-data.eicu_crd.diagnosis`
                GROUP BY patientunitstayid
                HAVING COUNT(DISTINCT diagnosisoffset) > 1
           )
      THEN 'YES'
      ELSE 'NO'
    END AS fractures_any_diagnosisoffset
  FROM
    `physionet-data.eicu_crd.diagnosis`
)
SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    fractures_min_diagnosisoffset,
    fractures_any_diagnosisoffset  
FROM sq1
WHERE diagnosisoffset = min_diagnosisoffset AND (fractures_min_diagnosisoffset = 'YES'  OR fractures_any_diagnosisoffset = 'YES')
ORDER BY patientunitstayid ASC;
