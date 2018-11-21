%   This is the total transfer script. It takes a segmentation network trained on street data (provided by matworks) 
%   and trains it on all the different data sets
clc; close all;
%% Create image and label Datastores
%Image and Label data locations
imDirNone = '/deepstore/datasets/ram/slss/ImagesOriginal/';
imDirCrop = '/deepstore/datasets/ram/slss/cropImages/';
imDirAug = '/deepstore/datasets/ram/slss/augImages/';
pxDirNone = '/deepstore/datasets/ram/slss/LabelsOriginal/';
pxDirCrop = '/deepstore/datasets/ram/slss/cropLabels/';
pxDirAug = '/deepstore/datasets/ram/slss/augLabels/';

classNames = ["Skin" "Lesion"]; %define classes
pixelLabelID = [1 2];           %define pixel-label IDs

%Create Image and Label datastores
imdsNone = imageDatastore(imDirNone);   
imdsCrop = imageDatastore(imDirCrop);   
imdsAug = imageDatastore(imDirAug);   
pxdsNone = pixelLabelDatastore(pxDirNone,classNames,pixelLabelID);
pxdsCrop = pixelLabelDatastore(pxDirCrop,classNames,pixelLabelID);
pxdsAug = pixelLabelDatastore(pxDirAug,classNames,pixelLabelID);
%% Calculate label frequency for each data set
tblNone = countEachLabel(pxdsNone);
tblCrop = countEachLabel(pxdsCrop);
tblAug = countEachLabel(pxdsAug);
frequencyNone = tblNone.PixelCount/sum(tblNone.PixelCount);
frequencyCrop = tblCrop.PixelCount/sum(tblCrop.PixelCount);
frequencyAug = tblAug.PixelCount/sum(tblAug.PixelCount);

%% Separate image and label into training and validation sets
rng('default'); %for reproducability

% Calculate amount of images and shuffle indices
numFilesNone = numel(imdsNone.Files);
numFilesCrop = numel(imdsCrop.Files);
numFilesAug = numel(imdsAug.Files);
shuffledIndicesTransferTotalNone = randperm(numFilesNone);
shuffledIndicesTransferTotalCrop = randperm(numFilesCrop);
shuffledIndicesTransferTotalAug = randperm(numFilesAug);

% Use 70% of the images for training.
NNone = round(0.70 * numFilesNone);
NCrop = round(0.70 * numFilesCrop);
NAug = round(0.70 * numFilesAug);
trainingIdxNone = shuffledIndicesTransferTotalNone(1:NNone);
trainingIdxCrop = shuffledIndicesTransferTotalCrop(1:NCrop);
trainingIdxAug = shuffledIndicesTransferTotalAug(1:NAug);

% Use the rest for testing.
testIdxNone = shuffledIndicesTransferTotalNone(NNone+1:end);
testIdxCrop = shuffledIndicesTransferTotalCrop(NCrop+1:end);
testIdxAug = shuffledIndicesTransferTotalAug(NAug+1:end);

% Create image datastores for training and test.
trainingImagesNone = imdsNone.Files(trainingIdxNone);
trainingImagesCrop = imdsCrop.Files(trainingIdxCrop);
trainingImagesAug = imdsAug.Files(trainingIdxAug);
testImagesNone = imdsNone.Files(testIdxnone);
testImagesCrop = imdsCrop.Files(testIdxCrop);
testImagesAug = imdsAug.Files(testIdxAug);

imdsTrainNone = imageDatastore(trainingImagesNone);
imdsTrainCrop = imageDatastore(trainingImagesCrop);
imdsTrainAug = imageDatastore(trainingImagesAug);
imdsTestNone = imageDatastore(testImagesNone);
imdsTestCrop = imageDatastore(testImagesCrop);
imdsTestAug = imageDatastore(testImagesAug);

% Create pixel label datastores for training and test.
trainingLabelsNone = pxdsNone.Files(trainingIdxNone);
trainingLabelsCrop = pxdsCrop.Files(trainingIdxCrop);
trainingLabelsAug = pxdsAug.Files(trainingIdxAug);
testLabelsNone = pxdsNone.Files(testIdxNone);
testLabelsCrop = pxdsCrop.Files(testIdxCrop);
testLabelsAug = pxdsAug.Files(testIdxAug);

pxdsTrainNone = pixelLabelDatastore(trainingLabelsNone, classNames, pixelLabelIDs);
pxdsTrainCrop = pixelLabelDatastore(trainingLabelsCrop, classNames, pixelLabelIDs);
pxdsTrainAug = pixelLabelDatastore(trainingLabelsAug, classNames, pixelLabelIDs);
pxdsTestNone = pixelLabelDatastore(testLabelsNone, classNames, pixelLabelIDs);
pxdsTestCrop = pixelLabelDatastore(testLabelsCrop, classNames, pixelLabelIDs);
pxdsTestAug = pixelLabelDatastore(testLabelsAug, classNames, pixelLabelIDs);

numTrainingImagesNone = numel(imdsTrainNone.Files);
numTrainingImagesCrop = numel(imdsTrainCrop.Files);
numTrainingImagesAug = numel(testImagesAug.Files);

numTestingImagesNone = numel(imdsTestNone.Files);
numTestingImagesCrop = numel(imdsTestCrop.Files);
numTestingImagesAug = numel(imdsTestAug.Files);

% create labelimage datastore for training validation
impxdsTestNone = pixelLabelImageDatastore(imdsTestNone, pxdsTestNone);
impxdsTestCrop = pixelLabelImageDatastore(imdsTestCrop, pxdsTestCrop);
impxdsTestAug = pixelLabelImageDatastore(imdsTestAug, pxdsTestAug);

%% Load VGG16 based Net
imageSize = [360 480 3];
numClasses = numel(classNames);
lgraphTransferTotal = load('/home/s1590294/nets/transferTotalNet.mat');
%Convert to layergraph to be able to edit network
lgraphTransferTotal = layerGraph(lgraphTransferTotal);

%% Class weight balancing
imageFreqNone = tblNone.PixelCount ./ tblNone.ImagePixelCount;
imageFreqCrop = tblCrop.PixelCount ./ tblCrop.ImagePixelCount;
imageFreqAug = tblAug.PixelCount ./ tblAug.ImagePixelCount;
classWeightsNone = median(imageFreqNone) ./ imageFreqNone;
classWeightsCrop = median(imageFreqCrop) ./ imageFreqCrop;
classWeightsAug = median(imageFreqAug) ./ imageFreqAug;

%Construct new pixelclassification layer
pxLayerNone = pixelClassificationLayer('Name','labels','classNames',tblNone.Name,'ClassWeights',classWeightsNone);
pxLayerCrop = pixelClassificationLayer('Name','labels','classNames',tblCrop.Name,'ClassWeights',classWeightsCrop);
pxLayerAug = pixelClassificationLayer('Name','labels','classNames',tblAug.Name,'ClassWeights',classWeightsAug);

%Replace existing pixelclassification layer
lgraphTransferTotalNone = removeLayers(lgraphTransferTotalNone,'labels');
lgraphTransferTotalNone = addLayers(lgraphTransferTotalNone, pxLayerNone);
lgraphTransferTotalNone = connectLayers(lgraphTransferTotalNone,'softmax','labels');

lgraphTransferTotalCrop = removeLayers(lgraphTransferTotalCrop,'labels');
lgraphTransferTotalCrop = addLayers(lgraphTransferTotalCrop, pxLayerNone);
lgraphTransferTotalCrop = connectLayers(lgraphTransferTotalCrop,'softmax','labels');

lgraphTransferTotalAug = removeLayers(lgraphTransferTotalAug,'labels');
lgraphTransferTotalAug = addLayers(lgraphTransferTotalAug, pxLayerAug);
lgraphTransferTotalAug = connectLayers(lgraphTransferTotalAug,'softmax','labels');

%% Image augmentation to generate more training data

augmenter = imageDataAugmenter(...
    'RandXReflection',true,...
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
pximdsAug = pixelLabelImageDatastore(imdsTrainAug,pxdsTrainAug,'outputSize',imageSize,'DataAugmentation',augmenter);

%% Traning options 
optionsNone = trainingOptions('sgdm' ...
    ,'Momentum',0.9 ...
    ,'InitialLearnRate',1e-3 ...
    ,'L2Regularization',5e-4 ...
    ,'MaxEpochs',500 ...  
    ,'MiniBatchSize',10 ...
    ,'Plots','training-progress' ...
    ,'validationData',impxdsTestAug...
    ,'ValidationPatience',15 ...
    ,'Shuffle','every-epoch' ...
    ,'Verbose','false'...
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
    ,'Verbose','false'...
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
    ,'Verbose','false'...
    ,'ExecutionEnvironment','auto');




%% Train network!
[trainedNetTransferTotalNone, infoNone] = trainNetwork(pximdsNone,lgraphTransferTotalNone,optionsNone);
[trainedNetTransferTotalCrop, infoCrop] = trainNetwork(pximdsCrop,lgraphTransferTotalCrop,optionsCrop);
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

save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalNone');
save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalCrop');
save('/home/s1590294/OutTransferTotal', 'trainedNetTransferTotalAug');

save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalNone');
save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalCrop');
save('/home/s1590294/OutTransferTotal', 'shuffledIndicesTransferTotalAug');


