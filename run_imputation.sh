#!/bin/bash
# Imputation of the clinical scores
# Uses the imputation toolbox from Llera et al. (2022): download the Imputation-master folder first.
# Input:  data_for_imputation_FSL.csv (created by the imputation-preparation R script)
# Output: Imputation_Output/data_for_imputation_FSL_imputed.xlsx

# Create the conda environment (only needed once)
conda env create -f imputation_conda_env.yml
conda activate imputation

cd '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/imputation/Imputation-master'

# Run the imputation (missing values are coded as 999)
python imputation999.py -savedir './Imputation_Output' 'data_for_imputation_FSL.csv'