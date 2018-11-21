clc; close all;
%% Create image and label Datastores
imDir = '/deepstore/datasets/ram/slss/ImagesOriginal/';
pxDir = '/deepstore/datasets/ram/slss/LabelsOriginal/';

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
shuffledIndicesTransfer = randperm(numFiles);

% Use 70% of the images for training.
N = round(0.70 * numFiles);
trainingIdx = shuffledIndicesTransfer(1:N);

% Use the rest for testing.
testIdx = shuffledIndicesTransfer(N+1:end);

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
%% Load VGG16 based Net
imageSize = [360 480 3];
numClasses = numel(classNames);
lgraphtransfer = load('/home/s1590294/nets/transferNet.mat');


%% Class weight balancing
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

pxLayer = pixelClassificationLayer('Name','labels','classNames',tbl.Name,'ClassWeights',classWeights);

%replace existing pixelclassification layer
lgraphtransfer = removeLayers(lgraphtransfer,'pixelLabels');
lgraphtransfer = addLayers(lgraphtransfer, pxLayer);
lgraphtransfer = connectLayers(lgraphtransfer,'softmax','labels');

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
    'MiniBatchSize',10, ...
    'Plots','training-progress', ...
    'validationData',impxdsTest,...
    'ValidationPatience',10,...
    'Shuffle','every-epoch', ...
    'VerboseFrequency',100);

%% Train network!
[trainednetTransfer, info] = trainNetwork(pximds,lgraphtransfer,options);


% %% Test network
% I = read(imdsTest);
% C = semanticseg(I, trainednetTransfer);
% 
% B = labeloverlay(I,C,'Transparency',0.6);
% figure
% imshow(B)

%% Evaluate network performance

pxdsResultsTransfer = semanticseg(imdsTest,trainednetTransfer, ...
    'MiniBatchSize',1, ...
    'Verbose',true);
 
%metricsTransfer = evaluateSemanticSegmentation(pxdsResultsTransfer,pxds,'Verbose',false);
% metrics.DataSetMetrics;         %Average performance of entire network over all classes
% metrics.ClassMetrics;           %Performance of network per class
 
%% Save Net and results
save('/home/s1590294/OutTransfer', 'pxdsResultsTransfer');
save('/home/s1590294/OutTransfer', 'trainednetTransfer');
save('/home/s1590294/OutTransfer', 'shuffledIndicesTransfer');
