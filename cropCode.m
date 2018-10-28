%% Crops images in Image folder and applies the same cropping to the respective labels in the Labels folder
close all; clc; clear all; 

imDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\*.JPG";          %give image directory
labDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\*.png";         %give label directory

imageList = struct2cell(dir(imDir));
labelList = struct2cell(dir(labDir));

startBias = 127;                                                                            %define starting point of loop

for iCrop=(startBias):length(imageList)
    currentImage = imread(char(strcat(imageList(2,1),'\',imageList(1,iCrop))));
    currentLabel = imread(char(strcat(labelList(2,1),'\',labelList(1,iCrop))));   
    [croppedImage,rect] = imcrop(currentImage);
    croppedLabel = imcrop(currentLabel,rect);
    imwrite(croppedImage,char(strcat(imageList(2,1),'\',imageList(1,iCrop))));
    imwrite(croppedLabel,char(strcat(labelList(2,1),'\',labelList(1,iCrop))));
end