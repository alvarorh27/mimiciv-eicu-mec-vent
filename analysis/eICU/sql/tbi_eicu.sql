WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    CASE
      WHEN (icd9code BETWEEN '80000' AND '80199' OR icd9code BETWEEN '80300' AND '80499' OR icd9code BETWEEN '85000' AND '85410' OR icd9code BETWEEN '95010' AND '95030' OR icd9code='95901' OR icd9code='99555' OR icd9code='S020' OR icd9code LIKE 'S020__A' OR icd9code LIKE 'S020__B' OR icd9code='S021' OR icd9code LIKE 'S021_' OR icd9code LIKE 'S021__' OR icd9code LIKE 'S021__A' OR icd9code LIKE 'S021__B' OR icd9code='S028' OR icd9code LIKE 'S028__A' OR icd9code LIKE 'S028__B' OR icd9code='S0291' OR icd9code LIKE 'S0291_A' OR icd9code LIKE 'S0291_B' OR icd9code='S0402' OR icd9code LIKE 'S0402_A' OR icd9code='S0403' OR icd9code LIKE 'S0403_' OR icd9code LIKE 'S0403_A' OR icd9code='S0404' OR icd9code LIKE 'S0404_' OR icd9code LIKE 'S0404_A' OR icd9code='S06' OR icd9code LIKE 'S06_' OR icd9code LIKE 'S06__' OR icd9code LIKE 'S06___' OR icd9code LIKE 'S06___A' OR icd9code='S071' OR icd9code LIKE 'S071__A' OR icd9code='T744' OR icd9code='T744__A')
      AND diagnosisoffset = min_diagnosisoffset
      THEN 1
      ELSE 0
    END AS tbi_min_diagnosisoffset,
    CASE
      WHEN (icd9code BETWEEN '80000' AND '80199' OR icd9code BETWEEN '80300' AND '80499' OR icd9code BETWEEN '85000' AND '85410' OR icd9code BETWEEN '95010' AND '95030' OR icd9code='95901' OR icd9code='99555' OR icd9code='S020' OR icd9code LIKE 'S020__A' OR icd9code LIKE 'S020__B' OR icd9code='S021' OR icd9code LIKE 'S021_' OR icd9code LIKE 'S021__' OR icd9code LIKE 'S021__A' OR icd9code LIKE 'S021__B' OR icd9code='S028' OR icd9code LIKE 'S028__A' OR icd9code LIKE 'S028__B' OR icd9code='S0291' OR icd9code LIKE 'S0291_A' OR icd9code LIKE 'S0291_B' OR icd9code='S0402' OR icd9code LIKE 'S0402_A' OR icd9code='S0403' OR icd9code LIKE 'S0403_' OR icd9code LIKE 'S0403_A' OR icd9code='S0404' OR icd9code LIKE 'S0404_' OR icd9code LIKE 'S0404_A' OR icd9code='S06' OR icd9code LIKE 'S06_' OR icd9code LIKE 'S06__' OR icd9code LIKE 'S06___' OR icd9code LIKE 'S06___A' OR icd9code='S071' OR icd9code LIKE 'S071__A' OR icd9code='T744' OR icd9code='T744__A') 
      THEN 1
      ELSE 0
    END AS tbi_any_diagnosisoffset
  FROM (
    SELECT * ,MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset
    FROM 
    `physionet-data.eicu_crd.diagnosis`) 
)
SELECT
    patientunitstayid AS stay_id,
    tbi_min_diagnosisoffset,
    tbi_any_diagnosisoffset 
FROM sq1
WHERE tbi_min_diagnosisoffset = 1 OR tbi_any_diagnosisoffset = 1
ORDER BY patientunitstayid ASC;
