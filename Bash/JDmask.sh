#### preprocessing steps for JD prior to FLICA ####
output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/ABIDEu30_final_subs.txt`; do 
ls  $output_dir/Input/ABIDE_*/*_${i}/mri/wj_anat.nii \
    $output_dir/Input/ABIDE_*/*_${i}/mri/wj_mprage.nii; 
done > $output_dir/Data/JDmask/5FSL_redo/wholesample/JD.txt 

fslmerge -t $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD.nii.gz `cat $output_dir/Data/JDmask/5FSL_redo/wholesample/JD.txt`

#use the one we already made
flirt -in $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD.nii.gz \
      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
      -out $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD_FSL.nii.gz \
      -applyxfm \
      -init $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat

# then downsample 
flirt -applyisoxfm 4 \
      -in $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD_FSL.nii.gz \
      -ref $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD_FSL.nii.gz \
      -out $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD_4mmFSL.nii.gz

# multiply with mask
fslmaths $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_JD_4mmFSL.nii.gz \
         -mul $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz \
         $output_dir/Data/JDmask/5FSL_redo/wholesample/merged_masked_JD_4mmFSL.nii.gz


### then we run our first LICA 

#the following two filters are after extracting highly dominant subjects (see subject dominance script). The procedure was repeated twice
### first filter ###

output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/FSL_first_filter.txt`; do 
ls  $output_dir/Input/ABIDE_*/*_${i}/mri/wj_anat.nii \
    $output_dir/Input/ABIDE_*/*_${i}/mri/wj_mprage.nii; 
done > $output_dir/Data/JDmask/5FSL_redo/first_filter/JD.txt 

fslmerge -t $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD.nii.gz `cat $output_dir/Data/JDmask/5FSL_redo/first_filter/JD.txt`

#use the one we already made
flirt -in $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD.nii.gz \
      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
      -out $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD_FSL.nii.gz \
      -applyxfm \
      -init $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat

# then downsample 
flirt -applyisoxfm 4 \
      -in $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD_FSL.nii.gz \
      -ref $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD_FSL.nii.gz \
      -out $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD_4mmFSL.nii.gz

# multiply with mask
fslmaths $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_JD_4mmFSL.nii.gz \
         -mul $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz \
         $output_dir/Data/JDmask/5FSL_redo/first_filter/merged_masked_JD_4mmFSL.nii.gz

# JD maps were masked with the group brain mask derived from the VBM data of the full sample.


### second filter ###
output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/FSL_second_filter.txt`; do 
ls  $output_dir/Input/ABIDE_*/*_${i}/mri/wj_anat.nii \
    $output_dir/Input/ABIDE_*/*_${i}/mri/wj_mprage.nii; 
done > $output_dir/Data/JDmask/5FSL_redo/second_filter/JD.txt 

fslmerge -t $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD.nii.gz `cat $output_dir/Data/JDmask/5FSL_redo/second_filter/JD.txt`

#use the one we already made
flirt -in $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD.nii.gz \
      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
      -out $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD_FSL.nii.gz \
      -applyxfm \
      -init $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat

# then downsample 
flirt -applyisoxfm 4 \
      -in $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD_FSL.nii.gz \
      -ref $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD_FSL.nii.gz \
      -out $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD_4mmFSL.nii.gz

# multiply with mask
fslmaths $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_JD_4mmFSL.nii.gz \
         -mul $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz \
         $output_dir/Data/JDmask/5FSL_redo/second_filter/merged_masked_JD_4mmFSL.nii.gz


