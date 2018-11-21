% close all;
% 
% imDir = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal';
% labDir 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels';
% 
% X = imread(sprintf('%s\\img%d',imdir,jnmi);
% 
% Mdl = fitcsvm(X,Y);
dir = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\';
for i=1:6
    haha = segnetLayers(imageSize, numClasses, i);
    save(sprintf('%slgraphSGN%d.mat',dir,i),'haha');
end