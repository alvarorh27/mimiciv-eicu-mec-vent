WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    -- The entire table is sorted numerically;
    CASE
      WHEN (icd_code LIKE 'S10____' OR icd_code LIKE 'S00____' OR icd_code LIKE 'S05____' OR icd_code LIKE 'S20____' OR icd_code LIKE 'S40____' OR icd_code LIKE 'S50____' OR icd_code LIKE 'S60____' OR icd_code LIKE 'S70____' OR icd_code LIKE 'S80____' OR icd_code LIKE 'S90____' OR icd_code BETWEEN '92%' AND '92499') AND (icd_code NOT LIKE '______D'AND icd_code NOT LIKE '______S') AND seq_num=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS contusion_seq_1,
    -- New column: if you have TBI in seq_num=1 it appears as YES
    CASE
      WHEN (icd_code LIKE 'S10____' OR icd_code LIKE 'S00____' OR icd_code LIKE 'S05____' OR icd_code LIKE 'S20____' OR icd_code LIKE 'S40____' OR icd_code LIKE 'S50____' OR icd_code LIKE 'S60____' OR icd_code LIKE 'S70____' OR icd_code LIKE 'S80____' OR icd_code LIKE 'S90____' OR icd_code BETWEEN '92%' AND '92499') AND (icd_code NOT LIKE '______D'AND icd_code NOT LIKE '______S') AND seq_num>=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS contusion_any_seq,
    -- New column: If you have TBI on any seq_num it appears as YES,
  FROM
    `physionet-data.mimiciv_hosp.diagnoses_icd`
  ORDER BY
    subject_id,
    hadm_id,
    seq_num) -- End of sq1,
SELECT
  subject_id,
  hadm_id,
  contusion_seq_1,
  contusion_any_seq
FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id -- variable to indicate the hadm_id of the previous row;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      contusion_seq_1,
      contusion_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      contusion_seq_1,
      contusion_any_seq
    HAVING
      contusion_any_seq='YES'
      OR contusion_seq_1='YES' -- to group when there is CONTUSION
    ORDER BY
      subject_id,
      hadm_id,
      contusion_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND contusion_seq_1='NO'
    AND contusion_any_seq='YES') --look at word
ORDER BY
  subject_id,
  hadm_id

