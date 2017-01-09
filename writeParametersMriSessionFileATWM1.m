function writeParametersMriSessionFileATWM1()
clear all
clc


%return

global iStudy
iStudy = 'ATWM1';

folderDefinition                = eval(['folderDefinition', iStudy]);
parametersMriSessionStandard 	= eval(['parametersMriSessionStandard', iStudy]);


iSession = 1;
strSubject = 'TEST'


%parametersMriCurrentSession = parametersMriSessionStandard
%%{
% Manual editing of MriSessionParameters
[parametersMriCurrentSession, bAbort] = enterParametersCurrentMriSessionATWM1(parametersMriSessionStandard);
if bAbort == true
    return
end
%}
strParametersMriSessionFile = defineParametersMriSessionFileNameATWM1(strSubject, iSession);
strPathParametersMriSessionFile = fullfile(folderDefinition.parametersMriScan, strParametersMriSessionFile);


fid = fopen(strPathParametersMriSessionFile, 'wt');

%% Write header
fprintf(fid, 'function parametersMriSession = %s_parametersMriSession_%i_%s();', strSubject, iSession, iStudy);
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write fileIndexFmr_WM
fprintf(fid, 'parametersMriSession.fileIndexFmr_WM = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexFmr_WM)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexFmr_WM(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write fileIndexFmr_LOC
fprintf(fid, 'parametersMriSession.fileIndexFmr_LOC = [');
fprintf(fid, '\n');
fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexFmr_LOC);
fprintf(fid, '\n');
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write fileIndexFmr_COPE
fprintf(fid, 'parametersMriSession.fileIndexFmr_COPE = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexFmr_COPE)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexFmr_COPE(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write VMR parameters
fprintf(fid, 'parametersMriSession.fileIndexVmrHighRes = %i;', parametersMriCurrentSession.fileIndexVmrHighRes);
fprintf(fid, '\n');
fprintf(fid, 'parametersMriSession.fileIndexVmrLowRes = %i;', parametersMriCurrentSession.fileIndexVmrLowRes);
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write localizer parameters
fprintf(fid, 'parametersMriSession.fileIndexAnatomicalLocalizer = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexAnatomicalLocalizer)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexAnatomicalLocalizer(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write number of measurements in run
fprintf(fid, 'parametersMriSession.nMeasurementsInRun = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.nMeasurementsInRun)
    fprintf(fid, '\t%i', parametersMriCurrentSession.nMeasurementsInRun(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write file index of invalid runs
fprintf(fid, 'parametersMriSession.fileIndexInvalidRuns = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriCurrentSession.fileIndexInvalidRuns)
    fprintf(fid, '\t%i', parametersMriCurrentSession.fileIndexInvalidRuns(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write verification boolean
fprintf(fid, 'parametersMriSession.bVerified = %i;', parametersMriCurrentSession.bVerified);
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write end and close file
fprintf(fid, '\n');
fprintf(fid, 'end');

fclose(fid);

end


function [parametersMriCurrentSession, bAbort] = enterParametersCurrentMriSessionATWM1(parametersMriSessionStandard)

global iStudy
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
    %{
    if isempty(aStrAnswers)
        [parametersMriSessionStandard, parametersMriCurrentSession, bAbort] = enterNumberOfInvalidRunsATWM1(parametersMriSessionStandard, parametersMriCurrentSession, bAbort);
        if bAbort == true
            return
        end
        [parametersMriCurrentSession, bAbort] = enterFileIndicesATWM1(parametersMriSessionStandard, parametersMriCurrentSession, aStrFileIndexFieldnames, bAbort);
        if bAbort == true
            return
        end
    end
    %}
    %parametersMriCurrentSession = parametersMriCurrentSession
    %%{
    %%% REMOVE
    parametersMriCurrentSession = parametersMriSessionStandard
    %parametersMriCurrentSession.fileIndexFmr_WM(1) = NaN;
    parametersMriCurrentSession.allFileIndices = [1:14, parametersMriCurrentSession.fileIndexInvalidRuns]
    %%% REMOVE
    %}
    
    %{
    %%% REMOVE
    parametersMriCurrentSession = parametersMriSessionStandard
    parametersMriCurrentSession.allFileIndices = [1:14, parametersMriCurrentSession.fileIndexInvalidRuns]
    %%% REMOVE
    %}
    
    %{
    [parametersMriCurrentSession, bParametersCorrect, bAbort] = searchForDuplicateOfMissingFileIndicesATWM1(parametersMriCurrentSession, bParametersCorrect);
    if bAbort == true
        return
    end
    %}
    %% Show file indices for final evaluation
    counterFileIndex = 0;
    for cfi = 1:numel(aStrFileIndexFieldnames)
        strFieldname = aStrFileIndexFieldnames{cfi};
        for cr = 1:numel(parametersMriCurrentSession.(genvarname(strFieldname)))
            counterFileIndex = counterFileIndex + 1;
            if cr == 1 && cfi > 1
                strOffset = sprintf('\n\n');
                strOffset = sprintf('');
            else
                strOffset = sprintf('');
            end
            strSummaryPrompt{counterFileIndex} = sprintf('%sFile index for %s:', strOffset, parametersMriSessionStandard.strDescription.(genvarname(strFieldname)){cr});
            aStrFileIndex{counterFileIndex} = num2str(parametersMriCurrentSession.(genvarname(strFieldname))(cr));
        end
    end
    strTitle = 'Evaluate ParametersMriSession';
    nrOfLines = 1;
    aStrAnswers = (inputdlg(strSummaryPrompt, strTitle, nrOfLines, aStrFileIndex))';
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
                for cr = 1:numel(parametersMriCurrentSession.(genvarname(strFieldname)))
                    counterFileIndex = counterFileIndex + 1;
                    parametersMriCurrentSession.(genvarname(strFieldname))(cr) = str2num(aStrAnswers{counterFileIndex});
                    parametersMriCurrentSession.allFileIndices(counterFileIndex) = str2num(aStrAnswers{counterFileIndex});
                end
            end
        end
    end
    %% Evaluate parameters
    [parametersMriCurrentSession, bParametersCorrect, bAbort] = searchForDuplicateOfMissingFileIndicesATWM1(parametersMriCurrentSession, bParametersCorrect);
    if bAbort == true
        return
    end
end


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
%{
%%% REMOVE
parametersMriCurrentSession.nInvalidRuns = 3
parametersMriCurrentSession.fileIndexInvalidRuns = [15:17]
%%% REMOVE
%}
%%{
%%% REMOVE
parametersMriCurrentSession.nInvalidRuns = 0
%%% REMOVE
%}

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
        parametersMriCurrentSession.nMeasurementsInRun(fileIndexInvalidRuns(cfi)) = str2num(aStrAnswer{cfi});
    end
end
parametersMriCurrentSession.bVerified = true;


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
        parametersMriCurrentSession.nInvalidRuns = str2num(aStrAnswer{1});
        for cr = 1:parametersMriCurrentSession.nInvalidRuns
            parametersMriSessionStandard.fileIndexInvalidRuns(cr)   = NaN;
            parametersMriCurrentSession.fileIndexInvalidRuns(cr)    = NaN;
            parametersMriSessionStandard.strDescription.fileIndexInvalidRuns{cr} = sprintf('%s_run_%i', strDescriptionFileIndexInvalidRuns, cr);
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
    % Special case: file indices for invalid runs
    strInvalidRuns = 'InvalidRuns';
    if ~isempty(strfind(strFieldname, strInvalidRuns)) && parametersMriCurrentSession.nInvalidRuns == 0
        continue
    end
    
    bParametersEntered = false;
    while ~bParametersEntered
        aStrPrompt = {};
        aStrDefaultAnswer = {};
        for cr = 1:numel(parametersMriSessionStandard.(genvarname(strFieldname)))
            strPrompt = sprintf('Please enter filex index for %s', parametersMriSessionStandard.strDescription.(genvarname(strFieldname)){cr});
            aStrPrompt = [aStrPrompt, strPrompt];
            strAnswer = sprintf('%i', parametersMriSessionStandard.(genvarname(strFieldname))(cr));
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


function bAbort = openInvalidParametersDialogATWM1()

global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strSubjectAndGroup = sprintf('No valid parameters were entered!');
strTitle = '';
strOption1 = sprintf('%sRe-Enter values%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strSubjectAndGroup, strTitle, strOption1, strOption2, strOption1);
if ~isempty(choice)
    switch choice
        case strOption1
            bAbort = false;
        case strOption2
            bAbort = true;
            strMessage = sprintf('No parameters entered.\nAborting function.');
            disp(strMessage);
    end
else
    bAbort = true;
    strMessage = sprintf('No parameters entered.\nAborting function.');
    disp(strMessage);
end


end


function parametersMriCurrentSession = addAnswersToParametersMriSessionATWM1(parametersMriCurrentSession, strFieldname, aStrAnswer)
%%
for ca = 1:numel(aStrAnswer)
    if isempty(aStrAnswer{ca}) || isempty(str2num(aStrAnswer{ca}))
        aStrAnswer{ca} = '0';
    end
end
vAnswer = [];
for ca = 1:numel(aStrAnswer)
    vAnswer(ca) = str2num(aStrAnswer{ca});
end
vAnswer(vAnswer == 0) = NaN;
parametersMriCurrentSession.(genvarname(strFieldname)) = vAnswer;

parametersMriCurrentSession.allFileIndices = [parametersMriCurrentSession.allFileIndices, vAnswer];


end


function [parametersMriCurrentSession, bParametersCorrect, bAbort] = searchForDuplicateOfMissingFileIndicesATWM1(parametersMriCurrentSession, bParametersCorrect)
%%
% Replace NaN values for comparison
parametersMriCurrentSession.allFileIndices(isnan(parametersMriCurrentSession.allFileIndices)) = 0;

parametersMriCurrentSession.allFileIndices = sort(parametersMriCurrentSession.allFileIndices);
parametersMriCurrentSession.nRuns = numel(parametersMriCurrentSession.allFileIndices);

vCaculatedFileIndices = 1:parametersMriCurrentSession.nRuns;

if ~isequal(vCaculatedFileIndices, parametersMriCurrentSession.allFileIndices)
    strMessageFileIndices = sprintf('Number of file indices: %i\n', parametersMriCurrentSession.nRuns);
    
    % Detect missing indices
    vMissingFileIndices = find(~ismember(vCaculatedFileIndices, parametersMriCurrentSession.allFileIndices));
    if ~isempty(vMissingFileIndices)
        strMessageFileIndices = sprintf('%sMissing entries for file index %i\n', strMessageFileIndices, vMissingFileIndices);
    end
    
    % Detect duplicate indices
    u = unique(parametersMriCurrentSession.allFileIndices);
    n = histc(parametersMriCurrentSession.allFileIndices, u);
    vDuplicateFileIndices = u(n > 1);
    nDuplicateFileIndices = n(n > 1);
    if ~isempty(vDuplicateFileIndices)
        for cd = 1:numel(vDuplicateFileIndices)
            strMessageFileIndices = sprintf('%s%i duplicate entries for file index %i', strMessageFileIndices, nDuplicateFileIndices(cd), vDuplicateFileIndices(cd));
            %{
            for cdfi = 1:nDuplicateFileIndices(cd)
                % aStrFileIndex
                strMessageFileIndices = sprintf('%s\n%s', strMessageFileIndices, aStrFileIndex);
            end
            %}
        end
    end
    bAbort = openIncorrectFileIndicesDialogATWM1(strMessageFileIndices);
    if bAbort
        return
    end
else
    bAbort = false;
    bParametersCorrect = true;
end


end


function bAbort = openIncorrectFileIndicesDialogATWM1(strMessageFileIndices)
%%
global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strTitle = 'File index error';
strOption1 = sprintf('%sRe-Enter file indices%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strMessageFileIndices, strTitle, strOption1, strOption2, strOption1);
if ~isempty(choice)
    switch choice
        case strOption1
            bAbort = false;
        case strOption2
            bAbort = true;
            strMessage = sprintf('Incorrect file indices entered.\nAborting function.');
            disp(strMessage);
    end
else
    bAbort = true;
    strMessage = sprintf('Incorrect file indices entered.\nAborting function.');
    disp(strMessage);
end


end