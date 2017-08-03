function createParametersMriSessionFileATWM1()
clear all
clc

global iStudy
iStudy = 'ATWM1';

%{
parametersNetwork = parametersNetworkATWM1
parametersNetwork.strCurrentComputer = 'PSYCH - Windows PC';
%}

%% Determine current computer and load folder definitions
%%{
parametersNetwork = determineCurrentComputerATWM1
%}
folderDefinition = loadFolderDefinitionATWM1(parametersNetwork);

%% Check server access
bAllFoldersCanBeAccessed = checkFolderAccessATWM1(folderDefinition, parametersNetwork);
if bAllFoldersCanBeAccessed == false
    return
end
hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%% Load parameters
parametersStudy                 = eval(['parametersStudy', iStudy]);
parametersMriSessionStandard 	= eval(['parametersMriSessionStandard', iStudy]);
parametersGroups                = eval(['parametersGroups', iStudy]);

%%{
%% Determine current subject
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'single';
[strGroup, strSubject, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end
%}
%{
%%% REMOVE
parametersProjectFiles = parametersProjectFilesATWM1
[folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = setTestConfigurationParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles);
strSubject = aStrSubject{1}
iSession = 1;
%%% REMOVE
%}
%%{
%% Determine whether standard parameters need to be changed
[bUseStandardParameters, bAbort] = selectParameterModificationOptionsATWM1;
if bAbort == true
    return
end
%}
%bUseStandardParameters = false;
if bUseStandardParameters
    [iSession, parametersMriCurrentSession, bAbort] = setParametersCurrentMriSessionToStandardValuesATWM1(parametersMriSessionStandard);
    if bAbort == true
        return
    end
else
    %%{
    %% Determine session of current subject
    [iSession, bAbort] = determineMriSessionATWM1(aStrSubject, nSubjects);
    if bAbort == true
        return
    end
    %}
    %% Manual editing of MriSessionParameters
    [parametersMriCurrentSession, bAbort] = enterParametersCurrentMriSessionATWM1(parametersStudy, parametersMriSessionStandard);
    if bAbort == true
        return
    end
end

strParametersMriSessionFile         = defineParametersMriSessionFileNameATWM1(strSubject, iSession);
strPathParametersMriSessionFile     = determinePathParametersMriScanFileATWM1(folderDefinition, parametersNetwork, strParametersMriSessionFile);

writeParametersMriSessionFileATWM1(parametersMriCurrentSession, strParametersMriSessionFile, strPathParametersMriSessionFile);
copyParametersMriSessionFileToServerATWM1(folderDefinition, parametersNetwork, strPathParametersMriSessionFile);


end


function [bUseStandardParameters, bAbort] = selectParameterModificationOptionsATWM1()
%%
global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strTitle = 'Parameter Modification Options';
strPrompt = 'Please select modification options for ParametersMriSession';
strOption1 = sprintf('%sUse standard parameters%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sEdit parameters manually%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strPrompt, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        bUseStandardParameters = true;
        bAbort = false;
    case strOption2
        bUseStandardParameters = false;
        bAbort = false;
    otherwise
        bUseStandardParameters = false;
        bAbort = true;
        strMessage = sprintf('No valid option selected.\nAborting function.');
        disp(strMessage);
end


end


function [iSession, parametersMriCurrentSession, bAbort] = setParametersCurrentMriSessionToStandardValuesATWM1(parametersMriSessionStandard)

bAbort = false;

% Set default values
iSession = 1;
parametersMriCurrentSession = parametersMriSessionStandard;
aStrFieldnames = fieldnames(parametersMriCurrentSession);

% Select fieldnames which refer to file indices
indexFileIndex = strfind(aStrFieldnames, 'fileIndex');
indexFileIndex = not(cellfun('isempty', indexFileIndex));
aStrFileIndexFieldnames = aStrFieldnames(indexFileIndex);

% Enter standard values into allFileIndices field
counterFileIndices = 0;
for cfn = 1:numel(aStrFileIndexFieldnames)
    for cfne = 1:numel(parametersMriCurrentSession.(matlab.lang.makeValidName(aStrFileIndexFieldnames{cfn})))
        counterFileIndices = counterFileIndices + 1;
        parametersMriCurrentSession.allFileIndices(counterFileIndices) = parametersMriCurrentSession.(matlab.lang.makeValidName(aStrFileIndexFieldnames{cfn}))(cfne);
    end
end

% Enter standard value into nInvalidRuns field
parametersMriCurrentSession.nInvalidRuns = 0;

%%{
bParametersCorrect = false;
while bParametersCorrect == false
    [parametersMriCurrentSession, aStrFileIndexDescription, bAbort] = displayFileIndicesForCorrectionATWM1(parametersMriSessionStandard, parametersMriCurrentSession, aStrFileIndexFieldnames);
    if bAbort == true
        return
    end
    
    %% Evaluate parameters
    [parametersMriCurrentSession, bParametersCorrect, bAbort] = searchForDuplicateOfMissingFileIndicesATWM1(parametersMriCurrentSession, aStrFileIndexDescription, bParametersCorrect);
    if bAbort == true
        return
    end
end
%}
parametersMriCurrentSession = determineNumberOfMeasurementsInRunATWM1(parametersMriCurrentSession, aStrFileIndexFieldnames);
parametersMriCurrentSession.bVerified = true;


end


function [parametersMriCurrentSession, bAbort] = enterParametersCurrentMriSessionATWM1(parametersStudy, parametersMriSessionStandard)

bAbort = false;

% Set default values
parametersMriCurrentSession = parametersMriSessionStandard;
aStrFieldnames = fieldnames(parametersMriCurrentSession);

% Select fieldnames which refer to file indices
indexFileIndex = strfind(aStrFieldnames, 'fileIndex');
indexFileIndex = not(cellfun('isempty', indexFileIndex));
aStrFileIndexFieldnames = aStrFieldnames(indexFileIndex);

parametersMriCurrentSession.allFileIndices = [];

aStrAnswers = {};
bParametersCorrect = false;
while bParametersCorrect == false
    if isempty(aStrAnswers)
        [parametersMriSessionStandard, parametersMriCurrentSession, bAbort] = enterNumberOfAdditionalLocalizersATWM1(parametersStudy, parametersMriSessionStandard, parametersMriCurrentSession, bAbort);
        if bAbort == true
            return
        end
        [parametersMriSessionStandard, parametersMriCurrentSession, bAbort] = enterNumberOfInvalidRunsATWM1(parametersMriSessionStandard, parametersMriCurrentSession, bAbort);
        if bAbort == true
            return
        end
        [parametersMriCurrentSession, bAbort] = enterFileIndicesATWM1(parametersMriSessionStandard, parametersMriCurrentSession, aStrFileIndexFieldnames, bAbort);
        if bAbort == true
            return
        end
    end
    
    [parametersMriCurrentSession, aStrFileIndexDescription, bAbort] = displayFileIndicesForCorrectionATWM1(parametersMriSessionStandard, parametersMriCurrentSession, aStrFileIndexFieldnames);
    if bAbort == true
        return
    end
    %% Evaluate parameters
    [parametersMriCurrentSession, bParametersCorrect, bAbort] = searchForDuplicateOfMissingFileIndicesATWM1(parametersMriCurrentSession, aStrFileIndexDescription, bParametersCorrect);
    if bAbort == true
        return
    end
end

parametersMriCurrentSession = determineNumberOfMeasurementsInRunATWM1(parametersMriCurrentSession, aStrFileIndexFieldnames);
parametersMriCurrentSession.bVerified = true;


end


function [parametersMriSessionStandard, parametersMriCurrentSession, bAbort] = enterNumberOfAdditionalLocalizersATWM1(parametersStudy, parametersMriSessionStandard, parametersMriCurrentSession, bAbort)
%% Enter the number of additional anatomical localizers
bParametersEntered = false;
while ~bParametersEntered
    strPrompt = sprintf('Please enter number of additional anatomical localizers.');
    strTitle = sprintf('Number of additional anatomical localizers');
    nrOfLines = 1;
    strDefaultAnswer = {'0'};
    aStrAnswer = inputdlg(strPrompt, strTitle, nrOfLines, strDefaultAnswer);
    nrOfAdditionalLocalizers = str2double(aStrAnswer{1});
    if ~isempty(aStrAnswer) && mod(nrOfAdditionalLocalizers, 1) == 0
        bParametersEntered = true;
        if nrOfAdditionalLocalizers > 0
            parametersMriCurrentSession.bAdditionalLocalizer    = true;
            parametersMriCurrentSession.nAnatomicalLocalizers   = parametersMriSessionStandard.nAnatomicalLocalizers + nrOfAdditionalLocalizers;
          
            for cr = 1:parametersMriCurrentSession.nAnatomicalLocalizers
                parametersMriSessionStandard.fileIndexAnatomicalLocalizer(cr)   = NaN;
                parametersMriCurrentSession.fileIndexAnatomicalLocalizer(cr)    = NaN;
                parametersMriSessionStandard.strDescription.fileIndexAnatomicalLocalizer{cr} = sprintf('%s_run_%i', parametersStudy.strFullAnatomicalLocalizer, cr);
            end
        end
    else
        bAbort = openInvalidParametersDialogATWM1;
    end
    if bAbort == true
        break
    end
end
if bAbort == true
    return
end



end

function [parametersMriSessionStandard, parametersMriCurrentSession, bAbort] = enterNumberOfInvalidRunsATWM1(parametersMriSessionStandard, parametersMriCurrentSession, bAbort)
%% Enter the number of invalid runs
bParametersEntered = false;
while ~bParametersEntered
    strPrompt = sprintf('Please enter number of invalid runs.');
    strTitle = sprintf('Number of invalid runs');
    nrOfLines = 1;
    strDefaultAnswer = {'0'};
    aStrAnswer = inputdlg(strPrompt, strTitle, nrOfLines, strDefaultAnswer);
    if ~isempty(aStrAnswer)
        strDescriptionFileIndexInvalidRuns = parametersMriSessionStandard.strDescription.fileIndexInvalidRuns{1};
        bParametersEntered = true;
        parametersMriCurrentSession.nInvalidRuns = str2double(aStrAnswer{1});
        for cr = 1:parametersMriCurrentSession.nInvalidRuns
            parametersMriSessionStandard.fileIndexInvalidRuns(cr)   = NaN;
            parametersMriCurrentSession.fileIndexInvalidRuns(cr)    = NaN;
            parametersMriSessionStandard.strDescription.fileIndexInvalidRuns{cr} = sprintf('%s_%i', strDescriptionFileIndexInvalidRuns, cr);
        end
    else
        bAbort = openInvalidParametersDialogATWM1;
    end
    if bAbort == true
        break
    end
end
if bAbort == true
    return
end


end


function [parametersMriCurrentSession, bAbort] = enterFileIndicesATWM1(parametersMriSessionStandard, parametersMriCurrentSession, aStrFileIndexFieldnames, bAbort)
%% Enter file indices
for cfi = 1:numel(aStrFileIndexFieldnames)
    strFieldname = aStrFileIndexFieldnames{cfi};
    % Special case: file indices for invalid runs, which might be empty
    strInvalidRuns = 'InvalidRuns';
    if contains(strFieldname, strInvalidRuns) && parametersMriCurrentSession.nInvalidRuns == 0
        continue
    end
    bParametersEntered = false;
    while ~bParametersEntered
        aStrPrompt = {};
        aStrDefaultAnswer = {};
        for cr = 1:numel(parametersMriSessionStandard.(matlab.lang.makeValidName(strFieldname)))
            strPrompt = sprintf('Please enter filex index for %s', parametersMriSessionStandard.strDescription.(matlab.lang.makeValidName(strFieldname)){cr});
            aStrPrompt = [aStrPrompt, strPrompt];
            strAnswer = sprintf('%i', parametersMriSessionStandard.(matlab.lang.makeValidName(strFieldname))(cr));
            aStrDefaultAnswer = [aStrDefaultAnswer, strAnswer];
        end
        strTitle = 'Input';
        nrOfLines = 1;
        aStrAnswer = inputdlg(aStrPrompt, strTitle, nrOfLines, aStrDefaultAnswer);
        if ~isempty(aStrAnswer)
            bParametersEntered = true;
        else
            bAbort = openInvalidParametersDialogATWM1;
        end
        if bAbort == true
            break
        end
    end
    if bAbort == true
        return
    end
    parametersMriCurrentSession = addAnswersToParametersMriSessionATWM1(parametersMriCurrentSession, strFieldname, aStrAnswer);
end


end


function parametersMriCurrentSession = addAnswersToParametersMriSessionATWM1(parametersMriCurrentSession, strFieldname, aStrAnswer)
%%
for ca = 1:numel(aStrAnswer)
    if isempty(aStrAnswer{ca}) || isempty(str2double(aStrAnswer{ca}))
        aStrAnswer{ca} = '0';
    end
end
vAnswer = [];
for ca = 1:numel(aStrAnswer)
    vAnswer(ca) = str2double(aStrAnswer{ca});
end
vAnswer(vAnswer == 0) = NaN;
parametersMriCurrentSession.(matlab.lang.makeValidName(strFieldname)) = vAnswer;

parametersMriCurrentSession.allFileIndices = [parametersMriCurrentSession.allFileIndices, vAnswer];


end


function [parametersMriCurrentSession, bParametersCorrect, bAbort] = searchForDuplicateOfMissingFileIndicesATWM1(parametersMriCurrentSession, aStrFileIndexDescription, bParametersCorrect)
%%
% Replace NaN values for comparison
parametersMriCurrentSession.allFileIndices(isnan(parametersMriCurrentSession.allFileIndices)) = 0;

parametersMriCurrentSession.allFileIndices = sort(parametersMriCurrentSession.allFileIndices);
parametersMriCurrentSession.nRuns = numel(parametersMriCurrentSession.allFileIndices);

vCaculatedFileIndices = 1:parametersMriCurrentSession.nRuns;

if ~isequal(vCaculatedFileIndices, parametersMriCurrentSession.allFileIndices)
    strMessageFileIndices = sprintf('Number of file indices: %i\n', parametersMriCurrentSession.nRuns);
    strMessageFileIndices = sprintf('%s\n', strMessageFileIndices);
    
    % Detect missing indices
    vMissingFileIndices = find(~ismember(vCaculatedFileIndices, parametersMriCurrentSession.allFileIndices));
    if ~isempty(vMissingFileIndices)
        for cmfi = 1:numel(vMissingFileIndices)
            strMessageFileIndices = sprintf('%sMissing entries for file index %i\n', strMessageFileIndices, vMissingFileIndices(cmfi));
        end
    end
    strMessageFileIndices = sprintf('%s\n', strMessageFileIndices);
    
    % Detect duplicate indices
    u = unique(parametersMriCurrentSession.allFileIndices);
    n = histc(parametersMriCurrentSession.allFileIndices, u);
    vDuplicateFileIndices = u(n > 1);
    nDuplicateFileIndices = n(n > 1);
    if ~isempty(vDuplicateFileIndices)
        for cd = 1:numel(vDuplicateFileIndices)
            strMessageFileIndices = sprintf('%s%i duplicate entries for file index %i\n', strMessageFileIndices, nDuplicateFileIndices(cd), vDuplicateFileIndices(cd));
            indDuplicates = find(parametersMriCurrentSession.allFileIndices == vDuplicateFileIndices(cd));
            for c = 1:numel(indDuplicates)
                strDuplicate = aStrFileIndexDescription{indDuplicates(c)};
                strMessageFileIndices = sprintf('%s%s\n', strMessageFileIndices, strDuplicate);
            end
            strMessageFileIndices = sprintf('%s\n', strMessageFileIndices);
        end
    end
    [bParametersCorrect, bAbort] = openIncorrectFileIndicesDialogATWM1(strMessageFileIndices, bParametersCorrect);
    if bAbort
        return
    end
else
    bAbort = false;
    bParametersCorrect = true;
end


end


function [bParametersCorrect, bAbort] = openIncorrectFileIndicesDialogATWM1(strMessageFileIndices, bParametersCorrect)
%%
global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strTitle = 'File index error';
strOption1 = sprintf('%sRe-Enter file indices%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sConfirm current file indices%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strMessageFileIndices, strTitle, strOption1, strOption2, strOption3, strOption1);
if ~isempty(choice)
    switch choice
        case strOption1
            bAbort = false;
        case strOption2
            bAbort = false;
            bParametersCorrect = true;
        case strOption3
            bAbort = true;
            fprintf('Incorrect file indices entered.\nAborting function.\n');
    end
else
    bAbort = true;
    fprintf('Incorrect file indices entered.\nAborting function.\n');
end


end


function [parametersMriCurrentSession, aStrFileIndexDescription, bAbort] = displayFileIndicesForCorrectionATWM1(parametersMriSessionStandard, parametersMriCurrentSession, aStrFileIndexFieldnames)
%% Show file indices for final evaluation
bInvalidEntryDetected = true;
while bInvalidEntryDetected
    bAbort = false;
    counterFileIndex = 0;
    for cfi = 1:numel(aStrFileIndexFieldnames)
        strFieldname = aStrFileIndexFieldnames{cfi};
        for cr = 1:numel(parametersMriCurrentSession.(matlab.lang.makeValidName(strFieldname)))
            counterFileIndex = counterFileIndex + 1;
            if cr == 1 && cfi > 1
                strOffset = sprintf('\n\n');
                strOffset = sprintf('');
            else
                strOffset = sprintf('');
            end
            aStrFileIndex{counterFileIndex} = num2str(parametersMriCurrentSession.(matlab.lang.makeValidName(strFieldname))(cr));
            aStrFileIndexDescription{counterFileIndex} = sprintf('%s', parametersMriSessionStandard.strDescription.(matlab.lang.makeValidName(strFieldname)){cr});
            strSummaryPrompt{counterFileIndex} = sprintf('%sFile index for %s:', strOffset, aStrFileIndexDescription{counterFileIndex});
        end
    end
    strTitle = 'Evaluate ParametersMriSession';
    nrOfLines = 1;
    
    aStrAnswers = (inputdlg(strSummaryPrompt, strTitle, nrOfLines, aStrFileIndex))';
    
    %% Detect invalid entries
    bInvalidEntryDetected = false;
    for ca = 1:numel(aStrAnswers)
        if isempty(str2double(aStrAnswers{ca}))
            bInvalidEntryDetected = true;
        end
    end
    
    if bInvalidEntryDetected
        bAbort = openInvalidParametersDialogATWM1;
        if bAbort == true
            return
        end
    end
end

%% Detect empty entries
if isempty(aStrAnswers)
    bAbort = openInvalidParametersDialogATWM1;
    if bAbort == true
        return
    end
else
    % Modify ParametersMriSession
    if ~isequal(aStrAnswers, aStrFileIndex)
        counterFileIndex = 0;
        for cfi = 1:numel(aStrFileIndexFieldnames)
            strFieldname = aStrFileIndexFieldnames{cfi};
            for cr = 1:numel(parametersMriCurrentSession.(matlab.lang.makeValidName(strFieldname)))
                counterFileIndex = counterFileIndex + 1;
                parametersMriCurrentSession.(matlab.lang.makeValidName(strFieldname))(cr) = str2double(aStrAnswers{counterFileIndex});
                parametersMriCurrentSession.allFileIndices(counterFileIndex) = str2double(aStrAnswers{counterFileIndex});
            end
        end
    end
end


end


function parametersMriCurrentSession = determineNumberOfMeasurementsInRunATWM1(parametersMriCurrentSession, aStrFileIndexFieldnames)

global iStudy

parametersFunctionalMriSequence_WM          = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
parametersFunctionalMriSequence_LOC         = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
parametersFunctionalMriSequence_COPE        = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);
parametersStructuralMriSequenceHighRes      = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersStructuralMriSequenceLowRes       = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
parametersStructuralMriSequenceLocalizer    = eval(['parametersStructuralMriSequenceLocalizer', iStudy]);

%% Add nMeasurementsInRun
parametersMriCurrentSession.nMeasurementsInRun(1:parametersMriCurrentSession.nRuns) = 0;

% fileIndexFmr_WM
fileIndexFmr_WM = parametersMriCurrentSession.fileIndexFmr_WM;
parametersMriCurrentSession.nMeasurementsInRun(fileIndexFmr_WM) = parametersFunctionalMriSequence_WM.nVolumes;

% fileIndexFmr_LOC
fileIndexFmr_LOC = parametersMriCurrentSession.fileIndexFmr_LOC;
parametersMriCurrentSession.nMeasurementsInRun(fileIndexFmr_LOC) = parametersFunctionalMriSequence_LOC.nVolumes;

% fileIndexFmr_COPE
fileIndexFmr_COPE = parametersMriCurrentSession.fileIndexFmr_COPE;
parametersMriCurrentSession.nMeasurementsInRun(fileIndexFmr_COPE) = parametersFunctionalMriSequence_COPE.nVolumes;

% fileIndexVmrHighRes
fileIndexVmrHighRes = parametersMriCurrentSession.fileIndexVmrHighRes;
parametersMriCurrentSession.nMeasurementsInRun(fileIndexVmrHighRes) = parametersStructuralMriSequenceHighRes.nSlices;

% fileIndexVmrLowRes
fileIndexVmrLowRes = parametersMriCurrentSession.fileIndexVmrLowRes;
parametersMriCurrentSession.nMeasurementsInRun(fileIndexVmrLowRes) = parametersStructuralMriSequenceLowRes.nSlices;

% fileIndexAnatomicalLocalizer
fileIndexAnatomicalLocalizer = parametersMriCurrentSession.fileIndexAnatomicalLocalizer;
parametersMriCurrentSession.nMeasurementsInRun(fileIndexAnatomicalLocalizer) = parametersStructuralMriSequenceLocalizer.nSlices;

% fileIndexInvalidRuns
parametersMriCurrentSession = enterNumberOfMeasurementsInInvalidRunsATWM1(parametersMriCurrentSession);


end


function parametersMriCurrentSession = enterNumberOfMeasurementsInInvalidRunsATWM1(parametersMriCurrentSession)
%%
if parametersMriCurrentSession.nInvalidRuns > 0
    fileIndexInvalidRuns = parametersMriCurrentSession.fileIndexInvalidRuns;
    aStrPrompt = {};
    aStrDefaultAnswer = {};
    for cfi = 1:parametersMriCurrentSession.nInvalidRuns
        strPrompt = sprintf('Please enter # slices / measurements for invalid run %i with file index %i', cfi, fileIndexInvalidRuns(cfi));
        aStrPrompt = [aStrPrompt, strPrompt];
        strAnswer = sprintf('NaN');
        strAnswer = sprintf('3');
        aStrDefaultAnswer = [aStrDefaultAnswer, strAnswer];
    end
    strTitle = 'Invalid runs';
    nrOfLines = 1;
    aStrAnswer = inputdlg(aStrPrompt, strTitle, nrOfLines, aStrDefaultAnswer);
    for cfi = 1:parametersMriCurrentSession.nInvalidRuns
        parametersMriCurrentSession.nMeasurementsInRun(fileIndexInvalidRuns(cfi)) = str2double(aStrAnswer{cfi});
    end
end

end


function [strPathParametersMriSessionFile] = determinePathParametersMriScanFileATWM1(folderDefinition, parametersNetwork, strParametersMriSessionFile)

%% Determine path for parametersMriScan file
if ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strDepartmentOfPsychiatry), 1))
    folderParametersMriScan = folderDefinition.parametersMriScan;
elseif ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strBrainImagingCenter), 1)) && ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strPresentationComputer), 1))
    folderParametersMriScan = folderDefinition.parametersMriScanServerMriScanner;
end
strPathParametersMriSessionFile = fullfile(folderParametersMriScan, strParametersMriSessionFile);


end


function writeParametersMriSessionFileATWM1(parametersMriCurrentSession, strParametersMriSessionFile, strPathParametersMriSessionFile)

strParametersMriSession = strrep(strParametersMriSessionFile, '.m', '');

fid = fopen(strPathParametersMriSessionFile, 'wt');

%% Write header
fprintf(fid, 'function parametersMriSession = %s();', strParametersMriSession);
fprintf(fid, '\n\n');

%% Write fileIndexFmr_WM
fprintf(fid, 'parametersMriSession.fileIndexFmr_WM = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexFmr_WM)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexFmr_WM(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n\n');

%% Write fileIndexFmr_LOC
fprintf(fid, 'parametersMriSession.fileIndexFmr_LOC = [');
fprintf(fid, '\n');
fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexFmr_LOC);
fprintf(fid, '\n');
fprintf(fid, '\t];');
fprintf(fid, '\n\n');

%% Write fileIndexFmr_COPE
fprintf(fid, 'parametersMriSession.fileIndexFmr_COPE = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexFmr_COPE)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexFmr_COPE(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n\n');

%% Write VMR parameters
fprintf(fid, 'parametersMriSession.fileIndexVmrHighRes = %i;', parametersMriCurrentSession.fileIndexVmrHighRes);
fprintf(fid, '\n');
fprintf(fid, 'parametersMriSession.fileIndexVmrLowRes = %i;', parametersMriCurrentSession.fileIndexVmrLowRes);
fprintf(fid, '\n\n');

%% Write localizer parameters
fprintf(fid, 'parametersMriSession.fileIndexAnatomicalLocalizer = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexAnatomicalLocalizer)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexAnatomicalLocalizer(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n\n');

%% Write number of measurements in run
fprintf(fid, 'parametersMriSession.nMeasurementsInRun = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.nMeasurementsInRun)
    fprintf(fid, '\t%i', parametersMriCurrentSession.nMeasurementsInRun(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n\n');

%% Write file index of invalid runs
fprintf(fid, 'parametersMriSession.fileIndexInvalidRuns = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexInvalidRuns)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexInvalidRuns(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n\n');

%% Write verification boolean
fprintf(fid, 'parametersMriSession.bVerified = %i;', parametersMriCurrentSession.bVerified);
fprintf(fid, '\n\n');

%% Write end and close file
fprintf(fid, '\n');
fprintf(fid, 'end');

fclose(fid);

fprintf('File %s successfully created!\n', strPathParametersMriSessionFile);


end


function copyParametersMriSessionFileToServerATWM1(folderDefinition, parametersNetwork, strPathParametersMriSessionFile)
%% Copy ParametersMriSessionFile to server
if ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strDepartmentOfPsychiatry), 1))
    strPathServerParametersMriSessionFile = strrep(strPathParametersMriSessionFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
    if exist(strPathParametersMriSessionFile, 'file')
        success = copyfile(strPathParametersMriSessionFile, strPathServerParametersMriSessionFile);
        if success
            fprintf('File %s successfully copied to server!\n\n', strPathParametersMriSessionFile);
        else
            fprintf('Error while copying file %s to server!\nFile was not copied.\n', strPathParametersMriSessionFile);
        end
    end
end


end
