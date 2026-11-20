#!/bin/bash
# Threshold spatial maps VBM, JD of IC37 and IC1
# Part 1: maps used for the atlas overlap (original 4 mm resolution)
# Part 2: used for visualisation (z-scored, resampled to 0.5 mm)
# FLICA numbers ICs from 0: IC1 = vol0000, IC37 = vol0036

#### setup ####
FLICA_DIR='/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter'
VBM_DIR="${FLICA_DIR}/VBM_R"
JD_DIR="${FLICA_DIR}/JD_R"
MNI_REF='/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Data/MNImask/MNI152_T1_0.5mm.nii.gz'
GM='/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Data/Groupmask/final_002/group_mask_VBM_MNI_masked_GM_s8_4mm02.nii.gz'

# Split the 4D FLICA output into one 3D map per IC (niftiOut_mi1 = JD, niftiOut_mi2 = VBM)
mkdir -p "${VBM_DIR}" "${JD_DIR}"
cp "${FLICA_DIR}/niftiOut_mi2.nii.gz" "${VBM_DIR}/"
cp "${FLICA_DIR}/niftiOut_mi1.nii.gz" "${JD_DIR}/"
cd "${VBM_DIR}" && fslsplit niftiOut_mi2.nii.gz
cd "${JD_DIR}"  && fslsplit niftiOut_mi1.nii.gz


#### Part 1: thresholding for the atlas overlap ####
# Positive and negative loadings are thresholded separately at the 95th percentile of their non-zero voxels, at the original resolution (4 mm)
for DIR in "${VBM_DIR}" "${JD_DIR}"; do
    cd "${DIR}"
    for j in 00 36; do                     # IC1, IC37
        fslmaths vol00${j}.nii.gz -thr 0          vol00${j}_pos
        fslmaths vol00${j}.nii.gz -uthr 0 -mul -1 vol00${j}_neg

        for t in pos neg; do
            thresh_it=$(fslstats vol00${j}_${t}.nii.gz -P 95)
            echo "${DIR##*/} | IC vol00${j} | ${t}: threshold = ${thresh_it}"
            fslmaths vol00${j}_${t}.nii.gz -thr ${thresh_it} vol00${j}_${t}_thr95.nii.gz
        done
    done
done

# Sanity check: number of suprathreshold voxels (used for the coverage in R)
fslstats "${VBM_DIR}/vol0036_pos_thr95.nii.gz" -V   # expect 540
fslstats "${JD_DIR}/vol0036_pos_thr95.nii.gz"  -V   # expect 1265


#### Part 2: maps for visualisation only #####
# Within the grey-matter mask, each split is z-scored, resampled to 0.5 mm and then thresholded at the 95th percentile
for DIR in "${VBM_DIR}" "${JD_DIR}"; do
    cd "${DIR}"
    for j in 36; do
        for t in pos neg; do
            # z-score within the GM mask
            fslmaths vol00${j}_${t}.nii.gz -mas ${GM} -bin vol00${j}_${t}_mask.nii.gz
            mean_val=$(fslstats vol00${j}_${t}.nii.gz -k vol00${j}_${t}_mask.nii.gz -M)
            std_val=$(fslstats vol00${j}_${t}.nii.gz -k vol00${j}_${t}_mask.nii.gz -S)
            fslmaths vol00${j}_${t}.nii.gz -sub ${mean_val} -div ${std_val} \
                     -mas vol00${j}_${t}_mask.nii.gz vol00${j}_z_${t}.nii.gz

            # resample to 0.5 mm, then threshold at the 95th percentile
            flirt -applyisoxfm 0.5 -in vol00${j}_z_${t}.nii.gz -ref ${MNI_REF} \
                  -out vol00${j}_z_${t}_0.5mm.nii.gz
            thresh_it=$(fslstats vol00${j}_z_${t}_0.5mm.nii.gz -P 95)
            fslmaths vol00${j}_z_${t}_0.5mm.nii.gz -thr ${thresh_it} vol00${j}_z_${t}_0.5mm_thr95.nii.gz
        done
    done
done

# View
fsleyes ${MNI_REF} ${VBM_DIR}/vol0036_z_pos_0.5mm_thr95.nii.gz ${VBM_DIR}/vol0036_z_neg_0.5mm_thr95.nii.gz
fsleyes ${MNI_REF} ${JD_DIR}/vol0036_z_pos_0.5mm_thr95.nii.gz  ${JD_DIR}/vol0036_z_neg_0.5mm_thr95.nii.gz