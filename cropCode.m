%% Crops images in Image folder and applies the same cropping to the respective labels in the Labels folder
close all; 

imDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temper\*.JPG";          %give image directory
labDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temp\*.png";         %give label directory

outimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\croppedImages\";       %give image output directory
outlabDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\croppedLabels\";      %give label output directory

imageList = struct2cell(dir(imDir));
labelList = struct2cell(dir(labDir));

startBias = 1;                                                                            %define starting point of loop

% for iCrop=(startBias):length(imageList)
%     currentImage = imread(char(strcat(imageList(2,1),'\',imageList(1,iCrop))));
%     currentLabel = imread(char(strcat(labelList(2,1),'\',labelList(1,iCrop))));   
%     [croppedImage,rect] = imcrop(currentImage);
%     croppedLabel = imcrop(currentLabel,rect);
%     imwrite(croppedImage,char(sprintf('%s%s',outimDir,imageList(1,iCrop))));
%     imwrite(croppedLabel,char(strcat(outlabDir,labelList(1,iCrop))));
% end
iCrop = 1;
imgNumber = 1;
while true
    imgNumber = imgNumber + 1;
    ding = mod(imgNumber,5);
    for ding = 0
        iCrop = iCrop +1;
    end
    currentImage = imread(char(strcat(imageList(2,1),'\',imageList(1,iCrop))));
    currentLabel = imread(char(strcat(labelList(2,1),'\',labelList(1,iCrop))));   
    [croppedImage,rect] = imcrop(currentImage);
    croppedLabel = imcrop(currentLabel,rect);
    imwrite(croppedImage,sprintf('%simg%d%02d.JPG',outimDir,iCrop+126,imgNumber));
    imwrite(croppedLabel,sprintf('%slab%d%02d.png',outlabDir,iCrop+126,imgNumber));
end