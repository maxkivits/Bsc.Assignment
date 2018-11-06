% This script is used to output the different images contained in the paper
%% Original database examples
imDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Original\UTOGsize";
outDir ="C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Paper";
imds = imageDatastore(imDir);

numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);
exampleIndx = shuffledIndices(1:3);

figure
for iExImg = 1:3
    exImg = readimage(imds,exampleIndx(iExImg));
    subplot(1,3,iExImg);
    imshow(exImg);
end

imwrite(exImg,'example1.png','Location',outDir);