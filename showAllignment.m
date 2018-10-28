close all;

TestimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\augImages";
TestpxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\augLabels";

classNames = ["Background" "Skin" "Lesion"];
pixelLabelID = [0 1 2];

Testimds = imageDatastore(TestimDir);
Testpxds = pixelLabelDatastore(TestpxDir,classNames,pixelLabelID);

figure('position',[10 10 1500 1000]);
% iImage = 147;
for iOverlay = 167:187

    overlayImage = readimage(Testimds,iOverlay);
    overlayLabel = readimage(Testpxds,iOverlay);
    B = labeloverlay(overlayImage,overlayLabel,'Transparency',.60,'Colormap','parula');

    subplot(5,4,(iOverlay-166));
    imshow(B);
    title(sprintf("image %d",iOverlay-166));
end

