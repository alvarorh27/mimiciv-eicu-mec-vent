WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset,
    CASE
      WHEN (icd9code BETWEEN '80000' AND '80199' OR icd9code BETWEEN '80300' AND '80499' OR icd9code BETWEEN '85000' AND '85410' OR icd9code BETWEEN '95010' AND '95030' OR icd9code='95901' OR icd9code='99555' OR icd9code='S020' OR icd9code LIKE 'S020__A' OR icd9code LIKE 'S020__B' OR icd9code='S021' OR icd9code LIKE 'S021_' OR icd9code LIKE 'S021__' OR icd9code LIKE 'S021__A' OR icd9code LIKE 'S021__B' OR icd9code='S028' OR icd9code LIKE 'S028__A' OR icd9code LIKE 'S028__B' OR icd9code='S0291' OR icd9code LIKE 'S0291_A' OR icd9code LIKE 'S0291_B' OR icd9code='S0402' OR icd9code LIKE 'S0402_A' OR icd9code='S0403' OR icd9code LIKE 'S0403_' OR icd9code LIKE 'S0403_A' OR icd9code='S0404' OR icd9code LIKE 'S0404_' OR icd9code LIKE 'S0404_A' OR icd9code='S06' OR icd9code LIKE 'S06_' OR icd9code LIKE 'S06__' OR icd9code LIKE 'S06___' OR icd9code LIKE 'S06___A' OR icd9code='S071' OR icd9code LIKE 'S071__A' OR icd9code='T744' OR icd9code='T744__A')
      THEN 1
      ELSE 0
    END AS tbi_seq1,
    CASE
      WHEN (icd9code BETWEEN '80000' AND '80199' OR icd9code BETWEEN '80300' AND '80499' OR icd9code BETWEEN '85000' AND '85410' OR icd9code BETWEEN '95010' AND '95030' OR icd9code='95901' OR icd9code='99555' OR icd9code='S020' OR icd9code LIKE 'S020__A' OR icd9code LIKE 'S020__B' OR icd9code='S021' OR icd9code LIKE 'S021_' OR icd9code LIKE 'S021__' OR icd9code LIKE 'S021__A' OR icd9code LIKE 'S021__B' OR icd9code='S028' OR icd9code LIKE 'S028__A' OR icd9code LIKE 'S028__B' OR icd9code='S0291' OR icd9code LIKE 'S0291_A' OR icd9code LIKE 'S0291_B' OR icd9code='S0402' OR icd9code LIKE 'S0402_A' OR icd9code='S0403' OR icd9code LIKE 'S0403_' OR icd9code LIKE 'S0403_A' OR icd9code='S0404' OR icd9code LIKE 'S0404_' OR icd9code LIKE 'S0404_A' OR icd9code='S06' OR icd9code LIKE 'S06_' OR icd9code LIKE 'S06__' OR icd9code LIKE 'S06___' OR icd9code LIKE 'S06___A' OR icd9code='S071' OR icd9code LIKE 'S071__A' OR icd9code='T744' OR icd9code='T744__A')
           AND patientunitstayid IN (
                SELECT patientunitstayid
                FROM `physionet-data.eicu_crd.diagnosis`
                GROUP BY patientunitstayid
                HAVING COUNT(DISTINCT diagnosisoffset) > 1
           )
      THEN 1
      ELSE 0
    END AS tbi_anyseq
  FROM
    `physionet-data.eicu_crd.diagnosis`
) --end of sq1
SELECT
    patientunitstayid AS stay_id,
    diagnosisoffset,
    icd9code,
    tbi_seq1,
    tbi_anyseq 
FROM sq1
WHERE diagnosisoffset = min_diagnosisoffset AND (tbi_seq1 = 1  OR tbi_anyseq = 1) --group when there is Traumatic general injury
ORDER BY patientunitstayid ASC;
