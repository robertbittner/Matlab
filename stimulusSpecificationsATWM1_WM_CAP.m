function stimulusSpecifications = WMC2StimulusSpecifications_WM_CAP ();
%%% (c) Robert Bittner
%%% Study: WMC2_WM_CAP
%%% This function contains the specifications of the stimuli.

%stimulusSpecifications.cueStimulus = 'cueing_circle_r';

stimulusSpecifications.stimulusShape = {
    'circle'
%    'square'

    };

stimulusSpecifications.stimulusColor = {
    'black'
    'blue'
    'green'
    'red'
    'violet'
    'white'
    'yellow'
    };
stimulusSpecifications.stimulusColor = sort(stimulusSpecifications.stimulusColor);

%{
stimulusSpecifications.stimulusColorArray = {
    'red'
    'blue'
    };

stimulusSpecifications.targetColorIndex = [1, 2];
stimulusSpecifications.distractorColorIndex = wrev(stimulusSpecifications.targetColorIndex);
%}
%%% The file names of the blue and red stimuli are defined
%for col = 1:length(stimulusSpecifications.stimulusColorArray)
    for a = 1:length(stimulusSpecifications.stimulusColor)
        stimulusSpecifications.stimulusArray{a} = sprintf('%s_%s', stimulusSpecifications.stimulusShape{1}, stimulusSpecifications.stimulusColor{a});
    end
%end

stimulusSpecifications.blank = 'blank'; 

%stimulusSpecifications.nMaskStimuli = 32;
%stimulusSpecifications.maskSuffix = 'mask';

%{
for col = 2
    for a = 1:length(stimulusSpecifications.angleArray)
        stimulusSpecifications.stimulusArray{col}{a} = sprintf('%s', stimulusSpecifications.blank);
    end
end
%}
%{
%%% The file names of the masking stimuli are defined
for m = 1:stimulusSpecifications.nMaskStimuli
    stimulusSpecifications.maskArray{m} = sprintf('%s_%03i', stimulusSpecifications.maskSuffix, m);   
end
%}


stimulusSpecifications.fixationCross = 'fixation_cross_black';
stimulusSpecifications.alertingCross = 'fixation_cross_red';

%{
for col = 1:length(stimulusSpecifications.stimulusColorArray)
    stimulusSpecifications.alertingCross{col} = sprintf('fixation_cross_%s', stimulusSpecifications.stimulusColorArray{col});
end
%}
%{   
for col = 1:length(stimulusSpecifications.stimulusColorArray)
    stimulusSpecifications.alertingCross{col} = stimulusSpecifications.fixationCross;
end
%}

end