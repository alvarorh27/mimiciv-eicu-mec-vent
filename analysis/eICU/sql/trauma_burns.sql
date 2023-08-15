WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset,
    CASE
      WHEN (((icd9code BETWEEN 'T20' AND 'T299') OR (icd9code BETWEEN 'T30' AND 'T329') OR (icd9code BETWEEN '94%' AND '94999')) AND icd9code NOT LIKE '9S' AND icd9code NOT LIKE '9D')
      THEN 'YES'
      ELSE 'NO'
    END AS burns_min_diagnosisoffset,
    CASE
      WHEN (((icd9code BETWEEN 'T20' AND 'T299') OR (icd9code BETWEEN 'T30' AND 'T329') OR (icd9code BETWEEN '94%' AND '94999')) AND icd9code NOT LIKE '9S' AND icd9code NOT LIKE '9D')
           AND patientunitstayid IN (
                SELECT patientunitstayid
                FROM `physionet-data.eicu_crd.diagnosis`
                GROUP BY patientunitstayid
                HAVING COUNT(DISTINCT diagnosisoffset) > 1
           )
      THEN 'YES'
      ELSE 'NO'
    END AS burns_any_diagnosisoffset
  FROM
    `physionet-data.eicu_crd.diagnosis`
)
SELECT
    patientunitstayid AS stay_id,
    diagnosisoffset,
    icd9code,
    burns_min_diagnosisoffset,
    burns_any_diagnosisoffset  
FROM sq1
WHERE diagnosisoffset = min_diagnosisoffset AND (burns_min_diagnosisoffset = 'YES'  OR burns_any_diagnosisoffset = 'YES')
ORDER BY patientunitstayid ASC;
