close all 

resizeMap = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temper';
resizeDir = dir(sprintf('%s\\*.JPG',resizeMap));
imageResize = [360 480];      	%network input image size

for iRes = 1:length(resizeDir)
    tempImg = imread(sprintf('%s\\%s',resizeDir(iRes).folder,resizeDir(iRes).name));
    tempImg = imresize(tempImg,imageResize);
    imwrite(tempImg,sprintf('%s\\lab%d.png',resizeMap,(iRes+126)));
end
