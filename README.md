## Overview
This repository contains R Markdown and SQL code for studying prolonged mechanical ventilation (PMV) and its association with mortality in ICU patients across two large, publicly available critical care databases: MIMIC-IV and eICU.

The analysis focuses on trauma-related cohorts, with particular emphasis on traumatic brain injury (TBI), non-severe TBI, and severe TBI subgroups.

## Data Sources
- **[MIMIC-IV](https://physionet.org/content/mimiciv/2.2/)**: 
A single-center ICU database containing de-identified health data from Beth Israel Deaconess Medical Center.
- **[eICU](https://physionet.org/content/eicu-crd/2.0/)**: 
A multicenter ICU dataset with data from 208 hospitals across the United States.

## Repository Structure
```
analysis/
  mimic-iv/
    01_dataset_MIMICIV.Rmd       # MIMIC-IV extraction, preprocessing, cohort construction
    02-tables_MIMICIV.Rmd        # MIMIC-IV descriptive tables
    03-modeling_MIMICIV.Rmd      # MIMIC-IV regression models and PSM sensitivity analysis
    sql/                         # BigQuery SQL inputs for MIMIC-IV
  eICU/
    01_dataset_eICU.Rmd          # eICU extraction, preprocessing, cohort construction
    02_tables_eICU.Rmd           # eICU descriptive tables
    03-modeling_eICU.Rmd         # eICU hospital mortality regression models
    sql/                         # BigQuery SQL inputs for eICU

data/
  mimic-iv/                      # Final datasets, model outputs, PSM outputs, table exports
  eICU/                          # Final datasets, model outputs, table exports

figures/
  mimic-iv/                      # Forest plots and PSM plots
  eICU/                          # Forest plots

README.md
```

## Analysis Workflow

### 1. Dataset creation

Run the dataset creation notebooks separately for each database:

- `analysis/mimic-iv/01_dataset_MIMICIV.Rmd`
- `analysis/eICU/01_dataset_eICU.Rmd`

These files connect to Google BigQuery, run the SQL files in the local `sql/` directory, merge extracted tables, derive PMV and trauma/TBI variables, handle missingness, apply exclusions, and export final analysis datasets.

Main outputs:

- `data/mimic-iv/final_dataset_MIMICIV.rds`
- `data/mimic-iv/final_dataset_MIMICIV.csv`
- `data/eICU/final_dataset_eICU.rds`
- `data/eICU/final_dataset_eICU.csv`

### 2. Descriptive tables

Run:

- `analysis/mimic-iv/02-tables_MIMICIV.Rmd`
- `analysis/eICU/02_tables_eICU.Rmd`

These files load the final datasets and generate baseline characteristics tables stratified by PMV, mortality, trauma category, TBI category, and subgroup PMV status.

Selected table outputs are written as `.docx` files under:

- `data/mimic-iv/tables/`
- `data/eICU/tables/`

### 3. Modeling

Run:

- `analysis/mimic-iv/03-modeling_MIMICIV.Rmd`
- `analysis/eICU/03-modeling_eICU.Rmd`

The modeling notebooks fit univariable and multivariable logistic regression models estimating the association between PMV and mortality across:

- all patients
- non-trauma patients
- trauma patients
- non-TBI trauma patients
- TBI patients
- non-severe TBI patients
- severe TBI patients

MIMIC-IV models include hospital mortality and 1-year mortality. eICU models include hospital mortality.

MIMIC-IV also includes a propensity score matching sensitivity analysis, with balance tables, matched OR estimates, love plots, and comparison forest plots saved under `data/mimic-iv/` and `figures/mimic-iv/PSM/`.

## Usage
1. **Register** on [PhysioNet](https://physionet.org/).
2. **Obtain access** to the MIMIC-IV and eICU databases.
3. **Request access** through Google BigQuery.
4. **Open the RStudio project**: `mimic_mec_vent.Rproj`.
5. **Run the Rmd files from their database-specific directories** so relative SQL paths such as `sql/...` resolve correctly.
6. **Run files in order**:
   - dataset creation
   - descriptive tables
   - modeling

The dataset creation notebooks prompt for a Google BigQuery project ID and call `bigrquery::bq_auth()`.

## Requirements

The analysis requires R, RStudio, access to PhysioNet-hosted MIMIC-IV and eICU data through Google BigQuery, and the R packages loaded in the R Markdown files.

Commonly used packages include `bigrquery`, `DBI`, `dplyr`, `tidyverse`, `magrittr`, `tableone`, `kableExtra`, `gtsummary`, `flextable`, `officer`, `summarytools`, `naniar`, `modeest`, `mice`, `broom`, `htmlTable`, `ggplot2`, `MatchIt`, `cobalt`, `sandwich`, and `lmtest`.

## Notes

Several scripts currently contain hard-coded absolute paths under `C:/Users/se_al/Documents/GitHub/mimiciv-mec-vent`. These paths may need to be updated if the repository is moved or run on another machine.

The SQL files are inputs to the R Markdown workflows and are not standalone outputs.



