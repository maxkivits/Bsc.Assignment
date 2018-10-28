%% Test network
I = read(imdsTest);
C = semanticseg(I, trainednetScratch);

B = labeloverlay(I,C,'Transparency',0.8);
figure
imshow(B)
