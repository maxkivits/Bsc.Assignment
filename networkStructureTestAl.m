clc; close all;
%% Create image and label Datastores
%imLoc = '/deepstore/datasets/ram/slss/';
%pxLoc = '/deepstore/datasets/ram/slss/';

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
shuffledIndices = randperm(numFiles);

% Use 70% of the images for training.
N = round(0.70 * numFiles);
trainingIdx = shuffledIndices(1:N);

% Use the rest for testing.
testIdx = shuffledIndices(N+1:end);

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
%lgraph = load('/home/s1590294/net/lgraphSGN3.mat');
lgraphSGN1 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN1.mat');
lgraphSGN2 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN2.mat');
lgraphSGN3 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN3.mat');
lgraphSGN4 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN4.mat');
lgraphSGN5 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN5.mat');
lgraphSGN6 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGN6.mat');
lgraphVGG16 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphVGG16.mat');
lgraphVGG19 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphVGG19.mat');
lgraphFCN8 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphFCN8.mat');
lgraphFCN16 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphFCN16.mat');
lgraphFCN32 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphFCN32.mat');
lgraphSGNVGG16 = load('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Cluster\net\lgraphSGNVGG16.mat');


%Convert to layergraph to be able to edit network
%lgraph = layerGraph(lgraph.lgraphSGN3);
lgraphSGN1 = lgraphSGN1.haha;
lgraphSGN2 = lgraphSGN2.haha;
lgraphSGN3 = lgraphSGN3.haha;
lgraphSGN4 = lgraphSGN4.haha;
lgraphSGN5 = lgraphSGN5.haha;
lgraphSGN6 = lgraphSGN6.haha;
lgraphVGG16 = lgraphVGG16.lgraphVGG16;
lgraphVGG19 = lgraphVGG19.lgraphVGG19;
lgraphFCN8 = lgraphFCN8.lgraphFCN8;
lgraphFCN16 = lgraphFCN16.lgraphFCN16;
lgraphFCN32 = lgraphFCN32.lgraphFCN32;
lgraphSGNVGG16 = lgraphSGNVGG16.lgraphSGNVGG16;

%% Class weight balancing
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

pxLayer = pixelClassificationLayer('Name','labels','classNames',tbl.Name,'ClassWeights',classWeights);

%replace existing pixelclassification layer
lgraphSGN1 = removeLayers(lgraphSGN1,'pixelLabels');
lgraphSGN1 = addLayers(lgraphSGN1, pxLayer);
lgraphSGN1 = connectLayers(lgraphSGN1,'softmax','labels');

lgraphSGN2 = removeLayers(lgraphSGN2,'pixelLabels');
lgraphSGN2 = addLayers(lgraphSGN2, pxLayer);
lgraphSGN2 = connectLayers(lgraphSGN2,'softmax','labels');

lgraphSGN3 = removeLayers(lgraphSGN3,'pixelLabels');
lgraphSGN3 = addLayers(lgraphSGN3, pxLayer);
lgraphSGN3 = connectLayers(lgraphSGN3,'softmax','labels');

lgraphSGN4 = removeLayers(lgraphSGN4,'pixelLabels');
lgraphSGN4 = addLayers(lgraphSGN4, pxLayer);
lgraphSGN4 = connectLayers(lgraphSGN4,'softmax','labels');

lgraphSGN5 = removeLayers(lgraphSGN5,'pixelLabels');
lgraphSGN5 = addLayers(lgraphSGN5, pxLayer);
lgraphSGN5 = connectLayers(lgraphSGN5,'softmax','labels');

lgraphSGN6 = removeLayers(lgraphSGN6,'pixelLabels');
lgraphSGN6 = addLayers(lgraphSGN6, pxLayer);
lgraphSGN6 = connectLayers(lgraphSGN6,'softmax','labels');

lgraphVGG16 = removeLayers(lgraphVGG16,'pixelLabels');
lgraphVGG16 = addLayers(lgraphVGG16, pxLayer);
lgraphVGG16 = connectLayers(lgraphVGG16,'softmax','labels');

lgraphVGG19 = removeLayers(lgraphVGG19,'pixelLabels');
lgraphVGG19 = addLayers(lgraphVGG19, pxLayer);
lgraphVGG19 = connectLayers(lgraphVGG19,'softmax','labels');

lgraphFCN8 = removeLayers(lgraphFCN8,'pixelLabels');
lgraphFCN8 = addLayers(lgraphFCN8, pxLayer);
lgraphFCN8 = connectLayers(lgraphFCN8,'softmax','labels');

lgraphFCN16 = removeLayers(lgraphFCN16,'pixelLabels');
lgraphFCN16 = addLayers(lgraphFCN16, pxLayer);
lgraphFCN16 = connectLayers(lgraphFCN16,'softmax','labels');

lgraphFCN32 = removeLayers(lgraphFCN32,'pixelLabels');
lgraphFCN32 = addLayers(lgraphFCN32, pxLayer);
lgraphFCN32 = connectLayers(lgraphFCN32,'softmax','labels');

lgraphSGNVGG16 = removeLayers(lgraphSGNVGG16,'pixelLabels');
lgraphSGNVGG16 = addLayers(lgraphSGNVGG16, pxLayer);
lgraphSGNVGG16 = connectLayers(lgraphSGNVGG16,'softmax','labels');



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


%% List lgraph
lgraph = {lgraphSGN1,lgraphSGN2,lgraphSGN3,lgraphSGN4,lgraphSGN5,lgraphSGN6,lgraphVGG16,lgraphVGG19,lgraphFCN8,lgraphFCN16,lgraphFCN32,lgraphSGNVGG16};
lgraphname = {'lgraphSGN1','lgraphSGN2','lgraphSGN3','lgraphSGN4','lgraphSGN5','lgraphSGN6','lgraphVGG16','lgraphVGG19','lgraphFCN8','lgraphFCN16','lgraphFCN32','lgraphSGNVGG16'};


%% Traning options 
options = trainingOptions('sgdm', ...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.0005, ...
    'MaxEpochs',50, ...  
    'MiniBatchSize',1, ...
    'Plots','training-progress', ...
    'validationData',impxdsTest,...
    'ValidationPatience',25,...
    'Shuffle','every-epoch', ...
    'VerboseFrequency',100);

%% Train network
for iTrain=11:11%length(lgraph)
    fprintf(sprintf('Training network %s \n',lgraphname{iTrain}));
[trainedNet, info] = trainNetwork(pximds,lgraph{iTrain},options);


% %% Test network
% I = read(imdsTest);
% C = semanticseg(I, trainednetTransfer);
% 
% B = labeloverlay(I,C,'Transparency',0.6);
% figure
% imshow(B)

%% Evaluate network performance
outSem = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\SemantisSeg\';

pxdsResults = semanticseg(imdsTest,trainedNet, ...
    'MiniBatchSize',1, ...
    'Verbose',false,...
    'WriteLocation',sprintf('%s%s',outSem,lgraphname{iTrain}));
 
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
% metrics.DataSetMetrics;         %Average performance of entire network over all classes
% metrics.ClassMetrics;           %Performance of network per class

%% Save Net and results
% save('/home/s1590294/Out/DataTestCROP', 'trainednet_DataTestCROP');
% save('/home/s1590294/Out/DataTestCROP', 'pxdsResults_DataTestCROP');
% save('/home/s1590294/Out/DataTestCROP', 'shuffledIndices_DataTestCROP');

varLoc = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\Vars\';

save(sprintf('%strainednet_%s.mat',varLoc,lgraphname{iTrain}),'trainedNet')
save(sprintf('%spxdsResults_%s.mat',varLoc,lgraphname{iTrain}),'pxdsResults')
save(sprintf('%sshuffledIndices_%s.mat',varLoc,lgraphname{iTrain}),'shuffledIndices')
save(sprintf('%smetrics_%s.mat',varLoc,lgraphname{iTrain}),'metrics')

%% Test net
outImg = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Out\testImg\';
figure
imgIdx = {4,9,11,13,39,40,42,43,49};
for iTest=1:9
    I = readimage(imdsTest,imgIdx{iTest});
    C = semanticseg(I, trainedNet);

    B = labeloverlay(I,C,'colormap','parula','Transparency',0.75);
    subplot(3,3,iTest);
    imshow(B)
end
saveas(gcf,sprintf('%s%s_TestImg.png',outImg,lgraphname{iTrain}));
end
