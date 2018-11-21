%checks max label pixel value for each label in folder

labFolder = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels    ';
labDir = dir(sprintf('%s\\*.png',labFolder));

%memory preallocation
maxValue = zeros(1,length(labDir));

for i = 1:length(labDir)
    maxValueColumn = max(imread(sprintf('%s\\%s',labFolder,labDir(i).name)));
    maxValue(1,i) = max(maxValueColumn(:));

end
totalMax = max(maxValue(:));

disp(totalMax);

%% Check if viable for pixel label data store
classNames = ["Skin" "Lesion"]; %define classes
pixelLabelID = [1 2];           %define pixel-label IDs

pxdsCheck = pixelLabelDatastore(sprintf('%s\\*.png',labFolder),classNames,pixelLabelID);
