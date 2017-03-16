function [folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = selectGeneralParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles)

global iStudy
global strGroup
global iSession
global bTestConfiguration

if ~bTestConfiguration
    aStrSubject = {};
    nSubjects = numel(aStrSubject);
    vSessionIndex = [];
    parametersProjectFiles.bForceDeletionOfAllExistingFiles = false;

    %%% Load additional folder definitions
    hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
    folderDefinition = feval(hFunction, folderDefinition);
    
    %%% Check server access
    bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
    if bAllFoldersCanBeAccessed == false
        bAbort = true;
        return
    end
    
    %%% Select subjects
    aSubject = processSubjectArrayATWM1_IMAGING;
    strDialogSelectionModeSubject = 'multiple';
    iSession = 1;
    [strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
    if bAbort == true
        return
    end
    
    %%% Determine session for each subject
    if parametersProjectFiles.bProjectFileCreation || parametersProjectFiles.bTransferDicomFilesFirst
        [vSessionIndex, bAbort] = determineMriSessionATWM1(aStrSubject, nSubjects);
        if bAbort == true
            return
        end
    else
        vSessionIndex = [];
        bAbort = false;
    end
else
    [folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = setTestConfigurationParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles);
end

end