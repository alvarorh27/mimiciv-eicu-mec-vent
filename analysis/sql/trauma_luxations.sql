WITH
  sq1 AS(
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY subject_id, hadm_id, seq_num) AS row_num,
    -- The entire table is sorted numerically;
    CASE
      WHEN (icd_code LIKE 'S431___' OR icd_code LIKE 'S132___' OR icd_code LIKE 'S131___' OR icd_code LIKE 'S530___' OR icd_code LIKE 'S730___' OR icd_code LIKE 'S630___' OR icd_code LIKE 'S232___' OR icd_code LIKE 'S031___' OR icd_code LIKE 'S332___' OR icd_code LIKE 'S531___' OR icd_code LIKE 'S058___' OR icd_code LIKE 'S632___' OR icd_code LIKE 'S931___' OR icd_code LIKE 'S032___' OR icd_code LIKE 'S432___' OR icd_code LIKE 'S430___' OR icd_code LIKE 'S433___' OR icd_code LIKE 'S333___' OR icd_code LIKE 'S631___' OR icd_code LIKE 'S030___' OR icd_code LIKE 'S933___' OR icd_code LIKE 'S831___' OR icd_code LIKE 'S830___' OR icd_code LIKE 'S334___' OR icd_code LIKE 'S930___' OR icd_code LIKE 'S331___' OR icd_code LIKE 'S231___' OR icd_code LIKE 'S339XA' OR icd_code LIKE 'S832___' OR icd_code LIKE 'S833___') AND (icd_code NOT LIKE '______D'AND icd_code NOT LIKE '______S') OR (icd_code BETWEEN '83%' AND '83999') AND seq_num=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS luxation_seq_1,
    -- New column: if you have TBI in seq_num=1 it appears as YES
    CASE
      WHEN (icd_code LIKE 'S431___' OR icd_code LIKE 'S132___' OR icd_code LIKE 'S131___' OR icd_code LIKE 'S530___' OR icd_code LIKE 'S730___' OR icd_code LIKE 'S630___' OR icd_code LIKE 'S232___' OR icd_code LIKE 'S031___' OR icd_code LIKE 'S332___' OR icd_code LIKE 'S531___' OR icd_code LIKE 'S058___' OR icd_code LIKE 'S632___' OR icd_code LIKE 'S931___' OR icd_code LIKE 'S032___' OR icd_code LIKE 'S432___' OR icd_code LIKE 'S430___' OR icd_code LIKE 'S433___' OR icd_code LIKE 'S333___' OR icd_code LIKE 'S631___' OR icd_code LIKE 'S030___' OR icd_code LIKE 'S933___' OR icd_code LIKE 'S831___' OR icd_code LIKE 'S830___' OR icd_code LIKE 'S334___' OR icd_code LIKE 'S930___' OR icd_code LIKE 'S331___' OR icd_code LIKE 'S231___' OR icd_code LIKE 'S339XA' OR icd_code LIKE 'S832___' OR icd_code LIKE 'S833___') AND (icd_code NOT LIKE '______D'AND icd_code NOT LIKE '______S') OR (icd_code BETWEEN '83%' AND '83999')AND seq_num>=1 THEN 'YES'
    ELSE
    'NO'
  END
    AS luxation_any_seq,
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
  luxation_seq_1,
  luxation_any_seq
FROM (
  SELECT
    *,
    LAG(hadm_id) OVER (ORDER BY subject_id, hadm_id) AS prev_hadm_id -- variable to indicate the hadm_id of the previous row;
  FROM (
    SELECT
      subject_id,
      hadm_id,
      luxation_seq_1,
      luxation_any_seq,
      MIN(row_num) AS row_num
    FROM
      sq1
    GROUP BY
      subject_id,
      hadm_id,
      luxation_seq_1,
      luxation_any_seq
    HAVING
      luxation_any_seq='YES'
      OR luxation_seq_1='YES' -- to group when there is LUXATION
    ORDER BY
      subject_id,
      hadm_id,
      luxation_seq_1))
WHERE
  NOT (hadm_id=prev_hadm_id
    AND luxation_seq_1='NO'
    AND luxation_any_seq='YES') --look at word
ORDER BY
  subject_id,
  hadm_id
