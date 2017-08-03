function genericWrapperForAutoItATWM1()

%clear all
%clc

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions

iStudy = 'ATWM1';

folderDefinition                        = eval(['folderDefinition', iStudy]);
parametersProjectFiles                  = eval(['parametersProjectFiles', iStudy]);
parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersBrainSegmentation             = eval(['parametersBrainSegmentation', iStudy]);

%%% REINSTATE
%{
%%% Select subjects
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'multiple';
[strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end
%}
%%% REINSTATE

%%% REMOVE
strGroup = 'CONT';
strSubject = 'AE23XMP';
nSubjects = 1;
%%% REMOVE

parametersProjectFiles.strHighResAnatomy = sprintf('%s_%s', parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution);

%%% MOVE TO SEPARATE PARAMETER FILE
%%% Might have to be changed to .exe file
parametersAutoIt.strAutoItScriptFile        = 'AutoItScriptFileName.au3';


parametersAutoIt.strTextFileForAutoItScript = 'Parameters_for_execution_of_Auto_It_Script.txt';
%%% MOVE TO SEPARATE PARAMETER FILE

%%% This might have to be changed
%parametersAutoIt.strFolderForAutoItScript = folderDefinition.autoITscripts;
parametersAutoIt.strPathAutoItScriptFile = fullfile(folderDefinition.autoITscripts, parametersAutoIt.strAutoItScriptFile);
%%% This might have to be changed

%%% The different AutoIT script files are stored in a centralised folder
%%% defined by the variable: folderDefinition.autoITscripts

%%% Check, whether the required AutoIT script file exists
if exist(parametersAutoIt.strPathAutoItScriptFile, 'file')
    bAutoITscriptFileExists = true;
else
    bAutoITscriptFileExists = false;
    fprintf('\nAutoIT script file %s could not be found!\nAborting function!\n\n', parametersAutoIt.strAutoItScriptFile);
end

if ~bAutoITscriptFileExists
    return
end

strCurrentFolder = pwd;



%%% Define name of BV-files required for the AutoIT script
vmr = defineStandardVmrFileNamesATWM1;
folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);


strFolderHighResAnatomy = structProjectDataSubFolders.(matlab.lang.makeValidName(sprintf('strFolder_%s', parametersProjectFiles.strHighResAnatomy)));
strPathVmrFile = fullfile(strFolderHighResAnatomy, vmr.strVmrFile);








parametersAutoIt.strPathTextFileForAutoItScript = fullfile(parametersAutoIt.strFolderForAutoItScript, parametersAutoIt.strTextFileForAutoItScript);

%%{
%%% Create array containing all the 
aStrPathBvFilesForAutoItScript = {
    strPathVmrFile
    };

%%% Check, whether all file required for AutoIT script exist
bBvFilesForAutoItScriptComplete = true;
for cf = 1:numel(aStrPathBvFilesForAutoItScript)
    if ~exist(aStrPathBvFilesForAutoItScript{cf}, 'file')
        bBvFilesForAutoItScriptComplete = false;
        fprintf('Error!\nFile %s not found!\n', aStrPathBvFilesForAutoItScript{cf});
    end
end


if bBvFilesForAutoItScriptComplete
    %function createTextFileForAutoItScriptATWM1
    bAutoITscriptPrepSuccessful = true;
    %%% Delete preexisting text file for AutoIt script
    try
        if exist(parametersAutoIt.strPathTextFileForAutoItScript, 'file')
            delete(parametersAutoIt.strPathTextFileForAutoItScript)
        end
    catch
        fprintf('Error! Could not delete file %s\n', parametersAutoIt.strPathTextFileForAutoItScript);
        bAutoITscriptPrepSuccessful = false;
    end
    
    %%% Create text file for AutoIt script
    try
        %%% Move to separate function (see Danylo's script)
        fileID = fopen(parametersAutoIt.strPathTextFileForAutoItScript, 'wt');
        fprintf(fileID, 'WRITE IN PARAMETERS!\n');
        for cf = numel(aStrPathBvFilesForAutoItScript)
            fprintf(fileID, '%s\n', aStrPathBvFilesForAutoItScript{cf});
        end
        fclose(fileID);
    catch
        % Error message will be created in the separate script
        bAutoITscriptPrepSuccessful = false;
    end
    
    %%% Copy AutoIt script to local folder??
    %%% Check, whether that is necessary
    
    if bAutoITscriptPrepSuccessful
        
        %%% Execute AutoIt script
        try
            bAutoITscriptExecutionSuccessful = true;
            cd(parametersAutoIt.strFolderForAutoItScript)
            strCommand = sprintf('%s', parametersAutoIt.strPathAutoItScriptFile);
            system(strCommand);
        catch
            bAutoITscriptExecutionSuccessful = false;
            fprintf('Could not execute AutoIt script %s!\n', parametersAutoIt.strPathAutoItScriptFile);
            %cd(strCurrentFolder);
        end
        
        %%% Check if necessary
        %%% Delete local copy of AutoIt script
        try
            %%% Delete local copy of AutoIt script
            %%%delete(parametersAutoIt.strPathTextFileForAutoItScript)
        catch
            
        end
        
        %%% Delete text file containing parameters for AutoIt script
        try
            delete(parametersAutoIt.strPathTextFileForAutoItScript)
        catch
            fprintf('Could not delete AutoIt script parameter file %s!\n', parametersAutoIt.strPathTextFileForAutoItScript);
        end
        cd(strCurrentFolder);
    else
        fprintf('Error during preparation of AutoIT script!\n')
    end
else
    fprintf('\nAutoIT script %s cannot be executed!\nSkipping subject %s.\n\n', parametersAutoIt.strAutoItScriptFile, strSubject);
    continue
end
%}
%end

end

