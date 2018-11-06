close all;

TestimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\tempest";
TestpxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temp";

classNames = ["Background" "Skin" "Lesion"];
pixelLabelID = [0 1 2];

Testimds = imageDatastore(TestimDir);
Testpxds = pixelLabelDatastore(TestpxDir,classNames,pixelLabelID);

figure('position',[10 10 1500 1000]);
% iImage = 147;
for iOverlay = 1:27

    overlayImage = readimage(Testimds,iOverlay);
    overlayLabel = readimage(Testpxds,iOverlay);
    B = labeloverlay(overlayImage,overlayLabel,'Transparency',.60,'Colormap','parula');

    subplot(7,5,(iOverlay));
    imshow(B);
    title(sprintf("image %d",iOverlay));
end

