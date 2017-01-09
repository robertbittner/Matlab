function [bPlotCreationSuccessful] = plotFmrMotionEstimatesATWM1(folderDefinition, parametersProjectFiles, parametersFunctionalMriSequence, parametersMotionCorrection, cr)
%%% CREATION OF MOTION PLOT FOR A SINGLE RUN %%%
%% Load parameters

global iStudy
global strSubject

nDataPoints = parametersFunctionalMriSequence.nVolumesFmr;
%% Define plot properties
colorBackground = [0 0 0];
colorTransX = [1 0 0];
colorTransY = [0 1 0];
colorTransZ = [0 0 1];
colorRotationX = [1 1 0];
colorRotationY = [1 0 1];
colorRotationZ = [0 1 1];
colorLegendText = [1 1 1];

strFormatGraphicsFile = 'png';
strExtGraphicsFile = strcat('.', strFormatGraphicsFile);
%% Import data %%
%%% Define SDM file name
strExtSdmFileMotionCorr = sprintf('_%s%s', parametersMotionCorrection.aStrAbbrMotionCorrection, parametersProjectFiles.extSingleDesignMatrixFile);
strSdmFileMotion    = strrep(parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr, parametersProjectFiles.extFunctionalProject, strExtSdmFileMotionCorr);
strPathSdmFileMotion = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strSdmFileMotion);

sdm = importdata(strPathSdmFileMotion,' ',9);

%% Define parameters for plot
scrsz = get(0, 'ScreenSize');
motionPlot = figure('color','black','Position',[1 scrsz(4)/2.2 scrsz(3) scrsz(4)/2.2]);
c = axes;
set(c,'FontName','times', 'FontWeight','bold', 'FontSize',8, 'XColor','w', 'YColor','w')
xLimit = nDataPoints;
xTick = 1:round(nDataPoints * 0.10):nDataPoints;
xTickLabel = sprintf('%.0f\n', xTick);
yLimit = 3;
yTick = -yLimit:yLimit;
yTickLabel = sprintf('%.0f\n', yTick);
set(c, 'XLim',[1 xLimit], 'XTick', xTick, 'XTickLabel', xTickLabel)
set(c, 'YLim',[-yLimit yLimit],'YTick',yTick,'YTickLabel',yTickLabel)
set(c,'YGrid','on')
set(get(c,'XLabel'),'String', 'Number of Volumes','FontName','times', 'FontWeight','bold', 'FontSize',8)
set(get(c,'YLabel'),'String', 'Motion in mm','FontName','times', 'FontWeight','bold', 'FontSize',8)
set(c,'Color', colorBackground)

%% Create plot
hold on
plotTitle = sprintf('%s %s run%s %s', strSubject, iStudy, num2str(cr), parametersMotionCorrection.strAbbrInterpolationMethod);  %'Rigid Body Motion Parameters - 3 Translations, 3 Rotations'
title(plotTitle,'Color','w','FontName','times', 'FontWeight','bold', 'FontSize',10);
lineWidth = 0.25;
TransX = plot(sdm.data(1:nDataPoints,1),'-','color', colorTransX,'LineWidth',lineWidth);
TransY = plot(sdm.data(1:nDataPoints,2),'-','color', colorTransY,'LineWidth',lineWidth);
TransZ = plot(sdm.data(1:nDataPoints,3),'-','color', colorTransZ,'LineWidth',lineWidth);
RotationX = plot(sdm.data(1:nDataPoints,4),'-','color', colorRotationX,'LineWidth',lineWidth);
RotationY = plot(sdm.data(1:nDataPoints,5),'-','color', colorRotationY,'LineWidth',lineWidth);
RotationZ = plot(sdm.data(1:nDataPoints,6),'-','color', colorRotationZ,'LineWidth',lineWidth);
leg = legend('TranslationX', 'TranslationY', 'TranslationZ','RotationX','RotationY','RotationZ');
set(leg, 'Color',[0 0 0], 'TextColor', colorLegendText,'Location','EastOutside', 'FontSize',4);

%% Save Motion Plot as PNG
set(gcf,'PaperPosition',[-1.17 1.82 13.33 4.85],'PaperType','A4', 'PaperOrientation', 'portrait')
set(gcf, 'InvertHardCopy', 'off');
strMotionPlotFile = strrep(strSdmFileMotion, parametersProjectFiles.extSingleDesignMatrixFile, strExtGraphicsFile);
strPathMotionPlotFile = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strMotionPlotFile);

print(motionPlot,['-d' strFormatGraphicsFile],'-r600', strPathMotionPlotFile);

%% Copy PNG- and SDM-file to motion correction directory
copyfile(strPathMotionPlotFile, fullfile(folderDefinition.motionCorrection, strMotionPlotFile));    % copy motion plot file
copyfile(strPathSdmFileMotion, fullfile(folderDefinition.motionCorrection, strSdmFileMotion));      % copy motion sdm file
bPlotCreationSuccessful = true;
close all


end