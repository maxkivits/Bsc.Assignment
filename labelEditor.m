labLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temp';

for i = 1:126

Label = uint8(imread(sprintf('%s\\lab%03d.png',labLoc,(i))));

for x = 1:360
    for y = 1:480
        if Label(x,y) == 1
            Label(x,y) = 2;
        elseif Label(x,y) == 0
            Label(x,y) = 1;
        end
        
    end
end

imwrite(Label,sprintf('%s\\lab%03d.png',labLoc,(i)));


end