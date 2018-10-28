%mask = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\test11\pixelLabel_001.png');
close all;

TestimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images";
TestpxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Tests\test16Scratch\Labels";
classNames = ["Background" "Lesion"];
pixelLabelID = [0 1];
Testimds = imageDatastore(TestimDir);
Testpxds = pixelLabelDatastore(TestpxDir,classNames,pixelLabelID);

imageNumber = randi(167,'int8');

contourImage = imread(sprintf('%s\\img%03d.JPG',TestimDir,imageNumber));
labelConv = imread(sprintf('%s\\pixelLabel_%03d.png',TestpxDir,imageNumber));


for xIter = 1:360
    for yIter = 1:480
        if labelConv(xIter,yIter) == 1
            labelConv(xIter,yIter) = 0;
        else
        end
    end
end
labelConv = imfill(labelConv,'holes');

figure
imshow(contourImage);

figure 
imshow(labelConv,[0 1]);


contour = activecontour(contourImage,labelConv,3000,'Chan-Vese','SmoothFactor',2);
imageOut = labeloverlay(contourImage,contour,'Transparency',.60,'Colormap','parula');
figure
imshow(imageOut);