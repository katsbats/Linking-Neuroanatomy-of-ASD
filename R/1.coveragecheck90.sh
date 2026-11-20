# creating the 90% coverage check mask

output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# merge all files
for i in `cat $output_dir/Input/ABIDE_all_subs.txt`; do 
ls  $output_dir/Input/ABIDE_*/${i}/mri/mwp1anat.nii \
    $output_dir/Input/ABIDE_*/${i}/mri/mwp1mprage.nii; 
done > $output_dir/Data/VBM/VBM.txt 

fslmerge -t $output_dir/Data/VBM/merged_VBM.nii.gz `cat $output_dir/Data/VBM/VBM.txt`
    # for every subject in the list extract their mwp1anat file and make VBM file
    # then merge these into one 4D file which is merged_s4_VBM

#make group mask
fslmaths $output_dir/Data/VBM/merged_VBM.nii.gz -abs -bin -Tmin $output_dir/Data/VBM/group_mask_VBM.nii.gz
    # then we make absolute values, binary values and only includes voxels that everyone has


#multiply group mask with MNI mask
fslmaths $output_dir/Data/VBM/group_mask_VBM.nii.gz -mul $output_dir/Data/MNImask/MNI_mask_resampled1p5.nii $output_dir/Data/VBM/group_mask_VBM_MNI_masked.nii.gz
    # then we multiple the group mask with the MNI mask 


#coverage check
##count how many voxels (90%)
count_WholeBrain=$(fslstats $output_dir/Data/MNImask/MNI_mask_resampled1p5.nii -V | awk '{print $1}') 
WholeBrain=$(bc -l <<< "scale=5; $count_WholeBrain * 0.9") # 90% of voxels in the mask
echo $WholeBrain

##coverage 90%
less_than=0;
more_than=0;
for i in $(cat "$output_dir/Input/ABIDE_all_subs.txt"); do
  for img in \
    $output_dir/Input/ABIDE_*/${i}/mri/mwp1anat.nii \
    $output_dir/Input/ABIDE_*/${i}/mri/mwp1mprage.nii
  do
    [ -e "$img" ] || continue

    count=$(fslstats "$img" -k "$output_dir/Data/MNImask/MNI_mask_resampled1p5.nii" -V | awk '{print $1}') # How many voxels inside the MNI mask are non-zero in this subject?
    echo $count
    
    # Calculate percentage coverage
    perc=$(echo "scale=3; $count / $WholeBrain" | bc) # how close is participant to the 90% threshold
    echo $perc
    
    # Compare floating-point values using bc
    if (( $(echo "$count >= $WholeBrain" | bc -l) )); then #more than 90% coverage
        echo "$i has more than 90% coverage"
        more_than=$((more_than + 1))	
    else
        echo "$i has less than 90% coverage" #less than 90% coverage
        less_than=$((less_than + 1))
    fi

 done
done > $output_dir/Data/VBM/coverage_all_90_WholeBrain.txt

echo "Subjects with less than 90% coverage are: $less_than" >> $output_dir/Data/VBM/coverage_all_90_WholeBrain.txt
echo "Subjects with more than 90% coverage are: $more_than" >> $output_dir/Data/VBM/coverage_all_90_WholeBrain.txt




