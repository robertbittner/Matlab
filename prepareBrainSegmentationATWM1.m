function prepareBrainSegmentationATWM1()

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

%{
%%% Select subjects
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'multiple';
[strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end
%}

%%% REMOVE
strGroup = 'CONT';
aStrSubject = {'CX75DJQ'};
nSubjects = 1;
%%% REMOVE

parametersProjectFiles.strHighResAnatomy = sprintf('%s_%s', parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution);

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    vmr = defineStandardVmrFileNamesATWM1;
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    %%% REMOVE
    structProjectDataSubFolders.strFolder_MPRAGE_HIGH_RES = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\CX75DJQ\11_MPRAGE_HIGH_RES\';
    %%% REMOVE
    
    strFolderHighResAnatomy = structProjectDataSubFolders.(matlab.lang.makeValidName(sprintf('strFolder_%s', parametersProjectFiles.strHighResAnatomy)));
    strSubFolderBrainSegm   = structProjectDataSubFolders.(matlab.lang.makeValidName(sprintf('strFolder_%s_%s_%s', parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainSegmentation.strSegmentation)));
    strPathVmrInTalFile     = fullfile(strFolderHighResAnatomy, vmr.strVmrInTalFile);
    strPathVmrInTalSegmFile = fullfile(strSubFolderBrainSegm, vmr.strVmrInTalSegmFile);
  
    %%{
    if exist(strPathVmrInTalFile, 'file')
        if ~exist(strSubFolderBrainSegm, 'dir')
            try
                mkdir(strSubFolderBrainSegm);
                fprintf('Creating subfolder %s\n', strSubFolderBrainSegm);
                try
                    copyfile(strPathVmrInTalFile, strPathVmrInTalSegmFile);
                    fprintf('Creating file %s\n\n', strPathVmrInTalSegmFile);
                catch
                    fprintf('Error! Could not create file %s!\n', strPathVmrInTalSegmFile);
                end
            catch
                fprintf('Error! Could not create new subfolder %s!\n', strSubFolderBrainSegm);
            end
        end
    else
        fprintf('Error! File %s not found!\nSkipping preparation of brain segmentation!\n\n', strPathVmrInTalFile);
    end
    %}
end

end


function dkdk(aStrSubject, folderDefinition)

global iStudy
global strGroup
global strSubject

    strSubject = aStrSubject{cs};
    vmr = defineStandardVmrFileNamesATWM1;
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    %%% REMOVE
    structProjectDataSubFolders.strFolder_MPRAGE_HIGH_RES = 'D:\Daten\ATWM1\Single_Subject_Data\Daten von Mishal\CX75DJQ\11_MPRAGE_HIGH_RES\';
    %%% REMOVE
    
    strFolderHighResAnatomy = structProjectDataSubFolders.(matlab.lang.makeValidName(sprintf('strFolder_%s', parametersProjectFiles.strHighResAnatomy)));
    strSubFolderBrainSegm   = structProjectDataSubFolders.(matlab.lang.makeValidName(sprintf('strFolder_%s_%s_%s', parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainSegmentation.strSegmentation)));
    strPathVmrInTalFile     = fullfile(strFolderHighResAnatomy, vmr.strVmrInTalFile);
    strPathVmrInTalSegmFile = fullfile(strSubFolderBrainSegm, vmr.strVmrInTalSegmFile);
  
    %%{
    if exist(strPathVmrInTalFile, 'file')
        if ~exist(strSubFolderBrainSegm, 'dir')
            try
                mkdir(strSubFolderBrainSegm);
                fprintf('Creating subfolder %s\n', strSubFolderBrainSegm);
                try
                    copyfile(strPathVmrInTalFile, strPathVmrInTalSegmFile);
                    fprintf('Creating file %s\n\n', strPathVmrInTalSegmFile);
                catch
                    fprintf('Error! Could not create file %s!\n', strPathVmrInTalSegmFile);
                end
            catch
                fprintf('Error! Could not create new subfolder %s!\n', strSubFolderBrainSegm);
            end
        end
    else
        fprintf('Error! File %s not found!\nSkipping preparation of brain segmentation!\n\n', strPathVmrInTalFile);
    end
    %}



end