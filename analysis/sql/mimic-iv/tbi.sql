WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    --se ordena numéricamente toda la tabla;
    CASE
      WHEN (icd_code BETWEEN '80000' AND '80199' OR icd_code BETWEEN '80300' AND '80499' OR icd_code BETWEEN '85000' AND '85410' OR icd_code BETWEEN '95010' AND '95030' OR icd_code='95901' OR icd_code='99555' OR icd_code='S020' OR icd_code LIKE 'S020__A' OR icd_code LIKE 'S020__B' OR icd_code='S021' OR icd_code LIKE 'S021_' OR icd_code LIKE 'S021__' OR icd_code LIKE 'S021__A' OR icd_code LIKE 'S021__B' OR icd_code='S028' OR icd_code LIKE 'S028__A' OR icd_code LIKE 'S028__B' OR icd_code='S0291' OR icd_code LIKE 'S0291_A' OR icd_code LIKE 'S0291_B' OR icd_code='S0402' OR icd_code LIKE 'S0402_A' OR icd_code='S0403' OR icd_code LIKE 'S0403_' OR icd_code LIKE 'S0403_A' OR icd_code='S0404' OR icd_code LIKE 'S0404_' OR icd_code LIKE 'S0404_A' OR icd_code='S06' OR icd_code LIKE 'S06_' OR icd_code LIKE 'S06__' OR icd_code LIKE 'S06___' OR icd_code LIKE 'S06___A' OR icd_code='S071' OR icd_code LIKE 'S071__A' OR icd_code='T744' OR icd_code='T744__A') AND seq_num=1 THEN 1
    ELSE
    0
  END
    AS tbi_seq_1,
    --Columna nueva: si tiene tbi en seq_num=1 aparece como YES
    CASE
      WHEN (icd_code BETWEEN '80000' AND '80199' OR icd_code BETWEEN '80300' AND '80499' OR icd_code BETWEEN '85000' AND '85410' OR icd_code BETWEEN '95010' AND '95030' OR icd_code='95901' OR icd_code='99555' OR icd_code='S020' OR icd_code LIKE 'S020__A' OR icd_code LIKE 'S020__B' OR icd_code='S021' OR icd_code LIKE 'S021_' OR icd_code LIKE 'S021__' OR icd_code LIKE 'S021__A' OR icd_code LIKE 'S021__B' OR icd_code='S028' OR icd_code LIKE 'S028__A' OR icd_code LIKE 'S028__B' OR icd_code='S0291' OR icd_code LIKE 'S0291_A' OR icd_code LIKE 'S0291_B' OR icd_code='S0402' OR icd_code LIKE 'S0402_A' OR icd_code='S0403' OR icd_code LIKE 'S0403_' OR icd_code LIKE 'S0403_A' OR icd_code='S0404' OR icd_code LIKE 'S0404_' OR icd_code LIKE 'S0404_A' OR icd_code='S06' OR icd_code LIKE 'S06_' OR icd_code LIKE 'S06__' OR icd_code LIKE 'S06___' OR icd_code LIKE 'S06___A' OR icd_code='S071' OR icd_code LIKE 'S071__A' OR icd_code='T744' OR icd_code='T744__A') AND seq_num>=1 THEN 1
    ELSE
    0
  END
    AS tbi_any_seq,
    --Columna nueva: si tiene tbi en cualquier seq_num aparece como YES,
  FROM
    `physionet-data.mimiciv_hosp.diagnoses_icd`
  ORDER BY
    subject_id,
    hadm_id,
    seq_num) --Fin de la sq1,
SELECT
  subject_id,
  hadm_id,
  prev_hadm_id,
  tbi_seq_1,
  tbi_any_seq,
  row_num
FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id --variable para indicar el hadm_id de la fila anterior;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      tbi_seq_1,
      tbi_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      tbi_seq_1,
      tbi_any_seq
    HAVING
      tbi_any_seq=1
      OR tbi_seq_1=1 --para agrupar cuando haya Traumatic brain injury
    ORDER BY
      subject_id,
      hadm_id,
      tbi_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND tbi_seq_1=0
    AND tbi_any_seq=1) --mirar word
ORDER BY
  subject_id,
  hadm_id
