#!/bin/bash

clear

MaximumThreads=8 # Maximum number of parallel downloads to use
threads=0

Study=Beijing
#Study=Cambridge

startDir=/home/andek/Research_projects/fMRI_GAN/data/fcon1000

# Get one fMRI volume from each fMRI dataset
echo "Extracting single fMRI volumes "

for i in ${startDir}/${Study}/* ; do

	fslroi $i/func/rest.nii.gz $i/func/fMRI.nii.gz 0 1

done

# Do interpolation in parallel
echo "Interpolating fMRI to T1 "

for i in ${startDir}/${Study}/* ; do

	# Change voxel size and volume size to T1 volume
	flirt -interp sinc -in $i/func/fMRI.nii.gz -ref $i/anat/mprage_skullstripped.nii.gz -applyxfm -init id.mtx -out $i/func/fMRI_T1.nii.gz &

	((threads++))

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

done

wait

Subject=1

echo "Copying data "

for i in ${startDir}/${Study}/* ; do

	cp $i/func/fMRI_T1.nii.gz ${startDir}/T1_fMRI/${Study}_fMRI_${Subject}.nii.gz 

	cp $i/anat/mprage_skullstripped.nii.gz ${startDir}/T1_fMRI/${Study}_T1_${Subject}.nii.gz 

	((Subject++))
	
done



