clc; close all;
%% Create image and label Datastores
% imLoc = '/deepstore/datasets/ram/slss/';
% pxLoc = '/deepstore/datasets/ram/slss/';

imLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\';
pxLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\crop\';

imDirSpec = 'cropAugNoiseImg';
pxDirSpec = 'cropAugNoiseLab';

imDir = sprintf('%s%s',imLoc,imDirSpec);
pxDir = sprintf('%s%s',pxLoc,pxDirSpec);


classNames = ["Skin" "Lesion"]; %define classes
pixelLabelID = [1 2];

imds = imageDatastore(imDir);
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

%% Calculate label frequency
tbl = countEachLabel(pxds);
frequency = tbl.PixelCount/sum(tbl.PixelCount);

figure
bar(1:numel(classNames),frequency)
xticks(1:numel(classNames)) 
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')
%% Separate image and label into training and validation sets
rng('default');

numFiles = numel(imds.Files);
shuffledIndices_DataTestAUG = randperm(numFiles);

% Use 70% of the images for training.
N = round(0.70 * numFiles);
trainingIdx = shuffledIndices_DataTestAUG(1:N);

% Use the rest for testing.
testIdx = shuffledIndices_DataTestAUG(N+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
testImages = imds.Files(testIdx);
imdsTrain = imageDatastore(trainingImages);
imdsTest = imageDatastore(testImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = 1:numel(pxds.ClassNames);

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
testLabels = pxds.Files(testIdx);
pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);

numTrainingImages = numel(imdsTrain.Files);
numTestingImages = numel(imdsTest.Files);

% create labelimage datastore for training validation
impxdsTest = pixelLabelImageDatastore(imdsTest, pxdsTest);

%% Load Net
imageSize = [360 480 3];
numClasses = numel(classNames);
% lgraph = load('/home/s1590294/net/lgraphSGN3.mat');
lgraph = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN3.mat');

%Convert to layergraph to be able to edit network
%lgraph = layerGraph(lgraph.lgraphSGN3);
lgraph = lgraph.haha;

%% Class weight balancing
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

pxLayer = pixelClassificationLayer('Name','labels','classNames',tbl.Name,'ClassWeights',classWeights);

%replace existing pixelclassification layer
lgraph = removeLayers(lgraph,'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph,'softmax','labels');

%% Image augmentation to generate more training data

augmenter = imageDataAugmenter(...
    'RandXReflection',true,...
    'RandXTranslation',[-100 100],...
    'RandYTranslation',[-100 100],...
    'RandRotation',[-30, 30],...
    'RandYReflection',true,...
    'RandXScale',[0.75 1.5],...
    'RandYScale',[0.75 1.5]...
    );

%% Create an imagelabel datastore specifically used in segmentation networks
pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain,'outputSize',imageSize,'DataAugmentation',augmenter);

%% Traning options 
options = trainingOptions('sgdm', ...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.0005, ...
    'MaxEpochs',100, ...  
    'MiniBatchSize',1, ...
    'Plots','training-progress', ...
    'validationData',impxdsTest,...
    'ValidationPatience',10,...
    'Shuffle','every-epoch', ...
    'VerboseFrequency',100);

%% Train network!
[trainednet_DataTestAUG, info_DataTestAUG] = trainNetwork(pximds,lgraph,options);


% %% Test network
% I = read(imdsTest);
% C = semanticseg(I, trainednetTransfer);
% 
% B = labeloverlay(I,C,'Transparency',0.6);
% figure
% imshow(B)

%% Evaluate network performance

pxdsResults_DataTestAUG = semanticseg(imdsTest,trainednet_DataTestAUG, ...
    'MiniBatchSize',1, ...
    'Verbose',false);
 
metrics = evaluateSemanticSegmentation(pxdsResults_DataTestCROP,pxdsTest,'Verbose',false);

%metricsScratch = evaluateSemanticSegmentation(pxdsResultsScratch,pxds,'Verbose',false);
% metrics.DataSetMetrics;         %Average performance of entire network over all classes
% metrics.ClassMetrics;           %Performance of network per class

%% Save Net and results
save('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\trainednet_DataTestAUG.mat', 'trainednet_DataTestAUG');
save('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\pxdsResults_DataTestAUG.mat', 'pxdsResults_DataTestAUG');
save('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\shuffledIndices_DataTestAUG.mat', 'shuffledIndices_DataTestAUG');
save('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\metricsAUG.mat', 'metrics')

% save('/home/s1590294/Out/DataTestAUG', 'trainednet_DataTestAUG');
% save('/home/s1590294/Out/DataTestAUG', 'pxdsResults_DataTestAUG');
% save('/home/s1590294/Out/DataTestAUG', 'shuffledIndices_DataTestAUG');

%% plot 9 random images
figure
for iTest=1:9
    I = read(imdsTest);
    C = semanticseg(I, trainednet_DataTestCROP);

    B = labeloverlay(I,C,'colormap','parula','Transparency',0.75);
    subplot(3,3,iTest);
    imshow(B)
end
saveas(gcf,'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\testImg\dataAug.png');

