#!/bin/bash

startDirectory=/flush2/andek67/Data/MPI

MaximumThreads=40
threads=0

# Loop over all subjects and segment brain
for i in /flush2/andek67/Data/MPI/ds000221_R1.0.0/* ; do

	# Go to current directory
	cd $i
	# Get subject name
   	Subject=${PWD##*/}
    echo "Processing" $Subject
	# Go back to original directory
	cd $startDirectory

	if [ -e ${i}/ses-01 ]; then	
		bet ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_magnitude1.nii.gz ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_magnitude1_brain.nii.gz -m  &
		((threads++))
	fi

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

done

threads=0

# Now erode brain masks to get rid of noise voxels
for i in /flush2/andek67/Data/MPI/ds000221_R1.0.0/* ; do

	# Go to current directory
	cd $i
	# Get subject name
   	Subject=${PWD##*/}
    echo "Processing" $Subject
	# Go back to original directory
	cd $startDirectory

	if [ -e ${i}/ses-01 ]; then	
		fslmaths ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_magnitude1_brain_mask.nii.gz -ero ${i}/ses-01/fmap/${Subject}_ses-01_acq-GEfmap_run-01_magnitude1_brain_mask_e.nii.gz   &
		((threads++))
	fi

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

done
