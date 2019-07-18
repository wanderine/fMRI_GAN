#!/bin/bash

# subjects with bad brain segmentations from BET
# 10045 10047 10092 10244 10272

clear

resolution=2mm

MaximumThreads=8 # Maximum number of parallel threads to use
threads=0

Study=MPI

#mkdir /home/andek/Research_projects/fMRI_GAN/data/${Study}

startDir=/home/andek/Research_projects/fMRI_GAN
dataDir=/home/andek/Research_projects/fMRI_GAN/data/${Study}

# Get one fMRI volume from each fMRI dataset

Subject=1
threads=0

echo "Extracting single fMRI volumes "

#for i in ${dataDir}/* ; do
    #echo "Processing Subject $Subject"
    #if ls $i/ses-01/func/*.nii.gz 1> /dev/null 2>&1; then
    #    fslroi $i/ses-01/func/*.nii.gz $i/ses-01/func/fMRI.nii.gz 0 1
    #else
    #    echo "No fMRI found for Subject $Subject"
    #fi

    #((threads++))
    #if [ $threads -eq "$MaximumThreads" ]; then
    #    wait
    #    threads=0
    #fi

    #((Subject++))
#done

wait

echo "Registering fMRI to T1 "

# First mask T1 volume

Subject=1

for i in ${dataDir}/* ; do
    echo "Processing Subject $Subject"

    if ls $i/ses-01/anat/*inv-2_mp2rage.nii.gz 1> /dev/null 2>&1; then
	echo "Found inv-2-mp2rage found for Subject $Subject"

        #fslmaths $i/ses-01/anat/*inv-2_mp2rage.nii.gz -thr 100 $i/ses-01/anat/mask.nii.gz

        #fslmaths $i/ses-01/anat/*acq-mp2rage_T1w.nii.gz -mul $i/ses-01/anat/mask.nii.gz $i/ses-01/anat/T1w.nii.gz 
    else
        echo "No inv-2-mp2rage found for Subject $Subject"
    fi
    ((Subject++))
done

# Do T1 segmentations

Subject=1
threads=0

for i in ${dataDir}/* ; do
    echo "Processing Subject $Subject"

    #if [ -f "$i/ses-01/anat/T1w.nii.gz" ]; then
    #    bet $i/ses-01/anat/T1w.nii.gz $i/ses-01/anat/T1w_brain.nii.gz -R -f 0.25 &
    #fi

    ((threads++))
    if [ $threads -eq "$MaximumThreads" ]; then
        wait
        threads=0
    fi
    ((Subject++))
done

wait

Subject=1

for i in ${dataDir}/* ; do

    # Go to current directory
    cd $i
    # Get subject name
    SubjectID=${PWD##*/}
    echo "Processing" $SubjectID
    # Go back to original directory
    cd ${startDir}

    #if [ -f "$i/ses-01/anat/T1w.nii.gz" ]; then
    #    cp $i/ses-01/anat/T1w.nii.gz ${dataDir}/brains/T1w_${SubjectID}.nii.gz
    #
    #    cp $i/ses-01/anat/T1w_brain.nii.gz ${dataDir}/brains/T1w_brain_${SubjectID}.nii.gz
    #fi

    ((Subject++))
done



# Now do EPI T1 registrations

Subject=1
threads=0

for i in ${dataDir}/* ; do
    echo "Processing Subject $Subject"

    if [ -f "$i/ses-01/func/fMRI.nii.gz" ]; then

        epi_reg --epi=$i/ses-01/func/fMRI.nii.gz --t1=$i/ses-01/anat/T1w.nii.gz --t1brain=$i/ses-01/anat/T1w_brain.nii.gz --out=$i/ses-01/func/epi_to_T1 &

    else
        echo "No fMRI found for Subject $Subject"
    fi

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

for i in ${dataDir}/* ; do

    echo "Processing Subject $Subject"

    if [ -f "$i/ses-01/anat/T1w.nii.gz" ]; then

        flirt -interp sinc -in $i/ses-01/anat/T1w_brain.nii.gz -ref MNI_${resolution}_crop.nii.gz -out $i/ses-01/anat/T1_MNI_${resolution}.nii.gz -omat $i/ses-01/anat/T1_to_MNI_${resolution}.mat &

    fi
	
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

for i in ${dataDir}/* ; do

    echo "Processing Subject $Subject"		

    if [ -f "$i/ses-01/func/fMRI.nii.gz" ]; then

        # A = fMRI, B = T1, C = MNI
        convert_xfm -omat $i/ses-01/func/epi_to_MNI_${resolution}.mat -concat $i/ses-01/anat/T1_to_MNI_${resolution}.mat $i/ses-01/func/epi_to_T1.mat

        flirt -interp sinc -in $i/ses-01/func/fMRI.nii.gz -ref MNI_${resolution}_crop.nii.gz -applyxfm -init $i/ses-01/func/epi_to_MNI_${resolution}.mat -out $i/ses-01/func/fMRI_MNI_${resolution}.nii.gz &

    fi

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

for i in ${dataDir}/* ; do

    if [ -f "$i/ses-01/func/fMRI.nii.gz" ]; then
        cp $i/ses-01/func/fMRI_MNI_${resolution}.nii.gz ${dataDir}/MNI_${resolution}/${Study}_fMRI_${Subject}.nii.gz 
    fi

    if [ -f "$i/ses-01/anat/T1w.nii.gz" ]; then
        cp $i/ses-01/anat/T1_MNI_${resolution}.nii.gz ${dataDir}/MNI_${resolution}/${Study}_T1_${Subject}.nii.gz 
    fi

    ((Subject++))
	
done


# How to create cropped MNI volumes


# fslroi MNI152_T1_2mm_brain.nii.gz MNI_2mm_crop.nii.gz 8 76 12 88 18 60

# fslroi MNI152_T1_1mm_brain.nii.gz MNI_1mm_crop.nii.gz 15 152 21 180 36 120


