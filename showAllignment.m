%Shows allignment of image with respective label for 20 random images in
%the specified data folder
close all;


TestimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugNoiseImg";
TestpxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugNoiseLab";

classNames = ["Background" "Skin" "Lesion"];
pixelLabelID = [0 1 2];

Testimds = imageDatastore(TestimDir);
Testpxds = pixelLabelDatastore(TestpxDir,classNames,pixelLabelID);

figure('position',[10 10 1500 1000]);

idx = randperm(numel(Testimds.Files),20);

for iOverlay = 1:20

    overlayImage = readimage(Testimds,idx(iOverlay));
    overlayLabel = readimage(Testpxds,idx(iOverlay));
    B = labeloverlay(overlayImage,overlayLabel,'Transparency',.30,'Colormap','parula');

    subplot(5,4,(iOverlay));
    imshow(B);
    title(sprintf("image %d",iOverlay));
end

