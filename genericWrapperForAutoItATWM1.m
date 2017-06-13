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
aStrSubject = {'AE23XMP'};
nSubjects = 1;
%%% REMOVE

parametersProjectFiles.strHighResAnatomy = sprintf('%s_%s', parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution);

%%% MOVE TO SEPARATE PARAMETER FILE
parametersAutoIt.strAutoItScriptFileName    = 'AutoItScriptFileName.txt';
parametersAutoIt.strTextFileForAutoItScript = 'Parameters_for_execution_of_Auto_It_Script.txt';
%%% MOVE TO SEPARATE PARAMETER FILE

strCurrentFolder = pwd;

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    vmr = defineStandardVmrFileNamesATWM1;
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);

    
    strFolderHighResAnatomy = structProjectDataSubFolders.(matlab.lang.makeValidName(sprintf('strFolder_%s', parametersProjectFiles.strHighResAnatomy)));
    strPathVmrFile = fullfile(strFolderHighResAnatomy, vmr.strVmrFile);
  
    
    parametersAutoIt.strFolderForAutoItScript = strFolderHighResAnatomy;
    
    %%% This might have to be changed
    parametersAutoIt.strPathAutoItScriptFile = fullfile(parametersAutoIt.strFolderForAutoItScript, parametersAutoIt.strAutoItScriptFileName);
    %%% This might have to be changed
    
    parametersAutoIt.strPathTextFileForAutoItScript = fullfile(parametersAutoIt.strFolderForAutoItScript, parametersAutoIt.strTextFileForAutoItScript);
    
    %%{
    if exist(strPathVmrFile, 'file')
        %function createTextFileForAutoItScriptATWM1
        
        %%% Delete preexisting text file for AutoIt script
        if exist(parametersAutoIt.strPathTextFileForAutoItScript, 'file')
            delete(parametersAutoIt.strPathTextFileForAutoItScript)
        end
        
        %%% Create text file for AutoIt script
        fileID = fopen(parametersAutoIt.strPathTextFileForAutoItScript, 'wt');
        fprintf(fileID, 'WRITE IN PARAMETERS!\n');
        % strPathVmrFile
        fprintf(fileID, '%s\n', strPathVmrFile);
        fclose(fileID);
        
        %%% Copy AutoIt script to local folder??        
        
        %%% Execute AutoIt script
        try
            cd(parametersAutoIt.strFolderForAutoItScript)
            strCommand = sprintf('%s', parametersAutoIt.strPathAutoItScriptFile);
            system(strCommand);
        catch
            fprintf('Could not execute AutoIt script %s\n', parametersAutoIt.strPathAutoItScriptFile);
            %cd(strCurrentFolder);
        end
        
        
        try
            %%% Delete local copy of AutoIt script
            %%%delete(parametersAutoIt.strPathTextFileForAutoItScript)
        catch
            
        end
        try
            %%% Delete text file for AutoIt script
            delete(parametersAutoIt.strPathTextFileForAutoItScript)
        catch
            
        end
        cd(strCurrentFolder);
    else
        fprintf('Error! File %s not found!\nSkipping preparation of brain segmentation!\n\n', strPathVmrFile);
    end
    %}
end

end

