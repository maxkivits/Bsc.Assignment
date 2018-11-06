%% This script generates a semantic segmentation network for skin lesions using transfer learning on the vgg16 net 
clc; close all;

%% Load vgg16 Neural net that this segmentation network is based on
%vgg16();

%% Resize input images and labels to [360,480,3]
%transferResize(41,[360 480 3]);

totalNumber = 167;               %total number of pictures
imageResize = [360 480];      	%network input image size

% for iRes = 1:totalNumber
%     if iRes < 10                %stupid naming convention workaround
%         resizeImg = imread(strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\img00',num2str(iRes),'.JPG'));
%         resizeLab = imread(strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\lab00',num2str(iRes),'.png'));
%         resizedImg = imresize(resizeImg,imageResize);
%         resizedLab = imresize(resizeLab,imageResize);
%         imwrite(resizedImg,strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\img00',num2str(iRes),'.JPG'));
%         imwrite(resizedLab,strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\lab00',num2str(iRes),'.png'));
%     elseif iRes < 100
%         resizeImg = imread(strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\img0',num2str(iRes),'.JPG'));
%         resizeLab = imread(strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\lab0',num2str(iRes),'.png'));
%         resizedImg = imresize(resizeImg,imageResize);
%         resizedLab = imresize(resizeLab,imageResize);
%         imwrite(resizedImg,strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\img0',num2str(iRes),'.JPG'));
%         imwrite(resizedLab,strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\lab0',num2str(iRes),'.png'));
%     else
%         resizeImg = imread(strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\img',num2str(iRes),'.JPG'));
%         resizeLab = imread(strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\lab',num2str(iRes),'.png'));
%         resizedImg = imresize(resizeImg,imageResize);
%         resizedLab = imresize(resizeLab,imageResize);
%         imwrite(resizedImg,strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Images\img',num2str(iRes),'.JPG'));
%         imwrite(resizedLab,strcat('C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\Labels\lab',num2str(iRes),'.png'));       
%     end 
% end

%% Create image and label Datastores
imDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\augImages";
pxDir = "C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\augLabels";

classNames = ["Skin" "Lesion"]; %define classes
pixelLabelID = [1 2];

imds = imageDatastore(imDir);
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);

%% Test if imageDatastore is correct
figure
imageTest = readimage(imds,1);
imshow(imageTest);

%% Overlay Label and image to check 
overlayImage = readimage(imds,150);
overlayLabel = readimage(pxds,150);
B = labeloverlay(overlayImage,overlayLabel);
figure 
imshow(B)


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


%% use segnetLayers to generate layergraph of the segmentation network based on the vgg16 classification network
imageSize = [360 480 3];
numClasses = numel(classNames);
lgraphtransfer = segnetLayers(imageSize,numClasses,'vgg16');
figure
plot(lgraphtransfer);

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
    'MiniBatchSize',1, ...
    'Plots','training-progress', ...
    'validationData',impxdsTest,...
    'ValidationPatience',10,...
    'Shuffle','every-epoch', ...
    'VerboseFrequency',100);

%% Train network!
[trainednetTransfer, info] = trainNetwork(pximds,lgraphtransfer,options);


%% Test network
I = read(imdsTest);
C = semanticseg(I, trainednetTransfer);

B = labeloverlay(I,C,'Transparency',0.6);
figure
imshow(B)

%% Evaluate network performance

pxdsResults = semanticseg(imds,trainednetTransfer, ...
    'MiniBatchSize',1, ...
    'WriteLocation','C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Tests\test15\Labels', ...
    'Verbose',true);
 
metrics = evaluateSemanticSegmentation(pxdsResults,pxds,'Verbose',true);
metrics.DataSetMetrics;         %Average performance of entire network over all classes
metrics.ClassMetrics;           %Performance of network per class


