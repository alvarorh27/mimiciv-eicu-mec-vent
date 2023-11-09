SELECT
  patientunitstayid AS stay_id,
  event,
  hrs
FROM
  `physionet-data.eicu_crd_derived.ventilation_events`
WHERE
  event = "Trach"
  AND hrs>=96