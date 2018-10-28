close all;

TestimDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temper";
TestpxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Tests\test16Scratch\Labels";

classNames = ["Background" "Skin" "Lesion"];
pixelLabelID = [0 1 2];

Testimds = imageDatastore(TestimDir);
Testpxds = pixelLabelDatastore(TestpxDir,classNames,pixelLabelID);

figure('position',[10 10 1500 1000]);
% iImage = 147;
for iOverlay = 1:167

    overlayImage = readimage(Testimds,iOverlay);
    overlayLabel = readimage(Testpxds,(iOverlay));
    B = labeloverlay(overlayImage,overlayLabel,'Transparency',.80,'Colormap','parula');

    %subplot(6,7,(iOverlay-126));
    figure('position',[10 10 1500 1000]);
    imshow(B);
    title(sprintf("image %d",iOverlay));
end

