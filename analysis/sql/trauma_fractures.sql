WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    -- se ordena numéricamente toda la tabla;
    CASE
      WHEN (icd_code LIKE 'S12____' OR icd_code LIKE 'S32____' OR icd_code LIKE 'S52____' OR icd_code LIKE 'S72____' OR icd_code LIKE 'S62____' OR icd_code LIKE 'S42____' OR icd_code LIKE 'S22____' OR icd_code LIKE 'S398___' OR icd_code LIKE 'S92____' OR icd_code LIKE 'S82____' OR icd_code LIKE 'S591___' OR icd_code LIKE 'S99____') AND (icd_code LIKE '______A' OR icd_code LIKE '______B' OR icd_code LIKE '______C') OR (icd_code BETWEEN '805' AND '82999') AND seq_num=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS fractures_seq_1,
    -- New column: if you have TBI in seq_num=1 it appears as YES
    CASE
      WHEN (icd_code LIKE 'S12____' OR icd_code LIKE 'S32____' OR icd_code LIKE 'S52____' OR icd_code LIKE 'S72____' OR icd_code LIKE 'S62____' OR icd_code LIKE 'S42____' OR icd_code LIKE 'S22____' OR icd_code LIKE 'S398___' OR icd_code LIKE 'S92____' OR icd_code LIKE 'S82____' OR icd_code LIKE 'S591___' OR icd_code LIKE 'S99____') AND (icd_code LIKE '______A' OR icd_code LIKE '______B' OR icd_code LIKE '______C' )OR (icd_code BETWEEN '805' AND '82999') AND seq_num>=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS fractures_any_seq,
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
  fractures_seq_1,
  fractures_any_seq
FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id -- variable to indicate the hadm_id of the previous row;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      fractures_seq_1,
      fractures_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      fractures_seq_1,
      fractures_any_seq
    HAVING
      fractures_any_seq='YES'
      OR fractures_seq_1='YES' -- to group when there are FRACTURES
    ORDER BY
      subject_id,
      hadm_id,
      fractures_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND fractures_seq_1='NO'
    AND fractures_any_seq='YES') --look at word
ORDER BY
  subject_id,
  hadm_id
