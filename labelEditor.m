%edits label pixel values
labLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropAugNoiseLab';
labDir = dir(sprintf('%s\\*.png',labLoc));

for i = 1:length(labDir)

Label = uint8(imread(sprintf('%s\\%s',labLoc,labDir(i).name)));

for x = 1:360
    for y = 1:480
        if Label(x,y) == 1
            Label(x,y) = 0;
        elseif Label(x,y) == 2
            Label(x,y) = 1;
        elseif Label(x,y) == 2
            Label(x,y) = 1;
        end
        
    end
end

imwrite(Label,(sprintf('%s\\%s',labLoc,labDir(i).name)));


end