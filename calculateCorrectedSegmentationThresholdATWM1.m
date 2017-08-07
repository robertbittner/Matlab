function calculateCorrectedSegmentationThresholdATWM1()

clear all
clc

global iStudy
iStudy = 'ATWM1';

parametersBrainSegmentation             = eval(['parametersBrainSegmentation', iStudy]);

[bvSegmThreshold, bAbort] = getBvSegmentationThresholdATWM1(parametersBrainSegmentation);
if bAbort
    return
end

correctionValue = round(bvSegmThreshold * parametersBrainSegmentation.correctionFactor);
corrBvSegmThreshold = bvSegmThreshold - correctionValue;

%fprintf('Preselected correction factor: %s\n\n', num2str(parametersBrainSegmentation.correctionFactor));
fprintf('Preselected correction factor: %s %%\n\n', num2str(parametersBrainSegmentation.correctionFactor * 100));
fprintf('Threshold determined by BrainVoyager: %i\n\n', bvSegmThreshold);
fprintf('Please use the corrected treshold: %i\n\n', corrBvSegmThreshold);


end


function [bvSegmThreshold, bAbort] = getBvSegmentationThresholdATWM1(parametersBrainSegmentation)

strPrompt   = {'Enter the segmentation treshold calculated by BrainVoyager'};
strName     = 'Input for calculation of corrected segmentation treshold';
nrOfLines   = 1;

bAbort = false;
bvSegmThreshold = inputdlg(strPrompt, strName, nrOfLines);
if isempty(bvSegmThreshold)
    bvSegmThreshold = [];
    bAbort = true;
    fprintf('No segmentation threshold entered, aborting function!\n\n');
    return
end

bvSegmThreshold = str2double(bvSegmThreshold{1});

if ~ismember(bvSegmThreshold, parametersBrainSegmentation.vRangeSegmThresholds)
    fprintf('WARNING: The entered segmentation threshold is not within the range of acceptable values!\n');
    fprintf('WARNING: Brain segmentation results based on this threshold will most likely be poor!\n\n');
end

end