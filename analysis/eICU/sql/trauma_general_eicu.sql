WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    CASE
      WHEN (icd9code LIKE 'S46____' OR icd9code LIKE 'S56____' OR icd9code LIKE 'S66____' OR icd9code LIKE 'S76____' OR icd9code LIKE 'S86____' OR icd9code LIKE 'S96____' OR icd9code LIKE 'S29____' OR icd9code LIKE 'S39____' OR icd9code LIKE 'S36____' OR icd9code LIKE 'S37____' OR icd9code LIKE 'S27____' OR icd9code LIKE 'S26____' OR icd9code LIKE 'S07____' OR icd9code LIKE 'S17____' OR icd9code LIKE 'S38____' OR icd9code LIKE 'S28____' OR icd9code LIKE 'S47____' OR icd9code LIKE 'S57____' OR icd9code LIKE 'S67____' OR icd9code LIKE 'S77____' OR icd9code LIKE 'S87____' OR icd9code LIKE 'S97____' OR icd9code LIKE 'S04____' OR icd9code LIKE 'S14____' OR icd9code LIKE 'S24____' OR icd9code LIKE 'S34____' OR icd9code LIKE 'S54____' OR icd9code LIKE 'S64____' OR icd9code LIKE 'S44____' OR icd9code LIKE 'S74____' OR icd9code LIKE 'S84____' OR icd9code LIKE 'S94____' OR icd9code LIKE 'S09____' OR icd9code LIKE 'S19____' OR icd9code LIKE 'S49____' OR icd9code LIKE 'S59____' OR icd9code LIKE 'S69____' OR icd9code LIKE 'S79____' OR icd9code LIKE 'S89____')
           AND (icd9code LIKE '______A' OR icd9code LIKE '______B' OR icd9code LIKE '______C')
           OR (icd9code BETWEEN '860' AND '86999' OR icd9code BETWEEN '925' AND '92999' OR icd9code BETWEEN '950' AND '95799' OR icd9code BETWEEN '9590' AND '9599') AND diagnosisoffset = min_diagnosisoffset
      THEN 1
      ELSE 0
    END AS traumatic_general_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S46____' OR icd9code LIKE 'S56____' OR icd9code LIKE 'S66____' OR icd9code LIKE 'S76____' OR icd9code LIKE 'S86____' OR icd9code LIKE 'S96____' OR icd9code LIKE 'S29____' OR icd9code LIKE 'S39____' OR icd9code LIKE 'S36____' OR icd9code LIKE 'S37____' OR icd9code LIKE 'S27____' OR icd9code LIKE 'S26____' OR icd9code LIKE 'S07____' OR icd9code LIKE 'S17____' OR icd9code LIKE 'S38____' OR icd9code LIKE 'S28____' OR icd9code LIKE 'S47____' OR icd9code LIKE 'S57____' OR icd9code LIKE 'S67____' OR icd9code LIKE 'S77____' OR icd9code LIKE 'S87____' OR icd9code LIKE 'S97____' OR icd9code LIKE 'S04____' OR icd9code LIKE 'S14____' OR icd9code LIKE 'S24____' OR icd9code LIKE 'S34____' OR icd9code LIKE 'S54____' OR icd9code LIKE 'S64____' OR icd9code LIKE 'S44____' OR icd9code LIKE 'S74____' OR icd9code LIKE 'S84____' OR icd9code LIKE 'S94____' OR icd9code LIKE 'S09____' OR icd9code LIKE 'S19____' OR icd9code LIKE 'S49____' OR icd9code LIKE 'S59____' OR icd9code LIKE 'S69____' OR icd9code LIKE 'S79____' OR icd9code LIKE 'S89____')
           AND (icd9code LIKE '______A' OR icd9code LIKE '______B' OR icd9code LIKE '______C')
           OR (icd9code BETWEEN '860' AND '86999' OR icd9code BETWEEN '925' AND '92999' OR icd9code BETWEEN '950' AND '95799' OR icd9code BETWEEN '9590' AND '9599') 
      THEN 1
      ELSE 0
    END AS traumatic_general_any_diagnosisoffset
  FROM (
    SELECT * ,MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset
    FROM 
    `physionet-data.eicu_crd.diagnosis`) 
) -- end of sq1
SELECT
    patientunitstayid AS stay_id,
    traumatic_general_min_diagnosisoffset,
    traumatic_general_any_diagnosisoffset 
FROM sq1
WHERE traumatic_general_min_diagnosisoffset = 1 OR traumatic_general_any_diagnosisoffset = 1
ORDER BY patientunitstayid ASC;
