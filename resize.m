%Resizes images/labels
close all 

resizeMapIn = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\croppedImages'; %resize directory
resizeMapOut = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropResImg';
resizeDir = dir(sprintf('%s\\*.JPG',resizeMapIn));                        
imageResize = [360 480];                                                          %network input image size

for iRes = 1:length(resizeDir)
    tempImg = imread(sprintf('%s\\%s',resizeDir(iRes).folder,resizeDir(iRes).name));
    tempImg = imresize(tempImg,imageResize,'nearest');
    imwrite(tempImg,sprintf('%s\\img%d.JPG',resizeMapOut,(iRes+126)));
end
