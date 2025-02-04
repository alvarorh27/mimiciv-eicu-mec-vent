## Overview
This repository contains code for the analysis of prolonged mechanical ventilation (PMV) and its association with mortality in 
ICU patients across two large, publicly available databases: MIMIC-IV and eICU. The study focuses on trauma-related cohorts, with 
a particular emphasis on severe traumatic brain injury (TBI) patients.

## Data Sources
- **[MIMIC-IV](https://physionet.org/content/mimiciv/2.2/)**: 
A single-center ICU database containing de-identified health data from Beth Israel Deaconess Medical Center.
- **[eICU](https://physionet.org/content/eicu-crd/2.0/)**: 
A multicenter ICU dataset with data from 208 hospitals across the United States.

## Main Features
- Extraction and preprocessing of data from both datasets (analysis/01_dataset.Rmd)
- Baseline characteristics of patients stratified by PMV, mortality, trauma cohorts, etc. (analysis/02-tables.Rmd)
- Multivariable and univariable models evaluating PMV and mortality associations (analysis/03-modeling)

## Repository Structure
```
├── analysis/              # Data preprocessing, statistical analysis and model implementation
├── data/                  # Summary tables
├── figures/               # Plots, tables and figures
├── README.md              # Project description
```

## Installation & Dependencies
To run the Rmd files, you need **RStudio** and **R (version 4.3.3 or later)**.  
All required dependencies are specified within each Rmd file.

## Usage
1. **Register** on [PhysioNet](https://physionet.org/).
2. **Obtain access** to the MIMIC-IV and eICU databases.
3. **Request access** through Google BigQuery.
4. **Run the Rmd files** in the following order:
   - `01_dataset` (You will be prompted to enter your email and BigQuery project name for the database connection)
   - `02_tables`
   - `03_modeling`



