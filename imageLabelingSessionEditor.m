imDir = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temper';

for i=1:41
    imageLabelingSession.ImageFilenames(i,1) = cellstr(sprintf('%s\\img%03d.JPG',imDir,i));  
end
 
% C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temper
% C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temp