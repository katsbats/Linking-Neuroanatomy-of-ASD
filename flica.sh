##### Linked ICA (FLICA) on VBM, JD, CT and PA ####
# Main analysis: 150 ICs, second-filter sample (N = 955), 1500 iterations
# We are using the environment that Alberto defined in his Flica folder. This has been saved as a conda environment as flica_env

### for 250 ICs, full sample, 3000 iterations ### (first try)
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 250 -maxits 3000 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/250ica \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/wholesample
  
#final decomponsition: 
### for 150 ICs, full sample, 1500 iterations ###
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 150 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_wholesample \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/wholesample

### first filter ### (based on subject dominance) ###
### for 150 ICs, first filter, 1500 iterations ###
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 150 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_firstfilter \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/first_filter
   
### second filter (based on subject dominance) ###
####for 150 ICs, second filter, 1500 iterations ####
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 150 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/second_filter


### Created to test robustness of model order ###

### for 160 ICs, second filter, 1500 iterations ###
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 160 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/160ica_secondfilter \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/second_filter
  
### for 140 ICs, second filter, 1500 iterations ###
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 140 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/140ica_secondfilter \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/second_filter

