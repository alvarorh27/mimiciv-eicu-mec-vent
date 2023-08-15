WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    -- The entire table is sorted numerically;
    CASE
      WHEN (icd_code LIKE 'S434___' OR icd_code LIKE 'S435___' OR icd_code LIKE 'S436___' OR icd_code LIKE 'S438___' OR icd_code LIKE 'S439___' OR icd_code LIKE 'S134___' OR icd_code LIKE 'S135___' OR icd_code LIKE 'S138___' OR icd_code LIKE 'S139___' OR icd_code LIKE 'S039___' OR icd_code LIKE 'S034___' OR icd_code LIKE 'S038___' OR icd_code LIKE 'S731___' OR icd_code LIKE 'S635___' OR icd_code LIKE 'S636___' OR icd_code LIKE 'S638___' OR icd_code LIKE 'S639___' OR icd_code LIKE 'S234___' OR icd_code LIKE 'S233___' OR icd_code LIKE 'S238___' OR icd_code LIKE 'S239___' OR icd_code LIKE 'S134___' OR icd_code LIKE 'S135___' OR icd_code LIKE 'S138___' OR icd_code LIKE 'S139___' OR icd_code LIKE 'S834___' OR icd_code LIKE 'S835___' OR icd_code LIKE 'S836___' OR icd_code LIKE 'S838___' OR icd_code LIKE 'S839___' OR icd_code LIKE 'S534___' OR icd_code LIKE 'S335___' OR icd_code LIKE 'S336___' OR icd_code LIKE 'S338___' OR icd_code LIKE 'S936___' OR icd_code LIKE 'S761___' OR icd_code LIKE 'S934___' OR icd_code LIKE 'S935') AND (icd_code NOT LIKE '______D'AND icd_code NOT LIKE '______S') OR (icd_code BETWEEN '84%' AND '84899') AND seq_num=1 THEN 1
    ELSE
    0
  END
    AS sprain_seq_1,
    -- New column: if you have TBI in seq_num=1 it appears as YES
    CASE
      WHEN (icd_code LIKE 'S434___' OR icd_code LIKE 'S435___' OR icd_code LIKE 'S436___' OR icd_code LIKE 'S438___' OR icd_code LIKE 'S439___' OR icd_code LIKE 'S134___' OR icd_code LIKE 'S135___' OR icd_code LIKE 'S138___' OR icd_code LIKE 'S139___' OR icd_code LIKE 'S039___' OR icd_code LIKE 'S034___' OR icd_code LIKE 'S038___' OR icd_code LIKE 'S731___' OR icd_code LIKE 'S635___' OR icd_code LIKE 'S636___' OR icd_code LIKE 'S638___' OR icd_code LIKE 'S639___' OR icd_code LIKE 'S234___' OR icd_code LIKE 'S233___' OR icd_code LIKE 'S238___' OR icd_code LIKE 'S239___' OR icd_code LIKE 'S134___' OR icd_code LIKE 'S135___' OR icd_code LIKE 'S138___' OR icd_code LIKE 'S139___' OR icd_code LIKE 'S834___' OR icd_code LIKE 'S835___' OR icd_code LIKE 'S836___' OR icd_code LIKE 'S838___' OR icd_code LIKE 'S839___' OR icd_code LIKE 'S534___' OR icd_code LIKE 'S335___' OR icd_code LIKE 'S336___' OR icd_code LIKE 'S338___' OR icd_code LIKE 'S936___' OR icd_code LIKE 'S761___' OR icd_code LIKE 'S934___' OR icd_code LIKE 'S935') AND (icd_code NOT LIKE '______D'AND icd_code NOT LIKE '______S') OR (icd_code BETWEEN '84%' AND '84899') AND seq_num>=1 THEN 1
    ELSE
    0
  END
    AS sprain_any_seq,
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
  sprain_seq_1,
  sprain_any_seq
FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id -- variable to indicate the hadm_id of the previous row;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      sprain_seq_1,
      sprain_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      sprain_seq_1,
      sprain_any_seq
    HAVING
      sprain_any_seq=1
      OR sprain_seq_1=1 -- to group when there is SPRAIN
    ORDER BY
      subject_id,
      hadm_id,
      sprain_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND sprain_seq_1=0
    AND sprain_any_seq=1) --look at word
ORDER BY
  subject_id,
  hadm_id
