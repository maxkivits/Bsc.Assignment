%   This is the total transfer script. It takes a segmentation network trained on street data (provided by matworks) 
%   and trains it on all the different data sets
clc; close all;
%% Create image and label Datastores
%Image and Label data locations
imDirNone = '/deepstore/datasets/ram/slss/ImagesOriginal/';
imDirCrop = '/deepstore/datasets/ram/slss/cropResImg/';
imDirAug = '/deepstore/datasets/ram/slss/augImages/';
imDirAugCrop = '/deepstore/datasets/ram/slss/cropAugNoiseImg/';
pxDirNone = '/deepstore/datasets/ram/slss/LabelsOriginal/';
pxDirCrop = '/deepstore/datasets/ram/slss/cropResLab/';
pxDirAug = '/deepstore/datasets/ram/slss/augLabels/';
pxDirAugCrop = '/deepstore/datasets/ram/slss/cropAugNoiseLab/';

classNames = ["Skin" "Lesion"]; %define classes
pixelLabelIDs = [1 2];           %define pixel-label IDs

%Create Image and Label datastores
imdsNone = imageDatastore(imDirNone);   
imdsCrop = imageDatastore(imDirCrop);   
imdsAug = imageDatastore(imDirAug);   
imdsAugCrop = imageDatastore(imDirAugCrop);  
pxdsNone = pixelLabelDatastore(sprintf('%s*.png',pxDirNone),classNames,pixelLabelIDs);
pxdsCrop = pixelLabelDatastore(sprintf('%s*.png',pxDirCrop),classNames,pixelLabelIDs);
pxdsAug = pixelLabelDatastore(sprintf('%s*.png',pxDirAug),classNames,pixelLabelIDs);
pxdsAugCrop = pixelLabelDatastore(sprintf('%s*.png',pxDirAugCrop),classNames,pixelLabelIDs);

%% Calculate label frequency for each data set
tblNone = countEachLabel(pxdsNone);
tblCrop = countEachLabel(pxdsCrop);
tblAug = countEachLabel(pxdsAug);
tblAugCrop = countEachLabel(pxdsAugCrop);
frequencyNone = tblNone.PixelCount/sum(tblNone.PixelCount);
frequencyCrop = tblCrop.PixelCount/sum(tblCrop.PixelCount);
frequencyAug = tblAug.PixelCount/sum(tblAug.PixelCount);
frequencyAugCrop = tblAugCrop.PixelCount/sum(tblAugCrop.PixelCount);

%% Separate image and label into training and validation sets
rng('default'); %for reproducability

% Calculate amount of images and shuffle indices
numFilesNone = numel(imdsNone.Files);
numFilesCrop = numel(imdsCrop.Files);
numFilesAugCrop = numel(imdsAugCrop.Files);
numFilesAug = numel(imdsAug.Files);
shuffledIndicesTransferTotalNone = randperm(numFilesNone);
shuffledIndicesTransferTotalCrop = randperm(numFilesCrop);
shuffledIndicesTransferTotalAugCrop = randperm(numFilesAugCrop);
shuffledIndicesTransferTotalAug = randperm(numFilesAug);

% Use 70% of the images for training.
NNone = round(0.70 * numFilesNone);
NCrop = round(0.70 * numFilesCrop);
NAugCrop = round(0.70 * numFilesAugCrop);
NAug = round(0.70 * numFilesAug);
trainingIdxNone = shuffledIndicesTransferTotalNone(1:NNone);
trainingIdxCrop = shuffledIndicesTransferTotalCrop(1:NCrop);
trainingIdxAugCrop = shuffledIndicesTransferTotalAugCrop(1:NAugCrop);
trainingIdxAug = shuffledIndicesTransferTotalAug(1:NAug);

% Use the rest for testing.
testIdxNone = shuffledIndicesTransferTotalNone(NNone+1:end);
testIdxCrop = shuffledIndicesTransferTotalCrop(NCrop+1:end);
testIdxAugCrop = shuffledIndicesTransferTotalAugCrop(NAugCrop+1:end);
testIdxAug = shuffledIndicesTransferTotalAug(NAug+1:end);

% Create image datastores for training and test.
trainingImagesNone = imdsNone.Files(trainingIdxNone);
trainingImagesCrop = imdsCrop.Files(trainingIdxCrop);
trainingImagesAugCrop = imdsAugCrop.Files(trainingIdxAugCrop);
trainingImagesAug = imdsAug.Files(trainingIdxAug);
testImagesNone = imdsNone.Files(testIdxNone);
testImagesCrop = imdsCrop.Files(testIdxCrop);
testImagesAugCrop = imdsAugCrop.Files(testIdxAugCrop);
testImagesAug = imdsAug.Files(testIdxAug);

imdsTrainNone = imageDatastore(trainingImagesNone);
imdsTrainCrop = imageDatastore(trainingImagesCrop);
imdsTrainAugCrop = imageDatastore(trainingImagesAugCrop);
imdsTrainAug = imageDatastore(trainingImagesAug);
imdsTestNone = imageDatastore(testImagesNone);
imdsTestCrop = imageDatastore(testImagesCrop);
imdsTestAugCrop = imageDatastore(testImagesAugCrop);
imdsTestAug = imageDatastore(testImagesAug);

% Create pixel label datastores for training and test.
trainingLabelsNone = pxdsNone.Files(trainingIdxNone);
trainingLabelsCrop = pxdsCrop.Files(trainingIdxCrop);
trainingLabelsAugCrop = pxdsAugCrop.Files(trainingIdxAugCrop);
trainingLabelsAug = pxdsAug.Files(trainingIdxAug);
testLabelsNone = pxdsNone.Files(testIdxNone);
testLabelsCrop = pxdsCrop.Files(testIdxCrop);
testLabelsAugCrop = pxdsAugCrop.Files(testIdxAugCrop);
testLabelsAug = pxdsAug.Files(testIdxAug);

pxdsTrainNone = pixelLabelDatastore(trainingLabelsNone, classNames, pixelLabelIDs);
pxdsTrainCrop = pixelLabelDatastore(trainingLabelsCrop, classNames, pixelLabelIDs);
pxdsTrainAugCrop = pixelLabelDatastore(trainingLabelsAugCrop, classNames, pixelLabelIDs);
pxdsTrainAug = pixelLabelDatastore(trainingLabelsAug, classNames, pixelLabelIDs);
pxdsTestNone = pixelLabelDatastore(testLabelsNone, classNames, pixelLabelIDs);
pxdsTestCrop = pixelLabelDatastore(testLabelsCrop, classNames, pixelLabelIDs);
pxdsTestAugCrop = pixelLabelDatastore(testLabelsAugCrop, classNames, pixelLabelIDs);
pxdsTestAug = pixelLabelDatastore(testLabelsAug, classNames, pixelLabelIDs);

numTrainingImagesNone = numel(imdsTrainNone.Files);
numTrainingImagesCrop = numel(imdsTrainCrop.Files);
numTrainingImagesAugCrop = numel(imdsTrainAugCrop.Files);
numTrainingImagesAug = numel(imdsTrainAug.Files);

numTestingImagesNone = numel(imdsTestNone.Files);
numTestingImagesCrop = numel(imdsTestCrop.Files);
numTestingImagesAugCrop = numel(imdsTestAugCrop.Files);
numTestingImagesAug = numel(imdsTestAug.Files);

% create labelimage datastore for training validation
impxdsTestNone = pixelLabelImageDatastore(imdsTestNone, pxdsTestNone);
impxdsTestCrop = pixelLabelImageDatastore(imdsTestCrop, pxdsTestCrop);
impxdsTestAugCrop = pixelLabelImageDatastore(imdsTestAugCrop, pxdsTestAugCrop);
impxdsTestAug = pixelLabelImageDatastore(imdsTestAug, pxdsTestAug);

%% Load VGG16 based Net
imageSize = [360 480 3];
numClasses = numel(classNames);
lgraphTransferTotal = load('/home/s1590294/nets/transferTotalNet.mat');
%Convert to layergraph to be able to edit network
lgraphTransferTotal = layerGraph(lgraphTransferTotal.transferTotalNet);

%% Class weight balancing
imageFreqNone = tblNone.PixelCount ./ tblNone.ImagePixelCount;
imageFreqCrop = tblCrop.PixelCount ./ tblCrop.ImagePixelCount;
imageFreqAugCrop = tblAugCrop.PixelCount ./ tblAugCrop.ImagePixelCount;
imageFreqAug = tblAug.PixelCount ./ tblAug.ImagePixelCount;
classWeightsNone = median(imageFreqNone) ./ imageFreqNone;
classWeightsCrop = median(imageFreqCrop) ./ imageFreqCrop;
classWeightsAugCrop = median(imageFreqAugCrop) ./ imageFreqAugCrop;
classWeightsAug = median(imageFreqAug) ./ imageFreqAug;

%Construct new pixelclassification layer
pxLayerNone = pixelClassificationLayer('Name','labels','classNames',tblNone.Name,'ClassWeights',classWeightsNone);
pxLayerCrop = pixelClassificationLayer('Name','labels','classNames',tblCrop.Name,'ClassWeights',classWeightsCrop);
pxLayerAugCrop = pixelClassificationLayer('Name','labels','classNames',tblAugCrop.Name,'ClassWeights',classWeightsAugCrop);
pxLayerAug = pixelClassificationLayer('Name','labels','classNames',tblAug.Name,'ClassWeights',classWeightsAug);

%Replace existing pixelclassification layer
lgraphTransferTotalNone = removeLayers(lgraphTransferTotal,'labels');
lgraphTransferTotalNone = addLayers(lgraphTransferTotalNone, pxLayerNone);
lgraphTransferTotalNone = connectLayers(lgraphTransferTotalNone,'softmax','labels');

lgraphTransferTotalCrop = removeLayers(lgraphTransferTotal,'labels');
lgraphTransferTotalCrop = addLayers(lgraphTransferTotalCrop, pxLayerNone);
lgraphTransferTotalCrop = connectLayers(lgraphTransferTotalCrop,'softmax','labels');

lgraphTransferTotalAug = removeLayers(lgraphTransferTotal,'labels');
lgraphTransferTotalAug = addLayers(lgraphTransferTotalAug, pxLayerAug);
lgraphTransferTotalAug = connectLayers(lgraphTransferTotalAug,'softmax','labels');

lgraphTransferTotalAugCrop = removeLayers(lgraphTransferTotal,'labels');
lgraphTransferTotalAugCrop = addLayers(lgraphTransferTotalAugCrop, pxLayerAug);
lgraphTransferTotalAugCrop = connectLayers(lgraphTransferTotalAugCrop,'softmax','labels');

%% Image augmentation to generate more training data

augmenter = imageDataAugmenter(...
    'RandXReflection',true,...
    'FillValue',0,...
    'RandXTranslation',[-100 100],...
    'RandYTranslation',[-100 100],...
    'RandRotation',[-45, 45],...
    'RandYReflection',true,...
    'RandXScale',[0.75 1.5],...
    'RandYScale',[0.75 1.5]...
    );

%% Create an imagelabel datastore specifically used in training segmentation networks
pximdsNone = pixelLabelImageDatastore(imdsTrainNone,pxdsTrainNone,'outputSize',imageSize,'DataAugmentation',augmenter);
pximdsCrop = pixelLabelImageDatastore(imdsTrainCrop,pxdsTrainCrop,'outputSize',imageSize,'DataAugmentation',augmenter);
pximdsAugCrop = pixelLabelImageDatastore(imdsTrainAugCrop,pxdsTrainAugCrop,'outputSize',imageSize,'DataAugmentation',augmenter);
pximdsAug = pixelLabelImageDatastore(imdsTrainAug,pxdsTrainAug,'outputSize',imageSize,'DataAugmentation',augmenter);

%% Traning options 
optionsNone = trainingOptions('sgdm' ...
    ,'Momentum',0.9 ...
    ,'InitialLearnRate',1e-3 ...
    ,'L2Regularization',5e-4 ...
    ,'MaxEpochs',500 ...  
    ,'MiniBatchSize',10 ...
    ,'Plots','training-progress' ...
    ,'validationData',impxdsTestNone...
    ,'ValidationPatience',15 ...
    ,'Shuffle','every-epoch' ...
    ,'Verbose',0 ...
    ,'ExecutionEnvironment','auto');

optionsCrop = trainingOptions('sgdm' ...
    ,'Momentum',0.9 ...
    ,'InitialLearnRate',1e-3 ...
    ,'L2Regularization',5e-4 ...
    ,'MaxEpochs',500 ...  
    ,'MiniBatchSize',10 ...
    ,'Plots','training-progress' ...
    ,'validationData',impxdsTestCrop...
    ,'ValidationPatience',15 ...
    ,'Shuffle','every-epoch' ...
    ,'Verbose',0 ...
    ,'ExecutionEnvironment','auto');

optionsAugCrop = trainingOptions('sgdm' ...
    ,'Momentum',0.9 ...
    ,'InitialLearnRate',1e-3 ...
    ,'L2Regularization',5e-4 ...
    ,'MaxEpochs',500 ...  
    ,'MiniBatchSize',10 ...
    ,'Plots','training-progress' ...
    ,'validationData',impxdsTestAugCrop...
    ,'ValidationPatience',15 ...
    ,'Shuffle','every-epoch' ...
    ,'Verbose',0 ...
    ,'ExecutionEnvironment','auto');

optionsAug = trainingOptions('sgdm' ...
    ,'Momentum',0.9 ...
    ,'InitialLearnRate',1e-3 ...
    ,'L2Regularization',5e-4 ...
    ,'MaxEpochs',500 ...  
    ,'MiniBatchSize',10 ...
    ,'Plots','training-progress' ...
    ,'validationData',impxdsTestAug...
    ,'ValidationPatience',15 ...
    ,'Shuffle','every-epoch' ...
    ,'Verbose',0 ...
    ,'ExecutionEnvironment','auto');

%% Train network!
[trainedNetTransferTotalNone, infoNone] = trainNetwork(pximdsNone,lgraphTransferTotalNone,optionsNone);
[trainedNetTransferTotalCrop, infoCrop] = trainNetwork(pximdsCrop,lgraphTransferTotalCrop,optionsCrop);
[trainedNetTransferTotalAugCrop, infoAugCrop] = trainNetwork(pximdsAugCrop,lgraphTransferTotalAugCrop,optionsAugCrop);
[trainedNetTransferTotalAug, infoAug] = trainNetwork(pximdsAug,lgraphTransferTotalAug,optionsAug);


% %% Test network
% I = read(imdsTest);
% C = semanticseg(I, trainednetTransfer);
% 
% B = labeloverlay(I,C,'Transparency',0.6);
% figure
% imshow(B)

%% Evaluate network performance

pxdsResultsTransferTotalNone = semanticseg(imdsTestNone,trainedNetTransferTotalNone, ...
    'MiniBatchSize',1, ...
    'Verbose',true);
pxdsResultsTransferTotalCrop = semanticseg(imdsTestCrop,trainedNetTransferTotalCrop, ...
    'MiniBatchSize',1, ...
    'Verbose',true);
pxdsResultsTransferTotalAugCrop = semanticseg(imdsTestAugCrop,trainedNetTransferTotalAugCrop, ...
    'MiniBatchSize',1, ...
    'Verbose',true);
pxdsResultsTransferTotalAug = semanticseg(imdsTestAug,trainedNetTransferTotalAug, ...
    'MiniBatchSize',1, ...
    'Verbose',true);
 
%metricsTransfer = evaluateSemanticSegmentation(pxdsResultsTransfer,pxds,'Verbose',false);
% metrics.DataSetMetrics;         %Average performance of entire network over all classes
% metrics.ClassMetrics;           %Performance of network per class
 
%% Save Net and results
save('/home/s1590294/OutTransferTotal', 'pxdsResultsTransferTotalNone');
save('/home/s1590294/OutTransferTotal', 'pxdsResultsTransferTotalCrop');
save('/home/s1590294/OutTransferTotal', 'pxdsResultsTransferTotalAug');
save('/home/s1590294/OutTransferTotal', 'pxdsResultsTransferTotalAugCrop');

save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalNone');
save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalCrop');
save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalAug');
save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalAugCrop');

save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalNone');
save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalCrop');
save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalAug');
save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalAugCrop');


