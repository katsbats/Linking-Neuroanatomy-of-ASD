
#### preprocessing steps for VBM prior to FLICA ####
output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/ABIDEu30_final_subs.txt`; do  #created at the end of the exclusion_of_subs script
ls  $output_dir/Input/ABIDE_*/*_${i}/mri/s8mwp1anat.nii \
    $output_dir/Input/ABIDE_*/*_${i}/mri/s8mwp1mprage.nii; 
done > $output_dir/Data/Groupmask/FSL_redo/wholesample/VBMs8.txt 

fslmerge -t $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8.nii.gz `cat $output_dir/Data/Groupmask/FSL_redo/wholesample/VBMs8.txt`
    # for every subject in the list extract their mwp1anat file and make VBM file
    # then merge these into one 4D file which is merged_VBM

# we must now change spm MNI space to fsl MNI space. take first volume, run flirt to fsl MNI brain (6 dof, --omat; NO applyxfm). 
# Take omat, edit in gedit, set on-diagonal to 1, off-diagonal to 0, don't change last column, save. 
# this was done in a separate script (see MNI_transformation) and saved as group2mni.mat
#Run flirt --in 4dfile --ref FSLMNI --out output --applyxfm --init saved.mat

#changing spm MNI space to fsl MNI space (only do once)
#flirt -in $output_dir/Input/ABIDE_I/Caltech_51456/mri/s8mwp1mprage.nii \
#      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
#      -omat $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat \
#      -dof 6

flirt -in $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8.nii.gz \
      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
      -out $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_FSL.nii.gz \
      -applyxfm \
      -init $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat

# downsample to 4mm
flirt -applyisoxfm 4 \
      -in $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_FSL.nii.gz \
      -ref $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_FSL.nii.gz \
      -out $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_4mmFSL.nii.gz
      

# make group mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_4mmFSL.nii.gz -abs -bin -Tmin $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_s8_4mmFSL.nii.gz
    ##from Alberto: echo fslmaths ${output_image} -mul ${mask} ${output_image} 

# multiply group mask with MNI mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_s8_4mmFSL.nii.gz -mul $output_dir/Data/MNImask/MNI_mask_resampled4mm.nii $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz

# grey matter mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_4mmFSL.nii.gz -Tmean $output_dir/Data/Groupmask/FSL_redo/wholesample/mean_GM_s8_4mmFSL.nii.gz #voxelwise mean GM image across all subjects

fslmaths $output_dir/Data/Groupmask/FSL_redo/wholesample/mean_GM_s8_4mmFSL.nii.gz -thr 0.2 -bin $output_dir/Data/Groupmask/FSL_redo/wholesample/group_GM_mask_s8_4mm02FSL.nii.gz #binary group GM mask over all subjects

# now we multiply the GM mask with our previous mask to ensure we only have GM
fslmaths $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz -mul $output_dir/Data/Groupmask/FSL_redo/wholesample/group_GM_mask_s8_4mm02FSL.nii.gz $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_GM_s8_4mm02FSL.nii.gz


# multiply with the 4mm 4d file from before, because the individual subjects are in 1.5mm
fslmaths $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_4mmFSL.nii.gz -mul $output_dir/Data/Groupmask/FSL_redo/wholesample/group_mask_VBM_MNI_masked_GM_s8_4mm02FSL.nii.gz $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_4mm_finalmaskedFSL.nii.gz

fslinfo $output_dir/Data/Groupmask/FSL_redo/wholesample/merged_VBM_s8_4mm_finalmaskedFSL.nii.gz

### then we run our first LICA 


#the following two filters are after extracting highly dominant subjects (see subject dominance script). The procedure was repeated twice

#### first filter ###
output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/FSL_first_filter.txt`; do  
ls  $output_dir/Input/ABIDE_*/*_${i}/mri/s8mwp1anat.nii \
    $output_dir/Input/ABIDE_*/*_${i}/mri/s8mwp1mprage.nii; 
done > $output_dir/Data/Groupmask/FSL_redo/first_filter/VBMs8.txt 

fslmerge -t $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8.nii.gz `cat $output_dir/Data/Groupmask/FSL_redo/first_filter/VBMs8.txt`

#changing spm MNI space to fsl MNI space 

flirt -in $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8.nii.gz \
      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
      -out $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_FSL.nii.gz \
      -applyxfm \
      -init $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat

# downsample
flirt -applyisoxfm 4 \
      -in $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_FSL.nii.gz \
      -ref $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_FSL.nii.gz \
      -out $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mmFSL.nii.gz
      
fslinfo $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mmFSL.nii.gz | grep pixdim

# make group mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mmFSL.nii.gz -abs -bin -Tmin $output_dir/Data/Groupmask/FSL_redo/first_filter/group_mask_VBM_s8_4mmFSL.nii.gz
     ##from Alberto: echo fslmaths ${output_image} -mul ${mask} ${output_image} 
# multiply group mask with MNI mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/first_filter/group_mask_VBM_s8_4mmFSL.nii.gz -mul $output_dir/Data/MNImask/MNI_mask_resampled4mm.nii $output_dir/Data/Groupmask/FSL_redo/first_filter/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz

# grey matter mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mmFSL.nii.gz -Tmean $output_dir/Data/Groupmask/FSL_redo/first_filter/mean_GM_s8_4mmFSL.nii.gz #voxelwise mean GM image across all subjects

fslmaths $output_dir/Data/Groupmask/FSL_redo/first_filter/mean_GM_s8_4mmFSL.nii.gz -thr 0.2 -bin $output_dir/Data/Groupmask/FSL_redo/first_filter/group_GM_mask_s8_4mm02FSL.nii.gz #binary group GM mask over all subjects

#now we multiply the GM mask with our previous mask to ensure we only have GM
fslmaths $output_dir/Data/Groupmask/FSL_redo/first_filter/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz -mul $output_dir/Data/Groupmask/FSL_redo/first_filter/group_GM_mask_s8_4mm02FSL.nii.gz $output_dir/Data/Groupmask/FSL_redo/first_filter/group_mask_VBM_MNI_masked_GM_s8_4mm02FSL.nii.gz


#multiply with the 4mm 4d file from before, because the individual subjects are in 1.5mm
fslmaths $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mmFSL.nii.gz -mul $output_dir/Data/Groupmask/FSL_redo/first_filter/group_mask_VBM_MNI_masked_GM_s8_4mm02FSL.nii.gz $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mm_finalmaskedFSL.nii.gz

fslinfo $output_dir/Data/Groupmask/FSL_redo/first_filter/merged_VBM_s8_4mm_finalmaskedFSL.nii.gz



#### second filter ###

output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/FSL_second_filter.txt`; do  
ls  $output_dir/Input/ABIDE_*/*_${i}/mri/s8mwp1anat.nii \
    $output_dir/Input/ABIDE_*/*_${i}/mri/s8mwp1mprage.nii; 
done > $output_dir/Data/Groupmask/FSL_redo/second_filter/VBMs8.txt 

fslmerge -t $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8.nii.gz `cat $output_dir/Data/Groupmask/FSL_redo/second_filter/VBMs8.txt`

# transform mni space
flirt -in $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8.nii.gz \
      -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz \
      -out $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_FSL.nii.gz \
      -applyxfm \
      -init $output_dir/Data/Groupmask/FSL_redo/wholesample/group2mni.mat

 # downsample
flirt -applyisoxfm 4 \
      -in $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_FSL.nii.gz \
      -ref $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_FSL.nii.gz \
      -out $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mmFSL.nii.gz
      
fslinfo $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mmFSL.nii.gz | grep pixdim


# make group mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mmFSL.nii.gz -abs -bin -Tmin $output_dir/Data/Groupmask/FSL_redo/second_filter/group_mask_VBM_s8_4mmFSL.nii.gz

# multiply group mask with MNI mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/second_filter/group_mask_VBM_s8_4mmFSL.nii.gz -mul $output_dir/Data/MNImask/MNI_mask_resampled4mm.nii $output_dir/Data/Groupmask/FSL_redo/second_filter/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz

# grey matter mask
fslmaths $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mmFSL.nii.gz -Tmean $output_dir/Data/Groupmask/FSL_redo/second_filter/mean_GM_s8_4mmFSL.nii.gz #voxelwise mean GM image across all subjects

fslmaths $output_dir/Data/Groupmask/FSL_redo/second_filter/mean_GM_s8_4mmFSL.nii.gz -thr 0.2 -bin $output_dir/Data/Groupmask/FSL_redo/second_filter/group_GM_mask_s8_4mm02FSL.nii.gz #binary group GM mask over all subjects

# now we multiply the GM mask with our previous mask to ensure we only have GM
fslmaths $output_dir/Data/Groupmask/FSL_redo/second_filter/group_mask_VBM_MNI_masked_s8_4mmFSL.nii.gz -mul $output_dir/Data/Groupmask/FSL_redo/second_filter/group_GM_mask_s8_4mm02FSL.nii.gz $output_dir/Data/Groupmask/FSL_redo/second_filter/group_mask_VBM_MNI_masked_GM_s8_4mm02FSL.nii.gz


# multiply with the 4mm 4d file from before, because the individual subjects are in 1.5mm
fslmaths $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mmFSL.nii.gz -mul $output_dir/Data/Groupmask/FSL_redo/second_filter/group_mask_VBM_MNI_masked_GM_s8_4mm02FSL.nii.gz $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mm_finalmaskedFSL.nii.gz

fslinfo $output_dir/Data/Groupmask/FSL_redo/second_filter/merged_VBM_s8_4mm_finalmaskedFSL.nii.gz
