%%%%%%%%%%%%%%%%%%%%%% Create X and Y for PLS toolkit %%%%%%%%%%%%%%%%%%%%%%
clear all; clc

% Brain data: subject loadings of the 150 ICs, z-scored across the full sample,
% then restricted to the autistic participants
the_path = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_Format/150ica_secondfilter/';
brain = load(strcat(the_path, 'subjectCoursesOut.txt'));
brain_pls = zscore(brain');

clinical_all = readtable('/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/R Studio/data/data_final/FSL_pheno_second_filter.csv');
I = find(clinical_all.DX_GROUP == 1);
Y = brain_pls(I,:);

% Clinical data: imputed scores of the autistic participants (same order as Y)
clinical = readtable('/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Imputation/imputed_data_final_FSL.csv');
X = [zscore(clinical.ADOS_2_severity_harmonized), ...
     zscore(clinical.ADI_R_SOCIAL_TOTAL_A), ...
     zscore(clinical.ADOS_2_rrb_harmonized), ...
     zscore(clinical.ADOS_2_total_gotham_harmonized), ...
     zscore(clinical.ADOS_2_socaff_harmonized), ...
     zscore(clinical.ADI_R_VERBAL_TOTAL_BV), ...
     zscore(clinical.ADI_RRB_harmonized), ...
     zscore(clinical.ADI_R_NONVERBAL_TOTAL_BV)];

% Regress out age, FIQ, sex and site from both blocks
confounds = [zscore(clinical.AGE_AT_SCAN), zscore(clinical.FIQ), zscore(double(clinical.SEX))];
sites = dummyvar(categorical(clinical.SITE_ID));
confounds = [confounds, zscore(sites(:, 2:end))];
C = [ones(size(confounds,1),1), confounds];
Rz_fn = @(M) M - C*(C\M);

X = Rz_fn(X);   % 405 x 8 clinical
Y = Rz_fn(Y);   % 405 x 150 brain

% Save for the toolkit
save('/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_analysis/data/X.mat', 'X');
save('/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_analysis/data/Y.mat', 'Y');
