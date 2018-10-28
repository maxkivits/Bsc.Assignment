close all;


% test = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\test1\pixelLabel_02.png');
% imshow(test,[0 2]);
TestimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images";
TestpxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Tests\test15\Labels";

classNames = ["Background" "Lesion"];
pixelLabelID = [0 1];

Testimds = imageDatastore(TestimDir);
Testpxds = pixelLabelDatastore(TestpxDir,classNames,pixelLabelID);

cd 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht'
numfiles = randperm(167);            

for iShow=1:20
overlayImage = readimage(Testimds,numfiles(iShow));
overlayLabel = readimage(Testpxds,numfiles(iShow));
B = labeloverlay(overlayImage,overlayLabel,'includedlabels',["Lesion"],'Transparency',.76,'Colormap','winter');

f = figure; 
imshow(B)
%saveas(f,sprintf('overlayImage%d.png',iShow)); %uncomment if want to save
end
