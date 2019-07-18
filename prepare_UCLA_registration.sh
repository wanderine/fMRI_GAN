#!/bin/bash

clear

resolution=2mm

MaximumThreads=8 # Maximum number of parallel threads to use
threads=0

Study=UCLA

startDir=/home/andek/Research_projects/fMRI_GAN
dataDir=/home/andek/Research_projects/fMRI_GAN/data/${Study}

# Get one fMRI volume from each fMRI dataset

Subject=1
threads=0

echo "Extracting single fMRI volumes "

#for i in ${dataDir}/* ; do
#    echo "Processing Subject $Subject"
#    if ls $i/func/*task-rest*.nii.gz 1> /dev/null 2>&1; then
#        fslroi $i/func/*task-rest*.nii.gz $i/func/fMRI.nii.gz 0 1 &
#    else
#        echo "No fMRI found for Subject $Subject"
#    fi
#
#    ((threads++))
#    if [ $threads -eq "$MaximumThreads" ]; then
#        wait
#        threads=0
#    fi
#
#    ((Subject++))
#done

#wait

echo "Registering fMRI to T1 "

# Do T1 segmentations

Subject=1
threads=0

for i in ${dataDir}/* ; do
    echo "Processing Subject $Subject"

    #if ls $i/anat/*T1w.nii.gz 1> /dev/null 2>&1; then
    #    bet $i/anat/*T1w.nii.gz $i/anat/T1w_brain.nii.gz -R -f 0.3 &
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

    #if [ -f "$i/anat/T1w_brain.nii.gz" ]; then
    #    cp $i/anat/*T1w.nii.gz ${dataDir}/brains/T1w_${SubjectID}.nii.gz
    #
    #    cp $i/anat/T1w_brain.nii.gz ${dataDir}/brains/T1w_brain_${SubjectID}.nii.gz
    #fi

    ((Subject++))
done



# Now do EPI T1 registrations

Subject=1
threads=0

for i in ${dataDir}/* ; do
    echo "Processing Subject $Subject"

    if ls $i/func/*task-rest*.nii.gz 1> /dev/null 2>&1; then

        epi_reg --epi=$i/func/fMRI.nii.gz --t1=$i/anat/*T1w.nii.gz --t1brain=$i/anat/T1w_brain.nii.gz --out=$i/func/epi_to_T1 &

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

    if ls $i/anat/T1w_brain.nii.gz 1> /dev/null 2>&1; then

        flirt -interp sinc -in $i/anat/T1w_brain.nii.gz -ref MNI_${resolution}_crop.nii.gz -out $i/anat/T1_MNI_${resolution}.nii.gz -omat $i/anat/T1_to_MNI_${resolution}.mat &

    else
        echo "No T1 found for Subject $Subject"
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

    if ls $i/func/*task-rest*.nii.gz 1> /dev/null 2>&1; then

        # A = fMRI, B = T1, C = MNI
        convert_xfm -omat $i/func/epi_to_MNI_${resolution}.mat -concat $i/anat/T1_to_MNI_${resolution}.mat $i/func/epi_to_T1.mat

        flirt -interp sinc -in $i/func/fMRI.nii.gz -ref MNI_${resolution}_crop.nii.gz -applyxfm -init $i/func/epi_to_MNI_${resolution}.mat -out $i/func/fMRI_MNI_${resolution}.nii.gz &

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

echo "Copying data "

Subject=1

for i in ${dataDir}/* ; do

    cp $i/func/fMRI_MNI_${resolution}.nii.gz ${dataDir}/MNI_${resolution}/${Study}_fMRI_${Subject}.nii.gz 

    cp $i/anat/T1_MNI_${resolution}.nii.gz ${dataDir}/MNI_${resolution}/${Study}_T1_${Subject}.nii.gz 

    ((Subject++))
	
done


# How to create cropped MNI volumes


# fslroi MNI152_T1_2mm_brain.nii.gz MNI_2mm_crop.nii.gz 8 76 12 88 18 60

# fslroi MNI152_T1_1mm_brain.nii.gz MNI_1mm_crop.nii.gz 15 152 21 180 36 120


