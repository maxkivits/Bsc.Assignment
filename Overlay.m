    overlayImage = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\croppedImages\img12701.JPG');
    overlayLabel = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\croppedLabels\lab12701.png');
    B = labeloverlay(overlayImage,overlayLabel,'Transparency',.80,'Colormap','parula');
figure
imshow(B);
