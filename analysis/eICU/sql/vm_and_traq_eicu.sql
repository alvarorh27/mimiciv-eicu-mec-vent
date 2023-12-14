/*Select tracheostomy procedures in respiratorycare table*/
SELECT
DISTINCT(patientunitstayid) AS stay_id, 
airwaytype
FROM
  `physionet-data.eicu_crd.respiratorycare`
WHERE
airwaytype = "Tracheostomy"
