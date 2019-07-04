close all
clear all
clc

study = 'Cambridge';

dirDataRoot = '/home/andek/Research_projects/fMRI_GAN/data/fcon1000/T1_fMRI/';

% Output folders
dirT1 = fullfile(dirDataRoot, 'T2F_T1_41');
dirfMRI = fullfile(dirDataRoot, 'T2F_fMRI_41');

if (~exist(dirT1, 'dir'))
    mkdir(dirT1);
end

if (~exist(dirfMRI, 'dir'))
    mkdir(dirfMRI);
end

% Slices to extract around the middle slice
selectedSlicesAroundMid = 1 * (-20:20); % 41 slices across the middle

% File lists
listT1 = dir(fullfile(dirDataRoot, [study '*T1*.nii.gz'])); % All subjects
listfMRI = dir(fullfile(dirDataRoot, [study '*fMRI*.nii.gz'])); % All subjects

maxVal = zeros(length(listT1),2);
medianStep = zeros(length(listT1),2);
quant095 = zeros(length(listT1),2);
quant0995 = zeros(length(listT1),2);

T1sizes = zeros(length(listT1),3);

% Read all volumes once, to get max sizes

for i = 1:length(listT1)  

    fileT1 = fullfile(dirDataRoot, listT1(i).name);
    filefMRI = fullfile(dirDataRoot, listfMRI(i).name);

    vol = double(niftiread(fileT1));
    [sy sx sz] = size(vol);
        
    T1sizes(i,:) = [sy sx sz];
        
end

maxSx = max(T1sizes(:,1));
maxSy = max(T1sizes(:,2));

% Set targetdim once
% (to avoid different sizes over subjects)
targetDim = ceil([maxSy maxSx]/4)*4;

% Now read volumes again
for i = 1:length(listT1)  
    fprintf('i = %d \n', i)
    
    % T1 and fMRI
    fileT1 = fullfile(dirDataRoot, listT1(i).name);
    filefMRI = fullfile(dirDataRoot, listfMRI(i).name);

    %% T1
    % Load T1 data
    vol = double(niftiread(fileT1));
    
    maxVal(i,1) = max(vol(:));
    quant095(i,1) = quantile(vol(vol~=0), 0.95);
    quant0995(i,1) = quantile(vol(vol~=0), 0.995);
    
    % Calculate center of mass
    [sy sx sz] = size(vol);
    T1sizes(i,:) = size(vol);
    totalMass = sum(vol(:));
    rx = 0; ry = 0; rz = 0;
    for x = 1:sx
        for y = 1:sy
            for z = 1:sz
                rx = rx + vol(y,x,z) * x;
                ry = ry + vol(y,x,z) * y;
                rz = rz + vol(y,x,z) * z;
            end
        end
    end
    rx = rx / totalMass;
    ry = ry / totalMass;
    rz = rz / totalMass;
        
    midSliceZ = round(rz);        
    
    % Extract axial slices around the middle slice
    slices = midSliceZ + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(:,:,slices(j)));
    
        % Convert and rearrange dimensions
        %im = uint8((im ./ maxVal(i,1)) .* 255);
        im = uint8((im ./ quant0995(i,1)) .* 255);
        im = rot90(im',2);

        % Make sure that image size is divisible by 4
        imOut = uint8(zeros(targetDim));
        imOut(1:size(im,1), 1:size(im,2)) = im;        
        
        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirT1, ['im', num2str(imageIndex), '.png']);
        imwrite(imOut, fileOut)
    end
    
    % Load fMRI data
    vol = double(niftiread(filefMRI));
        
    % Calculate center of mass
    [sy sx sz] = size(vol);
    fMRIsizes(i,:) = size(vol);
    totalMass = sum(vol(:));
    rx = 0; ry = 0; rz = 0;
    for x = 1:sx
        for y = 1:sy
            for z = 1:sz
                rx = rx + vol(y,x,z) * x;
                ry = ry + vol(y,x,z) * y;
                rz = rz + vol(y,x,z) * z;
            end
        end
    end
    rx = rx / totalMass;
    ry = ry / totalMass;
    rz = rz / totalMass;
    
    midSliceZ = round(rz);
        
    maxVal(i,2) = max(vol(:));
    quant095(i,2) = quantile(vol(vol~=0), 0.95);
    quant0995(i,2) = quantile(vol(vol~=0), 0.995);

    % Extract axial slices around the middle slice
    slices = midSliceZ + selectedSlicesAroundMid;
    
    for j = 1:length(slices)
        im = squeeze(vol(:,:,slices(j)));
    
        % Convert and rearrange dimensions
%         im = uint8((im ./ maxVal(i,2)) .* 255);
        im = uint8((im ./ quant0995(i,2)) .* 255);
        im = rot90(im',2);

        % Make sure that image size is divisible by 4
        imOut = uint8(zeros(targetDim));
        imOut(1:size(im,1), 1:size(im,2)) = im;
        
        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirfMRI, ['im', num2str(imageIndex), '.png']);
        imwrite(imOut, fileOut)
    end
end

system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im1* data/' study '-T2F-41/trainA' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im2* data/' study '-T2F-41/trainA' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im3* data/' study '-T2F-41/trainA' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im4* data/' study '-T2F-41/trainA' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im5* data/' study '-T2F-41/trainA' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im6* data/' study '-T2F-41/trainA' ]  ))

system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im7* data/' study '-T2F-41/testA' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_T1_41/') 'im8* data/' study '-T2F-41/testA' ]  ))

system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im1* data/' study '-T2F-41/trainB' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im2* data/' study '-T2F-41/trainB' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im3* data/' study '-T2F-41/trainB' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im4* data/' study '-T2F-41/trainB' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im5* data/' study '-T2F-41/trainB' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im6* data/' study '-T2F-41/trainB' ]  ))

system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im7* data/' study '-T2F-41/testB' ]  ))
system(sprintf('cp %s',[fullfile(dirDataRoot, 'T2F_fMRI_41/') 'im8* data/' study '-T2F-41/testB' ]  ))



