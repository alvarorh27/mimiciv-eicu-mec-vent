WITH sq1 AS (
  SELECT
    patientunitstayid,
    diagnosisoffset,
    icd9code,
    MIN(diagnosisoffset) OVER (PARTITION BY patientunitstayid) AS min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S431___' OR icd9code LIKE 'S132___' OR icd9code LIKE 'S131___' OR icd9code LIKE 'S530___' OR icd9code LIKE 'S730___' OR icd9code LIKE 'S630___' OR icd9code LIKE 'S232___' OR icd9code LIKE 'S031___' OR icd9code LIKE 'S332___' OR icd9code LIKE 'S531___' OR icd9code LIKE 'S058___' OR icd9code LIKE 'S632___' OR icd9code LIKE 'S931___' OR icd9code LIKE 'S032___' OR icd9code LIKE 'S432___' OR icd9code LIKE 'S430___' OR icd9code LIKE 'S433___' OR icd9code LIKE 'S333___' OR icd9code LIKE 'S631___' OR icd9code LIKE 'S030___' OR icd9code LIKE 'S933___' OR icd9code LIKE 'S831___' OR icd9code LIKE 'S830___' OR icd9code LIKE 'S334___' OR icd9code LIKE 'S930___' OR icd9code LIKE 'S331___' OR icd9code LIKE 'S231___' OR icd9code LIKE 'S339XA' OR icd9code LIKE 'S832___' OR icd9code LIKE 'S833___') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S') OR (icd9code BETWEEN '83%' AND '83999')
      THEN 1
      ELSE 0
    END AS luxation_min_diagnosisoffset,
    CASE
      WHEN (icd9code LIKE 'S431___' OR icd9code LIKE 'S132___' OR icd9code LIKE 'S131___' OR icd9code LIKE 'S530___' OR icd9code LIKE 'S730___' OR icd9code LIKE 'S630___' OR icd9code LIKE 'S232___' OR icd9code LIKE 'S031___' OR icd9code LIKE 'S332___' OR icd9code LIKE 'S531___' OR icd9code LIKE 'S058___' OR icd9code LIKE 'S632___' OR icd9code LIKE 'S931___' OR icd9code LIKE 'S032___' OR icd9code LIKE 'S432___' OR icd9code LIKE 'S430___' OR icd9code LIKE 'S433___' OR icd9code LIKE 'S333___' OR icd9code LIKE 'S631___' OR icd9code LIKE 'S030___' OR icd9code LIKE 'S933___' OR icd9code LIKE 'S831___' OR icd9code LIKE 'S830___' OR icd9code LIKE 'S334___' OR icd9code LIKE 'S930___' OR icd9code LIKE 'S331___' OR icd9code LIKE 'S231___' OR icd9code LIKE 'S339XA' OR icd9code LIKE 'S832___' OR icd9code LIKE 'S833___') AND (icd9code NOT LIKE '______D'AND icd9code NOT LIKE '______S') OR (icd9code BETWEEN '83%' AND '83999')
           AND patientunitstayid IN (
                SELECT patientunitstayid
                FROM `physionet-data.eicu_crd.diagnosis`
                GROUP BY patientunitstayid
                HAVING COUNT(DISTINCT diagnosisoffset) > 1
           )
      THEN 1
      ELSE 0
    END AS luxation_any_diagnosisoffset
  FROM
    `physionet-data.eicu_crd.diagnosis`
)
SELECT
    patientunitstayid AS stay_id,
    diagnosisoffset,
    icd9code,
    luxation_min_diagnosisoffset,
    luxation_any_diagnosisoffset  
FROM sq1
WHERE diagnosisoffset = min_diagnosisoffset AND (luxation_min_diagnosisoffset = 1  OR luxation_any_diagnosisoffset = 1)
ORDER BY patientunitstayid ASC;
