#!/bin/bash

clear

resolution=1mm

MaximumThreads=8 # Maximum number of parallel threads to use
threads=0

#Study=Beijing
Study=Cambridge

startDir=/home/andek/Research_projects/fMRI_GAN/data/fcon1000

# Get one fMRI volume from each fMRI dataset
echo "Extracting single fMRI volumes "

for i in ${startDir}/${Study}/* ; do

	fslroi $i/func/rest.nii.gz $i/func/fMRI.nii.gz 0 1

done

# Do interpolation in parallel
echo "Registering fMRI to T1 "

# First to EPI T1 registrations

Subject=1
threads=0

for i in ${startDir}/${Study}/* ; do

	echo "Processing Subject $Subject"

	epi_reg --epi=$i/func/fMRI.nii.gz --t1=$i/anat/mprage_anonymized.nii.gz --t1brain=$i/anat/mprage_skullstripped.nii.gz --out=$i/func/epi_to_T1 &

	((threads++))

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

	((Subject++))

done

wait

# Now do T1 MNI registrations

Subject=1
threads=0

for i in ${startDir}/${Study}/* ; do

	echo "Processing Subject $Subject"


	flirt -interp sinc -in $i/anat/mprage_skullstripped.nii.gz -ref MNI_${resolution}_crop.nii.gz -out $i/anat/mprage_MNI_${resolution}.nii.gz -omat $i/anat/T1_to_MNI_${resolution}.mat &
	
	((threads++))

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

	((Subject++))

done

wait


# Now combine transformations to MNI
Subject=1
threads=0

for i in ${startDir}/${Study}/* ; do

	echo "Processing Subject $Subject"		

	# A = fMRI, B = T1, C = MNI
	convert_xfm -omat $i/func/epi_to_MNI_${resolution}.mat -concat $i/anat/T1_to_MNI_${resolution}.mat $i/func/epi_to_T1.mat

	flirt -interp sinc -in $i/func/fMRI.nii.gz -ref MNI_${resolution}_crop.nii.gz -applyxfm -init $i/func/epi_to_MNI_${resolution}.mat -out $i/func/fMRI_MNI_${resolution}.nii.gz &

	((threads++))

	if [ $threads -eq "$MaximumThreads" ]; then
		wait
		threads=0
	fi

	((Subject++))

done

wait

echo "Copying data "

Subject=1

for i in ${startDir}/${Study}/* ; do

	cp $i/func/fMRI_MNI_${resolution}.nii.gz ${startDir}/T1_fMRI_128/${Study}_fMRI_${Subject}.nii.gz 

	cp $i/anat/mprage_MNI_${resolution}.nii.gz ${startDir}/T1_fMRI_128/${Study}_T1_${Subject}.nii.gz 

	((Subject++))
	
done


#scp data/fcon1000/T1_fMRI_64/Beijing_fMRI_* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_64/trainA

#scp data/fcon1000/T1_fMRI_64/Beijing_T1_* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_64/trainB

#scp data/fcon1000/T1_fMRI_64/Beijing_fMRI_10* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_64/testA

#scp data/fcon1000/T1_fMRI_64/Beijing_T1_10* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_64/testB


#scp data/fcon1000/T1_fMRI_128/Beijing_fMRI_* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_128/trainA

#scp data/fcon1000/T1_fMRI_128/Beijing_T1_* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_128/trainB

#scp data/fcon1000/T1_fMRI_128/Beijing_fMRI_10* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_128/testA

#scp data/fcon1000/T1_fMRI_128/Beijing_T1_10* andek67@stoor.imt.liu.se:/home/andek67/Research_projects/CycleGAN3D/data/fcon1000_128/testB


# How to create cropped MNI volumes


# fslroi MNI152_T1_2mm_brain.nii.gz MNI_2mm_crop.nii.gz 8 76 12 88 18 60

# fslroi MNI152_T1_1mm_brain.nii.gz MNI_1mm_crop.nii.gz 15 152 21 180 36 120


