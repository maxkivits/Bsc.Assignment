% imgdatastore stores imgs in different manner as pixellabeldatastore...
%% Imgs
mypath = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugNoiseLab'; %specify imgs folder 

names = dir(sprintf('%s\\*.png',mypath));
names([names.isdir]) = [];
fileNames = {names.name};

for iFile = 1:length(fileNames) %# Loop over the file names
    f = fullfile(mypath, sprintf("lab%03d.png",iFile+126)); %Specify new name
    g = fullfile(mypath, fileNames{iFile});   
    movefile(g,f);        %# Rename the file   
end

% %% Labels
% 
% mypathlab = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Original\UTresizedlab'; %specify label folder
% 
% nameslab = dir(mypathlab);
% nameslab([nameslab.isdir]) = [];
% fileNameslab = {nameslab.name};
% 
% for iFile = 127: length(fileNames)+126  %# Loop over the file names
%     if iFile/10 < 1    
%     newName = sprintf('%04d.nc', iFile);  %# Make the new name
%           f = fullfile(mypathlab, strcat("lab00",num2str(iFile),".png")); %Specify new name
%           g = fullfile(mypathlab, fileNameslab{iFile});   
%           movefile(g,f);        %# Rename the file
%     elseif iFile/100 < 1  
%         newName = sprintf('%04d.nc', iFile);  %# Make the new name
%           f = fullfile(mypathlab, strcat("lab0",num2str(iFile),".png")); %Specify new name
%           g = fullfile(mypathlab, fileNameslab{iFile});   
%           movefile(g,f);        %# Rename the file
%     else
%         newName = sprintf('%04d.nc', iFile);  %# Make the new name
%           f = fullfile(mypathlab, strcat("lab",num2str(iFile),".png")); %Specify new name
%           g = fullfile(mypathlab, fileNameslab{iFile-126});   
%           movefile(g,f);        %# Rename the file
%     end
% end