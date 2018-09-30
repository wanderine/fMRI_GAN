close all
clear all
clc

addpath('/home/andek67/Research_projects/nifti_matlab')

cd ds000221_R1.0.0

directories = dir;

for subject = 1:250
    
    subject
    
    subjectname = directories(subject+2).name
    
    try	

		nii = load_untouch_nii([subjectname '/ses-01/fmap/' subjectname '_ses-01_acq-GEfmap_run-01_fieldmap.nii.gz']);
	    fieldmap = double(nii.img);
	    [sy sx sz] = size(fieldmap);

	    nii = load_untouch_nii([subjectname '/ses-01/func/' subjectname '_ses-01_task-rest_acq-AP_run-01_bold.nii.gz']);
	    fMRI = double(nii.img);

		nii = load_untouch_nii([subjectname '/ses-01/fmap/' subjectname '_ses-01_acq-GEfmap_run-01_magnitude1_brain_mask_e.nii.gz']);
	    mask = double(nii.img);
    	
		for slice = (round(sz/2)-10) : (round(sz/2)+10)

	        %slice

	        sfieldmap = fieldmap(:,:,slice) .* (mask(:,:,slice) > 0);
			sfieldmap = sfieldmap + abs(min(sfieldmap(:))) .* (mask(:,:,slice) > 0);
	        sfieldmap = flipud(sfieldmap');    
	        imwrite(uint16(sfieldmap*30),['../trainingData/subject_' num2str(subject) '_fieldmap_slice_' num2str(slice) '.png'],'png','BitDepth',16);    
	   
	        sfMRI = fMRI(:,:,slice,1);
	        sfMRI = flipud(sfMRI');    
	        imwrite(uint16(sfMRI*50),['../trainingData/subject_' num2str(subject) '_fMRI_slice_' num2str(slice) '.png'],'png','BitDepth',16);    
	    end

	catch me
		disp('Skipping subject')
	end


     
end

cd ..

