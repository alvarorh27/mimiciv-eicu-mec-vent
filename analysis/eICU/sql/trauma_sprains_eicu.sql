WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S434___' OR icd9code LIKE 'S435___' OR icd9code LIKE 'S436___' OR icd9code LIKE 'S438___' OR icd9code LIKE 'S439___' OR icd9code LIKE 'S134___' OR icd9code LIKE 'S135___' OR icd9code LIKE 'S138___' OR icd9code LIKE 'S139___' OR icd9code LIKE 'S039___' OR icd9code LIKE 'S034___' OR icd9code LIKE 'S038___' OR icd9code LIKE 'S731___' OR icd9code LIKE 'S635___' OR icd9code LIKE 'S636___' OR icd9code LIKE 'S638___' OR icd9code LIKE 'S639___' OR icd9code LIKE 'S234___' OR icd9code LIKE 'S233___' OR icd9code LIKE 'S238___' OR icd9code LIKE 'S239___' OR icd9code LIKE 'S134___' OR icd9code LIKE 'S135___' OR icd9code LIKE 'S138___' OR icd9code LIKE 'S139___' OR icd9code LIKE 'S834___' OR icd9code LIKE 'S835___' OR icd9code LIKE 'S836___' OR icd9code LIKE 'S838___' OR icd9code LIKE 'S839___' OR icd9code LIKE 'S534___' OR icd9code LIKE 'S335___' OR icd9code LIKE 'S336___' OR icd9code LIKE 'S338___' OR icd9code LIKE 'S936___' OR icd9code LIKE 'S761___' OR icd9code LIKE 'S934___' OR icd9code LIKE 'S935') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S') OR (icd9code BETWEEN '84%' AND '84899')
      THEN 'YES'
      ELSE 'NO'
    END AS sprain_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S434___' OR icd9code LIKE 'S435___' OR icd9code LIKE 'S436___' OR icd9code LIKE 'S438___' OR icd9code LIKE 'S439___' OR icd9code LIKE 'S134___' OR icd9code LIKE 'S135___' OR icd9code LIKE 'S138___' OR icd9code LIKE 'S139___' OR icd9code LIKE 'S039___' OR icd9code LIKE 'S034___' OR icd9code LIKE 'S038___' OR icd9code LIKE 'S731___' OR icd9code LIKE 'S635___' OR icd9code LIKE 'S636___' OR icd9code LIKE 'S638___' OR icd9code LIKE 'S639___' OR icd9code LIKE 'S234___' OR icd9code LIKE 'S233___' OR icd9code LIKE 'S238___' OR icd9code LIKE 'S239___' OR icd9code LIKE 'S134___' OR icd9code LIKE 'S135___' OR icd9code LIKE 'S138___' OR icd9code LIKE 'S139___' OR icd9code LIKE 'S834___' OR icd9code LIKE 'S835___' OR icd9code LIKE 'S836___' OR icd9code LIKE 'S838___' OR icd9code LIKE 'S839___' OR icd9code LIKE 'S534___' OR icd9code LIKE 'S335___' OR icd9code LIKE 'S336___' OR icd9code LIKE 'S338___' OR icd9code LIKE 'S936___' OR icd9code LIKE 'S761___' OR icd9code LIKE 'S934___' OR icd9code LIKE 'S935') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S') OR (icd9code BETWEEN '84%' AND '84899')
           AND patientunitstayid IN (
                SELECT patientunitstayid
                FROM `physionet-data.eicu_crd.diagnosis`
                GROUP BY patientunitstayid
                HAVING COUNT(DISTINCT diagnosisoffset) > 1
           )
      THEN 'YES'
      ELSE 'NO'
    END AS sprain_any_diagnosisoffset
  FROM
    `physionet-data.eicu_crd.diagnosis`
)
SELECT
    patientunitstayid AS stay_id,
    diagnosisoffset,
    icd9code,
    sprain_min_diagnosisoffset,
    sprain_any_diagnosisoffset  
FROM sq1
WHERE diagnosisoffset = min_diagnosisoffset AND (sprain_min_diagnosisoffset = 'YES'  OR sprain_any_diagnosisoffset = 'YES')
ORDER BY patientunitstayid ASC;
