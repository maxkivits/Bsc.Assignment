% This script is used to output the different images contained in the paper
close all;
%% Original database examples
imDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Original\DFCNimg";
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

%% Generate overlay image
classNames = ["Background" "Skin" "Lesion"]; %define classes
pixelLabelID = [0 1 2];
imdspic = imageDatastore('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal');
pxdspic = pixelLabelDatastore('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\LabelsOriginal',classNames,pixelLabelID);

overlayImage = readimage(imdspic,75);
overlayLabel = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\LabelsOriginal\lab075.png');
B = labeloverlay(overlayImage,overlayLabel,'Transparency',.60,'Colormap','parula');

figure
subplot(1,3,1)
imshow(overlayImage);
subplot(1,3,2)
imshow(overlayLabel,[0 2]);
subplot(1,3,3)
imshow(B);

%% Generate Lgraph plots
lgraph = {lgraphSGN1,lgraphSGN2,lgraphSGN3,lgraphSGN4,lgraphSGN5,lgraphSGN6,lgraphVGG16,lgraphVGG19,lgraphFCN8,lgraphFCN16,lgraphFCN32,lgraphSGNVGG16};
lgraphname = {'lgraphSGN1','lgraphSGN2','lgraphSGN3','lgraphSGN4','lgraphSGN5','lgraphSGN6','lgraphVGG16','lgraphVGG19','lgraphFCN8','lgraphFCN16','lgraphFCN32','lgraphSGNVGG16'};
outPlot = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Paper\Struct\';

for iLgraphPlot = 1:length(lgraph)
    figure
    plot(lgraph{iLgraphPlot});
    title(lgraphname{iLgraphPlot});
    saveas(gcf,sprintf('%s%s_Structure.png',outPlot,lgraphname{iLgraphPlot}));
end

%% Plot dataset examples
outEx = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Paper\';
UT = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal\img130.jpg';
DFCN = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal\img034.jpg';
ISIC = 'C:\Users\Max Kivits\Downloads\ISIC-images-20181121T101759Z-001\ISIC-images\ISIC_0000032.jpg';

figure
subplot(1,3,1)
imshow(UT);
subplot(1,3,2)
imshow(DFCN);
subplot(1,3,3)
imshow(ISIC);
saveas(gcf,sprintf('%sdataSetEx.png',outEx));
%% Hold out metrics
clear('metrics');
lgraphname = {'lgraphSGN1','lgraphSGN2','lgraphSGN3','lgraphSGN4','lgraphSGN5','lgraphSGN6','lgraphVGG16','lgraphVGG19','lgraphFCN8','lgraphFCN16','lgraphFCN32','lgraphSGNVGG16'};
netLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\';

holdOutLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ISIC\';
imDir = dir(sprintf('%s*.jpg',holdOutLoc));
pxDir = dir(sprintf('%s*.png',holdOutLoc));

        
outSem = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\SemantisSeg\';
classes = ["Skin" "Lesion"]; %define classes
pixelLabelIDs = [1 2];

%load trained nets
for iNet=1:length(lgraphname)
    lgraph{iNet} = load(sprintf('%strainednet_%s.mat',netLoc,lgraphname{iNet}));
    imds = imageDatastore(sprintf('%s*.jpg',holdOutLoc));
    pxds = pixelLabelDatastore(sprintf('%s*.png',holdOutLoc),classes, pixelLabelIDs);
    
    pxdsResults = semanticseg(imds,lgraph{iNet}.trainedNet, ...
    'MiniBatchSize',1, ...
    'Verbose',true,...
    'WriteLocation',sprintf('%s%sISIC',outSem,lgraphname{iNet}));
 
    ISICmetrics = evaluateSemanticSegmentation(pxdsResults,pxds,'Verbose',true);
    save(sprintf('%sISICmetrics_%s.mat',netLoc,lgraphname{iNet}),'ISICmetrics')

    
end


%% Metrics table files
clear('metrics');
lgraphname = {'lgraphSGN1','lgraphSGN2','lgraphSGN3','lgraphSGN4','lgraphSGN5','lgraphSGN6','lgraphVGG16','lgraphVGG19','lgraphFCN8','lgraphFCN16','lgraphFCN32','lgraphSGNVGG16'};
metricLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\';
for iMet=1:length(lgraphname)
    metrics{iMet} = load(sprintf('%sISICmetrics_%s.mat',metricLoc,lgraphname{iMet}));
    conMatrixTable = metrics{1, iMet}.ISICmetrics.NormalizedConfusionMatrix;
    t= (metrics{1, iMet}.ISICmetrics.ClassMetrics);
    writetable(t,sprintf('ISICclassMetric%s.csv',lgraphname{iMet}),'WriteRowNames',true);
end

%% different preprocess filter image
noiseLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Paper\';
tempImg = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal\img105.JPG');
imwrite(tempImg,sprintf('%sOG.jpg',noiseLoc));
    %Load RGB channels
    tempImgChannel = struct('R',tempImg(:,:,1),'G',tempImg(:,:,2),'B',tempImg(:,:,3));

    %Edge enhancement
    tempImgChannel.R = imsharpen(tempImgChannel.R,'Amount',2.5);
    tempImgChannel.G = imsharpen(tempImgChannel.G,'Amount',2.5);
    tempImgChannel.B = imsharpen(tempImgChannel.B,'Amount',2.5);
    
    %Reconstruct RGB image
    tempImg = cat(3,tempImgChannel.R,tempImgChannel.G,tempImgChannel.B);
    
    %Write image
    imwrite(tempImg,sprintf('%sedge.jpg',noiseLoc))
    
tempImg = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal\img105.JPG');
 %Load RGB channels
    tempImgChannel = struct('R',tempImg(:,:,1),'G',tempImg(:,:,2),'B',tempImg(:,:,3));

    %Histogram equalization
    tempImgChannel.R = histeq(tempImgChannel.R);
    tempImgChannel.G = histeq(tempImgChannel.G);
    tempImgChannel.B = histeq(tempImgChannel.B);
    %Reconstruct RGB image
    tempImg = cat(3,tempImgChannel.R,tempImgChannel.G,tempImgChannel.B);
    
    %Write image
    imwrite(tempImg,sprintf('%shist.jpg',noiseLoc))
    
tempImg = imread('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal\img105.JPG');
 %Load RGB channels
    tempImgChannel = struct('R',tempImg(:,:,1),'G',tempImg(:,:,2),'B',tempImg(:,:,3));
    
    %Median filtering
    tempImgChannel.R = medfilt2(tempImgChannel.R);
    tempImgChannel.G = medfilt2(tempImgChannel.G);
    tempImgChannel.B = medfilt2(tempImgChannel.B);
        %Reconstruct RGB image
    tempImg = cat(3,tempImgChannel.R,tempImgChannel.G,tempImgChannel.B);
    
    %Write image
    imwrite(tempImg,sprintf('%smedf.jpg',noiseLoc))
    
%% generate example segmentations for TD experiment
imOGLoc ='C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ImagesOriginal\';
imCROPLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\cropResImg\';

pxLocOG =  'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\SemantisSeg\dataTestCrop\';

%%%%%%%%%%%%%
imLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\';
pxLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\';

imDirSpec = 'cropResImg';
pxDirSpec = 'cropResLab';

% pxDirSpec = 'labels';

imDir = sprintf('%s%s',imLoc,imDirSpec);
pxDir = sprintf('%s%s',pxLoc,pxDirSpec);


classNames = ["Skin" "Lesion"]; %define classes
pixelLabelID = [1 2];

imds = imageDatastore(imDir);
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

rng('default');

numFiles = numel(imds.Files);
shuffledIndices_DataTestCROP = randperm(numFiles);

% Use 70% of the images for training.
N = round(0.70 * numFiles);
trainingIdx = shuffledIndices_DataTestCROP(1:N);

% Use the rest for testing.
testIdx = shuffledIndices_DataTestCROP(N+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);
%%%%%%%%%

% imCROP = imageDatastore(sprintf('%s*.JPG',imgCROPLoc));

outSem = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\SemantisSeg\dataTestCrop\*.png';
classes = ["Skin" "Lesion"]; %define classes
pixelLabelIDs = [1 2];

pxCrop = pixelLabelDatastore(pxLocOG,classes,pixelLabelIDs);
% 
% netOG = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\trainednet_DataTestOG.mat');
% netOG = netOG.trainednet_DataTestOG;
% netCROP = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\trainednet_DataTestCROP.mat');
% netCROP = netCROP.trainednet_DataTestCROP;
rng('shuffle');
idx = randperm(161,9);
figure
for iOG=1:9
    image = readimage(imdsTest,idx(iOG));
    label = readimage(pxCrop,idx(iOG));
    B = labeloverlay(image,label,'colormap','parula','Transparency',0.75);
    subplot(3,3,iOG)
    imshow(B);
end

%% For OG
% make imds Test
imLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\';
pxLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\';

imDirSpec = 'ImagesOriginal';
pxDirSpec = 'LabelsOriginal';

% pxDirSpec = 'labels';

imDir = sprintf('%s%s',imLoc,imDirSpec);
pxDir = sprintf('%s%s',pxLoc,pxDirSpec);


classNames = ["Skin" "Lesion"]; %define classes
pixelLabelID = [1 2];

imds = imageDatastore(imDir);
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

rng('default');

numFiles = numel(imds.Files);
shuffledIndices_DataTestOG = randperm(numFiles);

% Use 70% of the images for training.
N = round(0.70 * numFiles);
trainingIdx = shuffledIndices_DataTestOG(1:N);

% Use the rest for testing.
testIdx = shuffledIndices_DataTestOG(N+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);

outImg = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\testImg\';
figure
rng('shuffle');
imgIdx = randperm(50,9);

net = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\trainednet_DataTestOG.mat');
trainedNet = net.trainednet_DataTestOG  
for iTest=1:9
    I = readimage(imdsTest,imgIdx(iTest));
    C = semanticseg(I, trainedNet);

    B = labeloverlay(I,C,'colormap','parula','Transparency',0.75);
    subplot(3,3,iTest);
    imshow(B)
end
saveas(gcf,sprintf('%s%s_TestImg.png',outImg,lgraphname{iTest}));


%% Performance metrics of OG and Crop nets on hold out data
% Hold out metrics
clear('metrics');
lgraphname = {'DataTestOG','DataTestCROP'};
netLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\';

holdOutLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\ISIC\';
imDir = dir(sprintf('%s*.jpg',holdOutLoc));
pxDir = dir(sprintf('%s*.png',holdOutLoc));

        
outSem = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\SemantisSeg\';
classes = ["Skin" "Lesion"]; %define classes
pixelLabelIDs = [1 2];

%load trained nets
for iNet=2:length(lgraphname)
    lgraph{iNet} = load(sprintf('%strainednet_%s.mat',netLoc,lgraphname{iNet}));
    imds = imageDatastore(sprintf('%s*.jpg',holdOutLoc));
    pxds = pixelLabelDatastore(sprintf('%s*.png',holdOutLoc),classes, pixelLabelIDs);
    
    pxdsResults = semanticseg(imds,lgraph{iNet}.trainednet_DataTestCROP, ...
    'MiniBatchSize',1, ...
    'Verbose',true,...
    'WriteLocation',sprintf('%s%sISIC',outSem,lgraphname{iNet}));
 
    ISICmetrics = evaluateSemanticSegmentation(pxdsResults,pxds,'Verbose',true);
    save(sprintf('%sISICmetrics_%s.mat',netLoc,lgraphname{iNet}),'ISICmetrics')

    
end


% Metrics table files
clear('metrics');
lgraphname = {'DataTestOG','DataTestCROP'};
metricLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\';
for iMet=1:length(lgraphname)
    metrics{iMet} = load(sprintf('%sISICmetrics_%s.mat',metricLoc,lgraphname{iMet}));
    conMatrixTable = metrics{1, iMet}.ISICmetrics.NormalizedConfusionMatrix;
    t = (metrics{1, iMet}.ISICmetrics.ClassMetrics);
    writetable(t,sprintf('ISICclassMetric%s.csv',lgraphname{iMet}),'WriteRowNames',true);
end

