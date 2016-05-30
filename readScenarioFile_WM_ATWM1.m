function parametersParadigmRun = readScenarioFile_WM_ATWM1(parametersParadigm, pathScenarioFile);

parametersParadigmRun = parametersParadigm;

fid = fopen(pathScenarioFile, 'rt');

bStartOfTrialDefinitionsFound = false;
bEndOfTrialDefinitionsFound = false;
nPreviousLines = 5;
for cl = 1:nPreviousLines
    aStrPreviousLine{cl} = '';
end
strLine = '';
nTrials = 0;
while ~feof(fid)
    strTempPreviousLine = aStrPreviousLine;
    for cl = 1:nPreviousLines
        aStrPreviousLine{cl + 1} = strTempPreviousLine{cl};
    end
    strLine = fgetl(fid);
    aStrPreviousLine{1} = strLine;

    %%% Detect duration of pre-baseline
    if ~isempty(strfind(strLine, parametersParadigmRun.strBaselinePre))
        iDuration = strfind(aStrPreviousLine , parametersParadigmRun.strDuration);
        iDuration(cellfun(@isempty, iDuration)) = {0};
        iDuration = find(cell2mat(iDuration));
        parametersParadigmRun.durationBaselinePreSeconds = str2double(regexprep(aStrPreviousLine{iDuration}, '\D', ''));
        parametersParadigmRun.durationBaselinePreVolumes = parametersParadigmRun.durationBaselinePreSeconds / parametersParadigmRun.TR;
    end
    
    %%% Detect duration of post-baseline
    if ~isempty(strfind(strLine, parametersParadigmRun.strBaselinePost))
        iDuration = strfind(aStrPreviousLine , parametersParadigmRun.strDuration);
        iDuration(cellfun(@isempty, iDuration)) = {0};
        iDuration = find(cell2mat(iDuration));
        parametersParadigmRun.durationBaselinePostSeconds = str2double(regexprep(aStrPreviousLine{iDuration}, '\D', ''));
        parametersParadigmRun.durationBaselinePostVolumes = parametersParadigmRun.durationBaselinePostSeconds / parametersParadigmRun.TR;
    end
    
    %%% Detect the start of the trial definitions
    if ~isempty(strfind(strLine, parametersParadigmRun.strFirstTrial))
        bStartOfTrialDefinitionsFound = true;
    end
    %%% Detect the end of the trial definitions
    if bStartOfTrialDefinitionsFound == true && bEndOfTrialDefinitionsFound == false && ~isempty(strfind(strLine, parametersParadigmRun.strIndexEndOfTrialDefinitions))
        bEndOfTrialDefinitionsFound = true;
    end
    
    %%% Analyse trial definitions
    if bStartOfTrialDefinitionsFound == true && bEndOfTrialDefinitionsFound == false && ~isempty(strLine)
        nTrials = nTrials + 1;
        parametersParadigmRun = readTrialInfo_WM_ATMW1(parametersParadigmRun, nTrials, strLine);
        parametersParadigmRun = readTimingParameters_WM_ATWM1(parametersParadigmRun, nTrials, strLine);
        parametersParadigmRun = readConditionParameters_WM_ATWM1(parametersParadigmRun, nTrials);
        parametersParadigmRun = readRetrievalParameters_WM_ATWM1(parametersParadigmRun, nTrials);
    end
end

parametersParadigmRun.nTrials = nTrials;

parametersParadigmRun = determineStartVolumesTrials_WM_ATWM1(parametersParadigmRun);


%{
%%% Create design matrix
aConditions = parametersParadigmRun.aConditions;
for ca = 1:parametersParadigmRun.nAnalyses
    for cc = 1:aConditions{ca, 2}
        strCondition = aConditions{ca, 1}(cc);
        indCondition = find(ismember(aConditions{ca, 3}, strCondition));
        nTrialsCondition{ca, cc} = numel(indCondition);
        for ct = 1:nTrialsCondition{ca, cc}
            startVolumeCondition{ca}{cc}{ct} = startVolume(indCondition(ct));
            endVolumeCondition{ca}{cc}{ct} = startVolumeCondition{ca}{cc}{ct};
        end
    end
end

parametersParadigmRun.nTrialsCondition = nTrialsCondition;
parametersParadigmRun.startVolumeCondition = startVolumeCondition;
parametersParadigmRun.endVolumeCondition   = endVolumeCondition;
parametersParadigmRun.lastVolume = startVolume(end) + parametersParadigmRun.durationBaselinePostVolumes;

ts = parametersParadigmRun.lastVolume
%}
%{
for ct = 1:parametersParadigmRun.nTrials
    sdksd = (parametersParadigmRun.condition.indCondition{ct})
end

tset = parametersParadigmRun.condition.indCondition
for cc = 1:parametersParadigmRun.nConditions
    %test = find(parametersParadigmRun.condition.indCondition)
end
%}


end


function parametersParadigmRun = readTrialInfo_WM_ATMW1(parametersParadigmRun, nTrials, strLine);

iTrialInfo = strfind(strLine, parametersParadigmRun.strIndexTrialInfo);
parametersParadigmRun.strTrialInfoEncoding{nTrials} = strLine(iTrialInfo(1) + 1 : iTrialInfo(2) - 1);
parametersParadigmRun.strTrialInfoRetrieval{nTrials} = strLine(iTrialInfo(3) + 1 : iTrialInfo(4) - 1);


end


function parametersParadigmRun = readTimingParameters_WM_ATWM1(parametersParadigmRun, nTrials, strLine);

text = textscan(strLine, '%f %f %f %f %f %f %f %f %f %*[^\n]');

strTrialInfoEncoding   = parametersParadigmRun.strTrialInfoEncoding{nTrials};%strLine(iTrialInfo(1) + 1 : iTrialInfo(2) - 1);

%%% Read trigger values
parametersParadigmRun.triggerVolumeEncoding(nTrials)   = text{1};
parametersParadigmRun.triggerVolumeRetrieval(nTrials)  = text{2};

%%% Read timing parameters from values used in Presentaion
parametersParadigmRun.timing.cueTime(nTrials)                          = text{3};
parametersParadigmRun.timing.preparationTime(nTrials)                  = text{4};
parametersParadigmRun.timing.encodingTime(nTrials)                     = text{5};
parametersParadigmRun.timing.singleStimulusPresentationTime(nTrials)   = text{6};
parametersParadigmRun.timing.delayTime(nTrials)                        = text{7};
parametersParadigmRun.timing.retrievalTime(nTrials)                    = text{8};
parametersParadigmRun.timing.interTrialInterval(nTrials)               = text{9};

% 1_1_Encoding_Working_Memory_MRI_Nonsalient_Cued_DoChange_CuedRetrieval_300_300_399_11601_3000_18400_gabor_patch_orientation_179_072_113_044_target_position_1_4_retrieval_position_4
%%% Read timing parameters from trial info
nTimingParameters = 6;
for c = 1:numel(parametersParadigmRun.aStrRetrieval)
    aTimingParameters{c} = strfind(strTrialInfoEncoding, parametersParadigmRun.aStrRetrieval{c});
end
iTimingParameters = cell2mat(aTimingParameters);
iSeparators = strfind(strTrialInfoEncoding, parametersParadigmRun.strSeparator);
iSeparators = iSeparators(iSeparators > iTimingParameters);
iSeparators = iSeparators(1:nTimingParameters + 1);

parametersParadigmRun.trialInfoTiming.cueTime(nTrials)             = str2double(strTrialInfoEncoding(iSeparators(1)+1 : iSeparators(2)-1));
parametersParadigmRun.trialInfoTiming.preparationTime(nTrials)     = str2double(strTrialInfoEncoding(iSeparators(2)+1 : iSeparators(3)-1));
parametersParadigmRun.trialInfoTiming.encodingTime(nTrials)        = str2double(strTrialInfoEncoding(iSeparators(3)+1 : iSeparators(4)-1));
parametersParadigmRun.trialInfoTiming.delayTime(nTrials)           = str2double(strTrialInfoEncoding(iSeparators(4)+1 : iSeparators(5)-1));
parametersParadigmRun.trialInfoTiming.retrievalTime(nTrials)       = str2double(strTrialInfoEncoding(iSeparators(5)+1 : iSeparators(6)-1));
parametersParadigmRun.trialInfoTiming.interTrialInterval(nTrials)  = str2double(strTrialInfoEncoding(iSeparators(6)+1 : iSeparators(7)-1));


end


function parametersParadigmRun = readConditionParameters_WM_ATWM1(parametersParadigmRun, nTrials);

%%% Read condition parameters
strTrialInfoEncoding = parametersParadigmRun.strTrialInfoEncoding{nTrials}

%%% Condition
for c = 1:numel(parametersParadigmRun.aConditions)
    aIndCondtion{c} = ~isempty(strfind(strTrialInfoEncoding, parametersParadigmRun.aConditions{c}));
end
parametersParadigmRun.condition.indCondition{nTrials} = cell2mat(aIndCondtion);
parametersParadigmRun.condition.strCondition{nTrials} = parametersParadigmRun.aConditions{parametersParadigmRun.condition.indCondition{nTrials}};

%%% Salience
for c = 1:numel(parametersParadigmRun.aSalienceConditions)
    aIndSalience{c} = ~isempty(strfind(strTrialInfoEncoding, parametersParadigmRun.aSalienceConditions{c}));
end
parametersParadigmRun.condition.indSalience{nTrials} = cell2mat(aIndSalience);
parametersParadigmRun.condition.strSalience{nTrials} = parametersParadigmRun.aSalienceConditions{parametersParadigmRun.condition.indSalience{nTrials}};

%%% Cue
for c = 1:numel(parametersParadigmRun.aCueConditions)
    strCueCondition = sprintf('%s%s%s', parametersParadigmRun.strSeparator, parametersParadigmRun.aCueConditions{c}, parametersParadigmRun.strSeparator);
    aIndCue{c} = ~isempty(strfind(strTrialInfoEncoding, strCueCondition));
end
parametersParadigmRun.condition.indCue{nTrials} = cell2mat(aIndCue);
parametersParadigmRun.condition.strCue{nTrials} = parametersParadigmRun.aCueConditions{parametersParadigmRun.condition.indCue{nTrials}};

%%% Change
for c = 1:numel(parametersParadigmRun.aStrChange)
    aIndChange{c} = ~isempty(strfind(strTrialInfoEncoding, parametersParadigmRun.aStrChange{c}));
end
parametersParadigmRun.condition.indChange{nTrials} = cell2mat(aIndChange);
parametersParadigmRun.condition.strChange{nTrials} = parametersParadigmRun.aStrChange{parametersParadigmRun.condition.indChange{nTrials}};

%%% Retrieval
for c = 1:numel(parametersParadigmRun.aStrRetrieval)
    aIndRetrieval{c} = ~isempty(strfind(strTrialInfoEncoding, parametersParadigmRun.aStrRetrieval{c}));
end
parametersParadigmRun.condition.indRetrieval{nTrials} = cell2mat(aIndRetrieval);
parametersParadigmRun.condition.strRetrieval{nTrials} = parametersParadigmRun.aStrRetrieval{parametersParadigmRun.condition.indRetrieval{nTrials}};


end


function parametersParadigmRun = readRetrievalParameters_WM_ATWM1(parametersParadigmRun, nTrials);

%%% Read Retrieval Parameters
strTrialInfoRetrieval  = parametersParadigmRun.strTrialInfoRetrieval{nTrials};
iOrientation = strfind(strTrialInfoRetrieval, parametersParadigmRun.strOrientation);
iSeparators = strfind(strTrialInfoRetrieval, parametersParadigmRun.strSeparator);
iSeparators = iSeparators(iSeparators > iOrientation);
iSeparators = iSeparators(1:2);
parametersParadigmRun.orientationRetrievalStimulus(nTrials) = str2double(strTrialInfoRetrieval(iSeparators(1)+1 :iSeparators(2)-1));

iPosition = strfind(strTrialInfoRetrieval, parametersParadigmRun.strPosition);
iSeparators = strfind(strTrialInfoRetrieval, parametersParadigmRun.strSeparator);
iSeparators = iSeparators(iSeparators > iPosition);
parametersParadigmRun.positionRetrievalStimulus(nTrials) = str2double(strTrialInfoRetrieval(iSeparators+1 : end));


end



function parametersParadigmRun = determineStartVolumesTrials_WM_ATWM1(parametersParadigmRun);

for ct = 1:parametersParadigmRun.nTrials
    parametersParadigmRun.timing.preEncodingTime(ct)             = parametersParadigmRun.timing.cueTime(ct) + parametersParadigmRun.timing.preparationTime(ct);
    parametersParadigmRun.timing.encodingAndDelayTime(ct)        = parametersParadigmRun.timing.encodingTime(ct) + parametersParadigmRun.timing.delayTime(ct);
    parametersParadigmRun.timing.encodingAndDelayTimeRounded(ct) = ceil(parametersParadigmRun.timing.encodingAndDelayTime(ct)*0.01)*100;
    parametersParadigmRun.timing.retrievalAndItiTime(ct)         = parametersParadigmRun.timing.retrievalTime(ct) + parametersParadigmRun.timing.interTrialInterval(ct);
    parametersParadigmRun.timing.retrievalAndItiTimeRounded(ct)  = ceil(parametersParadigmRun.timing.retrievalAndItiTime(ct)*0.01)*100;
end

for ct = 1:parametersParadigmRun.nTrials
    if ct == 1
        parametersParadigmRun.startVolumeTrialEncoding(ct)  = ((parametersParadigmRun.durationBaselinePreSeconds + parametersParadigmRun.timing.preEncodingTime(ct)) / parametersParadigmRun.TR) + 1;
    else
        parametersParadigmRun.startVolumeTrialEncoding(ct)  = parametersParadigmRun.startVolumeTrialRetrieval(ct - 1) + ((parametersParadigmRun.timing.retrievalAndItiTimeRounded(ct - 1) + parametersParadigmRun.timing.preEncodingTime(ct)) / parametersParadigmRun.TR);
    end
        parametersParadigmRun.startVolumeTrialRetrieval(ct) = parametersParadigmRun.startVolumeTrialEncoding(ct) + (parametersParadigmRun.timing.encodingAndDelayTimeRounded(ct) / parametersParadigmRun.TR);
end

parametersParadigmRun = detectTrialTimingErrors_WM_ATWM1(parametersParadigmRun);


end


function parametersParadigmRun = detectTrialTimingErrors_WM_ATWM1(parametersParadigmRun);

parametersParadigmRun.indTrialTimingErrorEncoding = find(~ismember(parametersParadigmRun.startVolumeTrialEncoding, parametersParadigmRun.triggerVolumeEncoding));
if ~isempty(parametersParadigmRun.indTrialTimingErrorEncoding)
    strMessage = sprintf('Timing error for encoding in trial #%i\n', parametersParadigmRun.indTrialTimingErrorEncoding);
    disp(strMessage);
end
parametersParadigmRun.indTrialTimingErrorRetrieval = find(~ismember(parametersParadigmRun.startVolumeTrialRetrieval, parametersParadigmRun.triggerVolumeRetrieval));
if ~isempty(parametersParadigmRun.indTrialTimingErrorRetrieval)
    strMessage = sprintf('Timing error for retrieval in trial #%i\n', parametersParadigmRun.indTrialTimingErrorRetrieval);
    disp(strMessage);
end


end



