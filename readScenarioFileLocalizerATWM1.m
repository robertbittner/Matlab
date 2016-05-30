function parametersParadigm_LOC = readScenarioFileLocalizerATWM1(pathScenarioFile);


TR = 2000;

parametersParadigm_LOC_MRI = parametersParadigm_LOC_MRI_ATWM1;

strBaselinePre = parametersParadigm_LOC_MRI.strBaselinePre;
strBaselinePost = parametersParadigm_LOC_MRI.strBaselinePost;
strTemplate = 'TEMPLATE';
strIndexFirstTrial = parametersParadigm_LOC_MRI.strFirstTrial;
strIndexEndOfTrialDefinitions = parametersParadigm_LOC_MRI.strIndexEndOfTrialDefinitions;


strPosition = parametersParadigm_LOC_MRI.strPosition;
strDefaultTrial = parametersParadigm_LOC_MRI.strStandardTrial;
strTargeTrial = parametersParadigm_LOC_MRI.strTargetTrial;

%strFolder = 'D:\Forschung\Projekte\ATWM1\Paradigma\ATWM1_Paradigm_MRI_07.12.15\ATWM1_Localizer_MRI\';
strFolder = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\Scenario_Files\';

pathScenarioFile = pathScenarioFile
fid = fopen(pathScenarioFile, 'rt');


bStartOfTrialDefinitionsFound = false;
bEndOfTrialDefinitionsFound = false;
nPreviousLinesStored = 5;
for cl = 1:nPreviousLinesStored
    strPreviousLine{cl} = '';
end
strLine = '';
nTrials = 0;
while ~feof(fid)
    strTempPreviousLine = strPreviousLine;
    for cl = 1:nPreviousLinesStored
        strPreviousLine{cl + 1} = strTempPreviousLine{cl};
    end
    strLine = fgetl(fid);
    strPreviousLine{1} = strLine;
    strPreviousLine = strPreviousLine;

    %%% Detect duration of pre-baseline
    if ~isempty(strfind(strLine, strBaselinePre))
        parametersParadigm_LOC.durationBaselinePreSeconds = str2double(regexprep(strPreviousLine{3}, '\D', ''));
        parametersParadigm_LOC.durationBaselinePreVolumes = parametersParadigm_LOC.durationBaselinePreSeconds / TR;
    end
    
    %%% Detect duration of post-baseline
    if ~isempty(strfind(strLine, strBaselinePost))
        parametersParadigm_LOC.durationBaselinePostSeconds = str2double(regexprep(strPreviousLine{2}, '\D', ''));
        parametersParadigm_LOC.durationBaselinePostVolumes = parametersParadigm_LOC.durationBaselinePostSeconds / TR;
    end
    
    %%% Detect the start of the trial definitions
    if ~isempty(strfind(strLine, strIndexFirstTrial))
        bStartOfTrialDefinitionsFound = true;
    end
    %%% Detect the end of the trial definitions
    if bStartOfTrialDefinitionsFound == true && bEndOfTrialDefinitionsFound == false && ~isempty(strfind(strLine, strIndexEndOfTrialDefinitions))
        bEndOfTrialDefinitionsFound = true;
    end
    
    %%% Analyse trial definitions
    if bStartOfTrialDefinitionsFound == true && bEndOfTrialDefinitionsFound == false
        nTrials = nTrials + 1;
        % 166     0  131  1950  blank blank blank localizer 	 blank blank blank localizer_inv 	 blank blank blank localizer_target 	  0 	 "128_4_Objects_Pos4_DefaultTrial"	"Localizer_128_4_Objects_Pos4_DefaultTrial" 	 45.96 45.96 -45.96 45.96 -45.96 -45.96 45.96 -45.96;
        text = textscan(strLine, '%f %f %f %f %*[^\n]');
        iTrialInfo = strfind(strLine, '"');
        parametersParadigm_LOC.strTrialInfo{nTrials}                = strLine(iTrialInfo(3) + 1 : iTrialInfo(4) - 1);
        parametersParadigm_LOC.triggerVolume(nTrials)               = text{1};
        parametersParadigm_LOC.interTrialIntervalSeconds(nTrials)   = text{2};
        parametersParadigm_LOC.interTrialIntervalVolumes(nTrials)   = ceil(parametersParadigm_LOC.interTrialIntervalSeconds(nTrials) / TR);
        
    end
end

parametersParadigm_LOC.nTrials = nTrials;

%%% Determine position & trial type (default trial or target trial)
aStrTrialType = {};
aStrConditionPositionTrial = {};
aStrConditionTargetTrial = {};
aStrConditionPositionTargetTrial = {};
for ct = 1:parametersParadigm_LOC.nTrials
    indPosition = strfind(parametersParadigm_LOC.strTrialInfo{ct}, strPosition) + length(strPosition);
    iPosition(ct) = str2double(parametersParadigm_LOC.strTrialInfo{ct}(indPosition));
    
    if strfind(parametersParadigm_LOC.strTrialInfo{ct}, parametersParadigm_LOC_MRI.strStandardTrial)
        aStrTrialType{ct} = parametersParadigm_LOC_MRI.strStandardTrial;
    end
    
    if strfind(parametersParadigm_LOC.strTrialInfo{ct}, parametersParadigm_LOC_MRI.strTargetTrial)
        aStrTrialType{ct} = parametersParadigm_LOC_MRI.strTargetTrial;
    end

    aStrConditionPositionTrial{ct} = sprintf('%s_%i', parametersParadigm_LOC_MRI.strPosition, iPosition(ct));
    aStrConditionTargetTrial{ct} = sprintf('%s', aStrTrialType{ct});
    aStrConditionPositionTargetTrial{ct} = sprintf('%s_%i_%s', parametersParadigm_LOC_MRI.strPosition, iPosition(ct), aStrTrialType{ct});
    
end

aStrConditionPosition = unique(aStrConditionPositionTrial);
aStrConditionTarget = unique(aStrConditionTargetTrial);
aStrConditionPositionTarget = unique(aStrConditionPositionTargetTrial);

nConditionsPosition = numel(aStrConditionPosition);
nConditionsTarget = numel(aStrConditionTarget);
nConditionsPositionTarget = numel(aStrConditionPositionTarget);

strAnalysisPosition         = 'Position';
strAnalysisTarget           = 'Target';
strAnalysisPositionTarget   = 'PositionTarget';

parametersParadigm_LOC.aConditions = {
    aStrConditionPosition           nConditionsPosition         aStrConditionPositionTrial          strAnalysisPosition
    %aStrConditionTarget             nConditionsTarget           aStrConditionTargetTrial            strAnalysisTarget
    %aStrConditionPositionTarget     nConditionsPositionTarget   aStrConditionPositionTargetTrial    strAnalysisPositionTarget
    };
%tstes = aStrConditionPositionTrial
%es = strAnalysisPosition

parametersParadigm_LOC.nAnalyses = size(parametersParadigm_LOC.aConditions);
parametersParadigm_LOC.nAnalyses = parametersParadigm_LOC.nAnalyses(1);

%%% Determine the starting volume of each trial
%parametersParadigm_LOC = parametersParadigm_LOC
addVolume = parametersParadigm_LOC.interTrialIntervalVolumes;
%return
% Choose correct approach
volumeDuration = 1;
addVolume = addVolume + volumeDuration;

for ct = 1:nTrials
    if ct == 1
        startVolume(ct) = addVolume(ct) + parametersParadigm_LOC.durationBaselinePreVolumes;
    else
        startVolume(ct) = startVolume(ct - 1) + addVolume(ct - 1);
    end
    %%% Detect errors in the trial timing as defined in the scenario file
    bTrialTimingCorrect(ct) = isequal(startVolume(ct), parametersParadigm_LOC.triggerVolume(ct));
end

%%% Display error in the trial timing
parametersParadigm_LOC.indTrialTimingError = find(~bTrialTimingCorrect);
for ce = 1:numel(parametersParadigm_LOC.indTrialTimingError)
    strMessage = sprintf('Timing error in trial #%i', parametersParadigm_LOC.indTrialTimingError(ce));
    disp(strMessage);
    strMessage = sprintf('Calculated start volume: %i\nDefined trigger volume: %i\n\n', startVolume(parametersParadigm_LOC.indTrialTimingError(ce)), parametersParadigm_LOC.triggerVolume(parametersParadigm_LOC.indTrialTimingError(ce)));
    disp(strMessage);
end


%%% Create design matrix
aConditions = parametersParadigm_LOC.aConditions;
for ca = 1:parametersParadigm_LOC.nAnalyses
    for cc = 1:aConditions{ca, 2}
        strCondition = aConditions{ca, 1}(cc);
        indCondition = find(ismember(aConditions{ca, 3}, strCondition));
        nTrialsCondition{ca, cc} = numel(indCondition);
        for ct = 1:nTrialsCondition{ca, cc}
            startVolumeCondition{ca}{cc}{ct} = startVolume(indCondition(ct));
            endVolumeCondition{ca}{cc}{ct} = startVolumeCondition{ca}{cc}{ct};
        end
        %test = startVolumeCondition{ca}{cc}{:}
    end
end

%startVolumeCondition = startVolumeCondition

parametersParadigm_LOC.nTrialsCondition = nTrialsCondition;
parametersParadigm_LOC.startVolumeCondition = startVolumeCondition;
parametersParadigm_LOC.endVolumeCondition   = endVolumeCondition;
parametersParadigm_LOC.lastVolume = startVolume(end) + parametersParadigm_LOC.durationBaselinePostVolumes;
parametersParadigm_LOC.nrOfVolumes = parametersParadigm_LOC.lastVolume;

end