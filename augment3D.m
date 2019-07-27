close all
clear all
clc

addpath('/home/andek67/Research_projects/nifti_matlab')

study = 'Beijing';

datapath = 'data/fcon1000_64_Beijing/';
augmentedDatapath = 'data/fcon1000_64_Beijing_augmented/';

numberOfTrainingSubjects = 160;

nii = load_nii([datapath '/trainA/' study '_fMRI_' num2str(1) '.nii.gz']);
volume = double(nii.img);
[sy sx sz] = size(volume);        

[xi, yi, zi] = meshgrid(-(sx-1)/2:(sx-1)/2,-(sy-1)/2:(sy-1)/2, -(sz-1)/2:(sz-1)/2);

for subject = 1:numberOfTrainingSubjects
    
    subject
    
    for augmentation = 1:10
        
        x_rotation = 5 * randn;
        y_rotation = 5 * randn;
        z_rotation = 5 * randn;
        
        R_x = [1                        0                           0;
               0                        cos(x_rotation*pi/180)      -sin(x_rotation*pi/180);
               0                        sin(x_rotation*pi/180)      cos(x_rotation*pi/180)];
        
        R_y = [cos(y_rotation*pi/180)   0                           sin(y_rotation*pi/180);
               0                        1                           0;
               -sin(y_rotation*pi/180)  0                           cos(y_rotation*pi/180)];
        
        R_z = [cos(z_rotation*pi/180)   -sin(z_rotation*pi/180)     0;
               sin(z_rotation*pi/180)   cos(z_rotation*pi/180)      0;
               0                        0                           1];
        
        Rotation_matrix = R_x * R_y * R_z;
        Rotation_matrix = Rotation_matrix(:);
        
        rx_r = zeros(sy,sx,sz);
        ry_r = zeros(sy,sx,sz);
        rz_r = zeros(sy,sx,sz);
        
        rx_r(:) = [xi(:) yi(:) zi(:)]*Rotation_matrix(1:3);
        ry_r(:) = [xi(:) yi(:) zi(:)]*Rotation_matrix(4:6);
        rz_r(:) = [xi(:) yi(:) zi(:)]*Rotation_matrix(7:9);
        
        %----
        
        nii = load_nii([datapath '/trainA/' study '_fMRI_' num2str(subject) '.nii.gz']);
        volume = double(nii.img);
        
        % Add rotation and translation at the same time
        newVolume = interp3(xi,yi,zi,volume,rx_r,ry_r,rz_r,'cubic');
        % Remove 'not are numbers' from interpolation
        newVolume(isnan(newVolume)) = 0;
        
        newFile.hdr = nii.hdr;
        newFile.hdr.dime.datatype = 16;
        newFile.hdr.dime.bitpix = 16;
        newFile.img = single(newVolume);
        
        save_nii(newFile,[augmentedDatapath '/trainA/' study '_fMRI_' num2str(subject) '_augmented_' num2str(augmentation) '.nii.gz']);
        
        %----
        
        nii = load_nii([datapath '/trainB/' study '_T1_' num2str(subject) '.nii.gz']);
        volume = double(nii.img);
        
        % Add rotation and translation at the same time
        newVolume = interp3(xi,yi,zi,volume,rx_r,ry_r,rz_r,'cubic');
        % Remove 'not are numbers' from interpolation
        newVolume(isnan(newVolume)) = 0;
        
        newFile.hdr = nii.hdr;
        newFile.hdr.dime.datatype = 16;
        newFile.hdr.dime.bitpix = 16;
        newFile.img = single(newVolume);
        
        save_nii(newFile,[augmentedDatapath '/trainB/' study '_T1_' num2str(subject) '_augmented_' num2str(augmentation) '.nii.gz']);
        
        
    end
end

