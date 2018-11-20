%% Preprocessing script
close all;  

%% Loop through images and apply post processing
imLocation = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropResImg';           %image folder
augLocation = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugImg';       %output folder
imDir = dir(sprintf('%s\\*.JPG',imLocation)); 

%Comment out different preprocessing methods to disable them
for iPostOne = 1:length(imDir)
    %Load image
    tempImg = imread(sprintf('%s\\%s',imDir(iPostOne).folder,imDir(iPostOne).name));
    
    %Load RGB channels
    tempImgChannel = struct('R',tempImg(:,:,1),'G',tempImg(:,:,2),'B',tempImg(:,:,3));

    %Edge enhancement
    tempImgChannel.R = imsharpen(tempImgChannel.R,'Amount',2.5);
    tempImgChannel.G = imsharpen(tempImgChannel.G,'Amount',2.5);
    tempImgChannel.B = imsharpen(tempImgChannel.B,'Amount',2.5);
    
    %Histogram equalization
    tempImgChannel.R = histeq(tempImgChannel.R);
    tempImgChannel.G = histeq(tempImgChannel.G);
    tempImgChannel.B = histeq(tempImgChannel.B);
    
    %Median filtering
    tempImgChannel.R = medfilt2(tempImgChannel.R);
    tempImgChannel.G = medfilt2(tempImgChannel.G);
    tempImgChannel.B = medfilt2(tempImgChannel.B);
    
    %Reconstruct RGB image
    tempImg = cat(3,tempImgChannel.R,tempImgChannel.G,tempImgChannel.B);
    
    %Write image
    imwrite(tempImg,sprintf('%s\\img%03d.JPG',augLocation,(iPostOne)))
end

%% Noise data augmentation
tic

imLocation = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugImg';           %image directory
labLocation = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropResLab';          %label directory
augImgLocation = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugNoiseImg';             %output directories
augLabLocation = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugNoiseLab';
imDir = dir(sprintf('%s\\*.JPG',imLocation)); 
labDir = dir(sprintf('%s\\*.png',labLocation)); 

numberNoise = 10;           %specify amount of noise images per noise type

for iNoiseOne = 1:length(imDir)
    %Load images and labels
    
%     tempImg = imread(sprintf('%s\\%s',imDir(iNoiseOne).folder,imDir(iNoiseOne).name));
    tempLab = imread(sprintf('%s\\%s',labDir(iNoiseOne).folder,labDir(iNoiseOne).name));
%     imwrite(tempImg,sprintf('%s\\img%03d0000000000.JPG',augImgLocation,(iNoiseOne)))
    imwrite(tempLab,sprintf('%s\\lab%03d0000000000.png',augLabLocation,(iNoiseOne)))
    
    for iNoiseGauss = 1:numberNoise
%         tempImgNoise = imnoise(tempImg,'gaussian');
%         imwrite(tempImgNoise,sprintf('%s\\img%03d00000000%02d.JPG',augImgLocation,(iNoiseOne),iNoiseGauss))
        imwrite(tempLab,sprintf('%s\\lab%03d00000000%02d.png',augLabLocation,(iNoiseOne),iNoiseGauss))
    end
    for iNoiseSP = 1:numberNoise
%         tempImgNoise = imnoise(tempImg,'salt & pepper');
%         imwrite(tempImgNoise,sprintf('%s\\img%03d000000%02d00.JPG',augImgLocation,(iNoiseOne),iNoiseSP))
        imwrite(tempLab,sprintf('%s\\lab%03d000000%02d00.png',augLabLocation,(iNoiseOne),iNoiseSP))
    end
    for iNoiselocalvar = 1:numberNoise
%         J = stdfilt(tempImg);
%         tempImgNoise = imnoise(tempImg,'localvar',((J.^2)./10000));
%         imwrite(tempImgNoise,sprintf('%s\\img%03d0000%02d0000.JPG',augImgLocation,(iNoiseOne),iNoiselocalvar))
        imwrite(tempLab,sprintf('%s\\lab%03d0000%02d0000.png',augLabLocation,(iNoiseOne),iNoiselocalvar))
    end
    for iNoisePoisson = 1:numberNoise
%         tempImgNoise = imnoise(tempImg,'poisson');
%         imwrite(tempImgNoise,sprintf('%s\\img%03d00%02d000000.JPG',augImgLocation,(iNoiseOne),iNoisePoisson))
        imwrite(tempLab,sprintf('%s\\lab%03d00%02d000000.png',augLabLocation,(iNoiseOne),iNoisePoisson))
    end
    for iNoiseSpeckle = 1:numberNoise
%         tempImgNoise = imnoise(tempImg,'speckle');
%         imwrite(tempImgNoise,sprintf('%s\\img%03d%02d00000000.JPG',augImgLocation,(iNoiseOne),iNoiseSpeckle))
        imwrite(tempLab,sprintf('%s\\lab%03d%02d00000000.png',augLabLocation,(iNoiseOne),iNoiseSpeckle))
    end
    
end

toc
