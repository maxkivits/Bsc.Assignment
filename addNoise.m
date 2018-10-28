%% Create image and label Datastores
imDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images";
augImDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\augImages";

cd(imDir);
imagefiles = dir('*.JPG');      
nfiles = length(imagefiles);    % Number of files found

for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   for iNoise=1:10
        imageNoise = imnoise(currentimage,'salt & pepper');
        imwrite(imageNoise,sprintf("C:/Users/Max Kivits/Documents/MATLAB/Bacheloropdracht/Data/augImages/img%03d%02d.JPG",ii,iNoise));
   end
end