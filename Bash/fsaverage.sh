export SUBJECTS_DIR="/mnt/methlab-drive/methlab/Students/Jente/OutputABIDE1"
OUTDIR="/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/OutputFreeSurfer/fsaverageABIDE1"

ls $SUBJECTS_DIR | grep -v fsaverage | parallel -j 8 '

mkdir -p '"$OUTDIR"'/{}

for hemi in lh rh; do
  for meas in area thickness; do

    echo "Processing {} $hemi $meas"

    mris_preproc \
      --hemi $hemi \
      --meas $meas \
      --target fsaverage \
      --fwhm 10 \
      --s {} \
      --out '"$OUTDIR"'/{}/${hemi}.${meas}.fwhm10.fsaverage.mgh

  done
done

'

export SUBJECTS_DIR="/mnt/methlab-drive/methlab/Students/Jente/OutputABIDE2"
OUTDIR="/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/OutputFreeSurfer/fsaverageABIDE2"

ls $SUBJECTS_DIR | grep -v fsaverage | parallel -j 8 '

mkdir -p '"$OUTDIR"'/{}

for hemi in lh rh; do
  for meas in area thickness; do

    echo "Processing {} $hemi $meas"

    mris_preproc \
      --hemi $hemi \
      --meas $meas \
      --target fsaverage \
      --fwhm 10 \
      --s {} \
      --out '"$OUTDIR"'/{}/${hemi}.${meas}.fwhm10.fsaverage.mgh

  done
done

'


#for the extra ones 
export SUBJECTS_DIR="/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/OutputFreeSurfer/FreeSurferUSM+UM"
OUTDIR="/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/OutputFreeSurfer/fsaverageABIDE2"

ls $SUBJECTS_DIR | grep -v fsaverage | parallel -j 8 '

mkdir -p '"$OUTDIR"'/{}

for hemi in lh rh; do
  for meas in area thickness; do

    echo "Processing {} $hemi $meas"

    mris_preproc \
      --hemi $hemi \
      --meas $meas \
      --target fsaverage \
      --fwhm 10 \
      --s {} \
      --out '"$OUTDIR"'/{}/${hemi}.${meas}.fwhm10.fsaverage.mgh

  done
done

'
