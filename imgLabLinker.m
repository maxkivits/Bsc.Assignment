%does things
close all;

imDir = 'C:\Users\Max Kivits\Documents\MATLAB\Bacheloropdracht\Data\temper';

%Define ground truth source images
gt = groundTruthDataSource(imDir);

%Define labels
ldc =labelDefinitionCreator();
addLabel(ldc,'Background',labelType.PixelLabel);
addLabel(ldc,'Skin',labelType.PixelLabel);
addLabel(ldc,'Lesion',labelType.PixelLabel);
labelDefs = create(ldc);