function createPresentationFilesForMegAndMriATWM1()

clear all
clc

strStudy = 'ATWM1';

%% Define folder and add temporary paths
strRootFolderBeoserv = sprintf('/data/projects/%s/', strStudy);
strRootFolderServer = strRootFolderBeoserv;
strRootFolder = sprintf('%sPresentation/', strRootFolderServer); 

strScriptFolderWM               = sprintf('%sMATLAB_CreatePresentationFiles_WorkingMemory/', strRootFolder);
strGlobalStudyParametersFolder  = sprintf('%sStudy_Parameters/', strRootFolderServer);
strLocalStudyParametersFolder	= sprintf('%sStudy_Parameters/', strRootFolder);
strScriptFolderLocalizer        = sprintf('%sPresentation/MATLAB_CreatePresentationFiles_Localizer/', strRootFolderServer);

addpath(strScriptFolderWM);
addpath(strLocalStudyParametersFolder);
addpath(strScriptFolderLocalizer);

bAbort = copyStudyParameterFilesToLocalStudyParametersFolderATWM1(strStudy, strGlobalStudyParametersFolder, strLocalStudyParametersFolder);
if bAbort == true
    return
end

%% Load parameters
aSubject            = aSubjectATWM1_IMAGING;
parametersGroups    = parametersGroupsATWM1;
parametersParadigm  = parametersParadigm_WM_IMAGING_ATWM1;
parametersStudy     = parametersStudyATWM1;

%% Select/prepare parameters and folder 
[strGroup, strSubjectID, strPermutationType, strLeftRight] = selectParametersForPresentationScenarioFileCreationATWM1(parametersGroups, aSubject, parametersParadigm);
[strGroupPresentationFilesFolder, strSubjectPresentationFilesFolder, bAbort] = prepareSubjectFolderForPresentationScenarioFilesATMW1(strRootFolder, strGroup, strSubjectID);

if bAbort == true
    return
end
%% Create presentation files for MEG and MRI version of the working memory experiment
aStrSubjectPresentationFileSubFolder = {};
for ced = 1:numel(parametersStudy.aStrExpDevice)
    strExpDevice = parametersStudy.aStrExpDevice{ced};
    aStrFilePath = CreatePresentationFiles(strExpDevice, strSubjectID, strPermutationType, strLeftRight, strGroup, strRootFolder, strScriptFolderWM);
    for cp = 1:numel(aStrFilePath)
        iSubFolder = numel(aStrSubjectPresentationFileSubFolder) + 1;
        aStrSubjectPresentationFileSubFolder{iSubFolder} = aStrFilePath{cp};
    end
end

%% Create presentation files for localizer
strSubjectFolder = CreateSceFilesLocalizer(strSubjectID, strGroup, strRootFolder);
iSubFolder = numel(aStrSubjectPresentationFileSubFolder) + 1;
aStrSubjectPresentationFileSubFolder{iSubFolder} = strSubjectFolder;

%% Move and zip presentation files
movePresentationScenarioFilesToSubjectFolderATWM1(aStrSubjectPresentationFileSubFolder, strSubjectPresentationFilesFolder);
zipSubjectPresentationScenarioFileFolderATWM1(strSubjectID, strStudy, strGroupPresentationFilesFolder, strSubjectPresentationFilesFolder);

%% Push new files to study github account
pushSubjectPresentationScenarioFilesToGithubATWM1;

end


function bAbort = copyStudyParameterFilesToLocalStudyParametersFolderATWM1(strStudy, strGlobalStudyParametersFolder, strLocalStudyParametersFolder);
    % Copy parameter files from global study parameters folder to local study parameters folder
    aStrStudyParametersFiles = {
        sprintf('aSubject%s_IMAGING.m', strStudy)
        sprintf('parametersGroups%s.m', strStudy)
        sprintf('parametersParadigm_WM_IMAGING_%s.m', strStudy)
        sprintf('parametersStudy%s.m', strStudy)
        };

    for cf = 1:numel(aStrStudyParametersFiles)
        strParameterFile = aStrStudyParametersFiles{cf};
        pathFileGlobalStudyParametersFolder = fullfile(strGlobalStudyParametersFolder, strParameterFile);
        pathFileLocalStudyParametersFolder  = fullfile(strLocalStudyParametersFolder, strParameterFile);
        if exist(pathFileGlobalStudyParametersFolder, 'file')
            %status(cf) = copyfile(pathFileGlobalStudyParametersFolder, pathFileLocalStudyParametersFolder, 'f');
            %if status == true
            %    strMessage = sprintf('Study parameter file %s copied successfully!\n', pathFileGlobalStudyParametersFolder);
            %    disp(strMessage);
            %end
            try
                copyfile(pathFileGlobalStudyParametersFolder, pathFileLocalStudyParametersFolder, 'f');
            catch ME
                if (isempty (strfind (ME.message, 'Operation not permitted')))
                    bAbort = true;
                    rethrow (ME) ;
                end
            end
        end
    end

    %{
    if sum(status) ~= numel(aStrStudyParametersFiles)
        nrOfFilesNotCopied = numel(aStrStudyParametersFiles) - sum(status);
        strMessage = sprintf('Error! %i study parameter file(s) could not be copied!', nrOfFilesNotCopied);
        disp(strMessage);
        bAbort = true;
    else
        bAbort = false;
    end
    %}
    
    bAbort = false;
end


function [strGroup, strSubjectID, strPermutationType, strLeftRight] = selectParametersForPresentationScenarioFileCreationATWM1(parametersGroups, aSubject, parametersParadigm);

strDialogSelectionMode = 'single';

%% Select group
strPrompt = 'Please select the group';
strTitle = 'Group selection';
vListSize = [300, 100];

[iGroup] = listdlg('ListString', parametersGroups.aStrShortGroups, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(iGroup)
    strMessage = sprintf('\n\nNo group selected!\n');
    error(strMessage);
end
strGroup = parametersGroups.aStrShortGroups{iGroup};

%% Add dummy subject name for testing purposes
strDummySubject = sprintf('__SUBJECT_TEST_%s', strGroup);
aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup)) = [aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup))
                                                        strDummySubject];
if isempty(aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup)))
    strMessage = sprintf('\n\nNo subject entries found for group %s!\n', upper(parametersGroups.aStrLongGroups{iGroup}));
    error(strMessage);
end

%% Select subject
strPrompt = 'Please select the subject code';
strTitle = 'Subject code';
vListSize = [300, 600];
aStrSubjectsGroup = aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup));
[iSubject] = listdlg('ListString', aStrSubjectsGroup, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(iSubject)
    strMessage = sprintf('\n\nNo subject selected!\n');
    error(strMessage);
end
strSubjectID = aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup)){iSubject};

%% Select permutation
strPrompt = 'Please select the permutation order';
strTitle = 'Permutation order';
vListSize = [300, 150];
%parametersPermutation = parametersPermutationATWM1;
for cp = 1:parametersParadigm.nrOfPermutations
    parametersParadigm.aStrPermutations{cp}  = sprintf('P%i', cp);
end
[iPermutation] = listdlg('ListString', parametersParadigm.aStrPermutations, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(iPermutation)
    strMessage = sprintf('\n\nNo permutation selected!\n');
    error(strMessage);
end
strPermutationType = parametersParadigm.aStrPermutations{iPermutation};

%% Select response button configuration (left/right or right/left)
strPrompt = 'Please select the response button configuration for the subject';
strTitle = 'Response button configuration';
vListSize = [300, 100];
[iResponseButtonConfiguration ] = listdlg('ListString', parametersParadigm.aStrResponseButtonConfiguration, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(iResponseButtonConfiguration)
    strMessage = sprintf('\n\nNo response button configuration selected!\n');
    error(strMessage);
end
strLeftRight = parametersParadigm.aStrResponseButtonConfiguration{iResponseButtonConfiguration};


end


function [strGroupPresentationFilesFolder, strSubjectPresentationFilesFolder, bAbort] = prepareSubjectFolderForPresentationScenarioFilesATMW1(strRootFolder, strGroup, strSubjectID);
bAbort = false; 
%%% Check, whether Presentation scenario files have already been created
strPresentationFilesFolder = strcat(strRootFolder, 'PresentationFiles_Subjects', '/');
strGroupPresentationFilesFolder = strcat(strPresentationFilesFolder,  strGroup, '/');
strSubjectPresentationFilesFolder = strcat(strGroupPresentationFilesFolder, strSubjectID, '/');
if exist(strSubjectPresentationFilesFolder, 'dir')
    strTitle    =  'Overwrite existing files?';
    strQuestion = sprintf('One or more files already exist for subject %s', strSubjectID);
    strChoice1  = 'Overwrite'; 
    strChoice2  = 'Cancel'; 
    choice = questdlg(strQuestion, strTitle, strChoice1, strChoice2, strChoice1);
    switch choice
        case strChoice1
            try
                rmdir(strSubjectPresentationFilesFolder, 's');
            catch
                strMessage = sprintf('Could not delete folder %s\n', strSubjectPresentationFilesFolder);
                error(strMessage);
            end
            strMessage = sprintf('Overwriting Presentation scencario files for subject %s.\n', strSubjectID);
            disp(strMessage);

        case strChoice2
            strMessage = sprintf('Presentation scencario files for subject %s not overwritten!\nAborting function!\n', strSubjectID);
            disp(strMessage);
            bAbort = true; 
            return
    end
end
%%% Create subject folder for Presentation scenario files
mkdir(strSubjectPresentationFilesFolder);

end


function movePresentationScenarioFilesToSubjectFolderATWM1(aStrSubjectPresentationFileSubFolder, strSubjectPresentationFilesFolder);
% Move all subfolder to subject presentation file folder
for cp = 1:numel(aStrSubjectPresentationFileSubFolder)
    strFilePath = aStrSubjectPresentationFileSubFolder{cp};
    
    iDirSep = strfind(strFilePath, '/');
    iStart = iDirSep(end-1) + 1;
    iEnd = iDirSep(end) - 1;
    strSubFolder = strFilePath(iStart:iEnd);
    
    strNewFolder = strcat(strSubjectPresentationFilesFolder, strSubFolder, '/');
    movefile(strFilePath, strNewFolder)
end

end


function zipSubjectPresentationScenarioFileFolderATWM1(strSubjectID, strStudy, strGroupPresentationFilesFolder, strSubjectPresentationFilesFolder);
% Zip subject presentation file folder
strZipFile = sprintf('%s_%s_Presentation_Scenario_Files.zip', strSubjectID, strStudy);
pathZipFile = fullfile(strGroupPresentationFilesFolder, strZipFile);
zip(pathZipFile, strSubjectPresentationFilesFolder);

end
