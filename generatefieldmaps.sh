#!/bin/bash

startDirectory=/flush2/andek67/Data/MPI

MaximumThreads=40
threads=0

# Loop over all subjects
for i in /flush2/andek67/Data/MPI/ds000221_R1.0.0/* ; do

	# Go to current directory
	cd $i
	# Get subject name
   	Subject=${PWD##*/}
    echo "Processing" $Subject
	# Go back to original directory
	cd $startDirectory

	if [ -e ${i}/ses-01 ]; then	
		fsl_prepare_fieldmap SIEMENS  ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_phasediff.nii.gz ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_magnitude1_brain.nii.gz   ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_fieldmap.nii.gz 2.46 &
		((threads++))
	fi

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

	

done


