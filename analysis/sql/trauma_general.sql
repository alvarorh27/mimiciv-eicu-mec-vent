WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    -- The entire table is sorted numerically;
    CASE
      WHEN (icd_code LIKE 'S46____' OR icd_code LIKE 'S56____' OR icd_code LIKE 'S66____' OR icd_code LIKE 'S76____' OR icd_code LIKE 'S86____' OR icd_code LIKE 'S96____' OR icd_code LIKE 'S29____' OR icd_code LIKE 'S39____' OR icd_code LIKE 'S36____' OR icd_code LIKE 'S37____' OR icd_code LIKE 'S27____' OR icd_code LIKE 'S26____' OR icd_code LIKE 'S07____' OR icd_code LIKE 'S17____' OR icd_code LIKE 'S38____' OR icd_code LIKE 'S28____' OR icd_code LIKE 'S47____' OR icd_code LIKE 'S57____' OR icd_code LIKE 'S67____' OR icd_code LIKE 'S77____' OR icd_code LIKE 'S87____' OR icd_code LIKE 'S97____' OR icd_code LIKE 'S04____' OR icd_code LIKE 'S14____' OR icd_code LIKE 'S24____' OR icd_code LIKE 'S34____' OR icd_code LIKE 'S54____' OR icd_code LIKE 'S64____' OR icd_code LIKE 'S44____' OR icd_code LIKE 'S74____' OR icd_code LIKE 'S84____' OR icd_code LIKE 'S94____' OR icd_code LIKE 'S09____' OR icd_code LIKE 'S19____' OR icd_code LIKE 'S49____' OR icd_code LIKE 'S59____' OR icd_code LIKE 'S69____' OR icd_code LIKE 'S79____' OR icd_code LIKE 'S89____') AND (icd_code LIKE '______A' OR icd_code LIKE '______B' OR icd_code LIKE '______C') OR (icd_code BETWEEN '860' AND '86999'OR icd_code BETWEEN '925' AND '92999'OR icd_code BETWEEN '950' AND '95799'OR icd_code BETWEEN '9590' AND '9599') AND seq_num=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS traumatic_general_seq_1,
    -- New column: if you have TBI in seq_num=1 it appears as YES
    CASE
      WHEN (icd_code LIKE 'S46____' OR icd_code LIKE 'S56____' OR icd_code LIKE 'S66____' OR icd_code LIKE 'S76____' OR icd_code LIKE 'S86____' OR icd_code LIKE 'S96____' OR icd_code LIKE 'S29____' OR icd_code LIKE 'S39____' OR icd_code LIKE 'S36____' OR icd_code LIKE 'S37____' OR icd_code LIKE 'S27____' OR icd_code LIKE 'S26____' OR icd_code LIKE 'S07____' OR icd_code LIKE 'S17____' OR icd_code LIKE 'S38____' OR icd_code LIKE 'S28____' OR icd_code LIKE 'S47____' OR icd_code LIKE 'S57____' OR icd_code LIKE 'S67____' OR icd_code LIKE 'S77____' OR icd_code LIKE 'S87____' OR icd_code LIKE 'S97____' OR icd_code LIKE 'S04____' OR icd_code LIKE 'S14____' OR icd_code LIKE 'S24____' OR icd_code LIKE 'S34____' OR icd_code LIKE 'S54____' OR icd_code LIKE 'S64____' OR icd_code LIKE 'S44____' OR icd_code LIKE 'S74____' OR icd_code LIKE 'S84____' OR icd_code LIKE 'S94____' OR icd_code LIKE 'S09____' OR icd_code LIKE 'S19____' OR icd_code LIKE 'S49____' OR icd_code LIKE 'S59____' OR icd_code LIKE 'S69____' OR icd_code LIKE 'S79____' OR icd_code LIKE 'S89____') AND (icd_code LIKE '______A' OR icd_code LIKE '______B' OR icd_code LIKE '______C')OR (icd_code BETWEEN '860' AND '86999'OR icd_code BETWEEN '925' AND '92999'OR icd_code BETWEEN '950' AND '95799'OR icd_code BETWEEN '9590' AND '9599') AND seq_num>=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS traumatic_general_any_seq,
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
  traumatic_general_seq_1,
  traumatic_general_any_seq
FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id -- variable to indicate the hadm_id of the previous row;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      traumatic_general_seq_1,
      traumatic_general_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      traumatic_general_seq_1,
      traumatic_general_any_seq
    HAVING
      traumatic_general_any_seq='YES'
      OR traumatic_general_seq_1='YES'-- group when there is Traumatic general injury
    ORDER BY
      subject_id,
      hadm_id,
      traumatic_general_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND traumatic_general_seq_1='NO'
    AND traumatic_general_any_seq='YES') --look at word
ORDER BY
  subject_id,
  hadm_id
