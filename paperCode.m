% This script is used to output the different images contained in the paper
close all;
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

%% Sigmoid & ReLu activation graphs

figure
fplot(@(z) 1./(1 + exp(-z)),[-10 10]);
xlabel('x');
ylabel('\phi(x)');
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
figure
syms x;
y = piecewise(x<0, 0, x>0, x);
fplot(y,[-10 10]);
xlabel('x');
ylabel('R(x)');
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';


%% Generate Lgraph plots
lgraph = {lgraphSGN1,lgraphSGN2,lgraphSGN3,lgraphSGN4,lgraphSGN5,lgraphSGN6,lgraphVGG16,lgraphVGG19,lgraphFCN8,lgraphFCN16,lgraphFCN32,lgraphSGNVGG16};
lgraphname = {'lgraphSGN1','lgraphSGN2','lgraphSGN3','lgraphSGN4','lgraphSGN5','lgraphSGN6','lgraphVGG16','lgraphVGG19','lgraphFCN8','lgraphFCN16','lgraphFCN32','lgraphSGNVGG16'};


for iLgraphPlot = 1:length(lgraph)
    figure
    plot(lgraph{iLgraphPlot});
    title(lgraphname{iLgraphPlot});
end