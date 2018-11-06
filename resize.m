%Resizes images/labels, overwrites files!
close all 

resizeMap = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temp';      %resize directory
resizeDir = dir(sprintf('%s\\*.png',resizeMap));                        
imageResize = [1920 2560];                                                          %network input image size

for iRes = 1:length(resizeDir)
    tempImg = imread(sprintf('%s\\%s',resizeDir(iRes).folder,resizeDir(iRes).name));
    tempImg = imresize(tempImg,imageResize);
    imwrite(tempImg,sprintf('%s\\lab%d.png',resizeMap,(iRes+126)));
end
