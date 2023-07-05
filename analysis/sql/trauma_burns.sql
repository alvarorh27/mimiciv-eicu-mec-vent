WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    -- The entire table is sorted numerically;
    CASE
      WHEN (((icd_code BETWEEN 'T20' AND 'T29____') OR (icd_code BETWEEN 'T30' AND 'T32_') OR (icd_code BETWEEN '94%' AND '94999')) AND icd_code NOT LIKE '______S' AND icd_code NOT LIKE '______D') AND seq_num=1 THEN 1
    ELSE
    0
  END
    AS burns_seq_1,
    -- New column: if you have TBI in seq_num=1 it appears as YES
    CASE
      WHEN (((icd_code BETWEEN 'T20' AND 'T29____') OR (icd_code BETWEEN 'T30' AND 'T32_')OR (icd_code BETWEEN '94%' AND '94999')) AND icd_code NOT LIKE '______S' AND icd_code NOT LIKE '______D') AND seq_num>=1 THEN 1
    ELSE
    0
  END
    AS burns_any_seq,
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
  burns_seq_1,
  burns_any_seq
 FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id -- variable to indicate the hadm_id of the previous row;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      burns_seq_1,
      burns_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      burns_seq_1,
      burns_any_seq
    HAVING
      burns_any_seq=1
      OR burns_seq_1=1 -- to group when there are BURNS
    ORDER BY
      subject_id,
      hadm_id,
      burns_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND burns_seq_1=0
    AND burns_any_seq=1) --look at word
ORDER BY
  subject_id,
  hadm_id
