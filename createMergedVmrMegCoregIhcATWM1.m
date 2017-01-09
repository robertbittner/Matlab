function createMergedVmrMegCoregIhcATWM1()

clear all
clc

global iStudy
global strGroup
global strSubject

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);
%parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
%parametersDataSubFolders    = eval(['parametersDataSubFolders', iStudy]);
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);
parametersNiftiExport       = eval(['parametersNiftiExport', iStudy]);

parametersStructuralMriSequence         = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersPreprocessingStructuralMri    = eval(['parametersPreprocessingStructuralMri', iStudy]);

hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%%% Check server access
bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    return
end

%%% Select subjects
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'multiple';
[strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end

fprintf('Creating merged VMR(s) and NIFTI(s) %s_%s\n\n', parametersStudy.strMegCoregistration, parametersPreprocessingStructuralMri.strIntensityInhomogeneityCorrection);

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    [strPathVmrBrainIhc, strPathVmrMegCoreg, strPathVmrMegCoregIhc] = defineVmrFilesToBeMergedATWM1(parametersStudy, parametersProjectFiles, parametersStructuralMriSequence, parametersPreprocessingStructuralMri, structProjectDataSubFolders);
    if exist(strPathVmrBrainIhc, 'file') && exist(strPathVmrMegCoreg, 'file')
        createMissingV16FilesATWM1(parametersProjectFiles, strPathVmrMegCoreg, strPathVmrBrainIhc)
        [strPathVmrMegCoregIhc, strPathNiftiMegCoregIhc] = createMegCoregIhcFilesATWM1(parametersProjectFiles, parametersNiftiExport, strPathVmrMegCoreg, strPathVmrBrainIhc, strPathVmrMegCoregIhc);
        [bFileTransferSuccessful] = transferNiftiMegCoregIhcToServerATWM1(folderDefinition, strPathNiftiMegCoregIhc);
    else
        displayMissingVmrFilesForMergingATWM1(strPathVmrBrainIhc, strPathVmrMegCoreg, strPathVmrMegCoregIhc);
    end
end


end


function [strPathVmrBrainIhc, strPathVmrMegCoreg, strPathVmrMegCoregIhc] = defineVmrFilesToBeMergedATWM1(parametersStudy, parametersProjectFiles, parametersStructuralMriSequence, parametersPreprocessingStructuralMri, structProjectDataSubFolders)

global iStudy
global strSubject

%%% Define HIGH_RES_mIIHC.vmr
parametersProjectFiles.strCurrentProject = sprintf('%s_%s', parametersStructuralMriSequence.strSequence , parametersStructuralMriSequence.strResolution);
strVmrBrainIhc = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, '_', parametersPreprocessingStructuralMri.strManualIntensityInhomogeneityCorrection, parametersProjectFiles.extStructuralProject);
%strVmrBrainIhc = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, '_', parametersPreprocessingStructuralMri.strIntensityInhomogeneityCorrection, parametersProjectFiles.extStructuralProject);
strPathVmrBrainIhc = fullfile(structProjectDataSubFolders.strFolder_MPRAGE_HIGH_RES, strVmrBrainIhc);

%%% Define MEG_COREG.vmr
strVmrMegCoreg = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, '_', parametersStudy.strMegCoregistration, parametersProjectFiles.extStructuralProject);
strPathVmrMegCoreg = fullfile(structProjectDataSubFolders.strFolder_MPRAGE_MEG_COREG, strVmrMegCoreg);

%%% Define merged MEG_COREG_mIIHC.vmr
strVmrMegCoregIhc = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, '_', parametersStudy.strMegCoregistration, '_', parametersPreprocessingStructuralMri.strManualIntensityInhomogeneityCorrection, parametersProjectFiles.extStructuralProject);
%strVmrMegCoregIhc = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, '_', parametersStudy.strMegCoregistration, '_', parametersPreprocessingStructuralMri.strIntensityInhomogeneityCorrection, parametersProjectFiles.extStructuralProject);
strPathVmrMegCoregIhc = fullfile(structProjectDataSubFolders.strFolder_MPRAGE_MEG_COREG, strVmrMegCoregIhc);


end


function createMissingV16FilesATWM1(parametersProjectFiles, strPathVmrMegCoreg, strPathVmrBrainIhc)

%%% create missing v16 files
strPathV16MegCoreg = strrep(strPathVmrMegCoreg, parametersProjectFiles.extStructuralProject, parametersProjectFiles.extStructuralProjectV16);
if ~exist(strPathV16MegCoreg, 'file')
    vmr = xff(strPathVmrBrainIhc);
    vmr.VMRData16 = uint16(vmr.VMRData);
    vmr.SaveV16(strPathV16MegCoreg);
    vmr.ClearObject;
end
strPathV16BrainIhc = strrep(strPathVmrBrainIhc, parametersProjectFiles.extStructuralProject, parametersProjectFiles.extStructuralProjectV16);
if ~exist(strPathV16BrainIhc, 'file')
    vmr = xff(strPathVmrBrainIhc);
    vmr.VMRData16 = uint16(vmr.VMRData);
    vmr.SaveV16(strPathV16BrainIhc);
    vmr.ClearObject;
end


end


function [strPathVmrMegCoregIhc, strPathNiftiMegCoregIhc] = createMegCoregIhcFilesATWM1(parametersProjectFiles, parametersNiftiExport, strPathVmrMegCoreg, strPathVmrBrainIhc, strPathVmrMegCoregIhc)
%%% Merge VMRs
try
    %%% Load both VMRs
    vmrMegCoreg = xff(strPathVmrMegCoreg);
    vmrBrainIihc = xff(strPathVmrBrainIhc);
    %%% Create mask from vmrBrainIihc
    maskThreshold = 10;
    mask = vmrBrainIihc.VMRData > maskThreshold; % threshold 10, I believe BVQX still uses this internal as some kind of "background" threshold
    %%% Merge datasets
    vmrMegCoreg.LoadTransIOData;
    vmrMegCoreg.VMRData(mask) = vmrBrainIihc.VMRData(mask);
    if ~isempty(vmrMegCoreg.VMRData16)
        vmrMegCoreg.VMRData16(mask) = vmrBrainIihc.VMRData16(mask);
    end
    %%% Save merged VMR
    vmrMegCoreg.SaveAs(strPathVmrMegCoregIhc);
    fprintf('Saving merged file %s\n\n', strPathVmrMegCoregIhc);
    try
        %%% Export to NIFTI format
        strPathNiftiMegCoregIhc = strrep(strPathVmrMegCoregIhc, parametersProjectFiles.extStructuralProject, parametersProjectFiles.extNiftiFile);
        vmrMegCoreg.ExportNifti(strPathNiftiMegCoregIhc, parametersNiftiExport.bUseStandardNiftiAxes);
        fprintf('Exporting NIFTI file %s\n\n', strPathNiftiMegCoregIhc);
    catch
        fprintf('Error!\nCould not export %s to NIFTI!\n\n', strPathVmrMegCoregIhc);
    end
catch
    
end
%%% clear objects
vmrMegCoreg.ClearObject;
vmrBrainIihc.ClearObject;


end


function [bFileTransferSuccessful] = transferNiftiMegCoregIhcToServerATWM1(folderDefinition, strPathNiftiMegCoregIhc)
%%% Transfer NIFTI file to server

global strGroup

%%% Define NIFTI file name
strSeparator = '\';
indSeparator = strfind(strPathNiftiMegCoregIhc, strSeparator);
indSeparator = indSeparator(end);
strNiftiMegCoregIhc = strPathNiftiMegCoregIhc(indSeparator + 1 : end);
%%% Define paths
strPathNiftiMegCoregIhcTransferLocal    = strcat(folderDefinition.niftiFilesMegCoreg, strGroup, '\', strNiftiMegCoregIhc);
strPathNiftiMegCoregIhcTransferServer   = strcat(folderDefinition.niftiFilesMegCoregServer, strGroup, '\', strNiftiMegCoregIhc);
%%% Transfer file
[success(1)] = copyfile(strPathNiftiMegCoregIhc, strPathNiftiMegCoregIhcTransferLocal);
[success(2)] = copyfile(strPathNiftiMegCoregIhc, strPathNiftiMegCoregIhcTransferServer);

if sum(success) == numel(success)
    bFileTransferSuccessful = true;
    fprintf('Transfer of NIFTI file %s to server successful!\n\n', strPathNiftiMegCoregIhc)
else
    bFileTransferSuccessful = false;
    fprintf('Error!\nTransfer of NIFTI file %s to server failed!\n\n', strPathNiftiMegCoregIhc)
end


end


function displayMissingVmrFilesForMergingATWM1(strPathVmrBrainIhc, strPathVmrMegCoreg, strPathVmrMegCoregIhc)

% One or more files not found
if ~exist(strPathVmrBrainIhc, 'file')
    fprintf('%s not found!\n', strPathVmrBrainIhc);
end
if ~exist(strPathVmrMegCoreg, 'file')
    fprintf('%s not found!\n', strPathVmrMegCoreg);
end
fprintf('Could not create %s!\n\n', strPathVmrMegCoregIhc);


end


function TESTcreateMergedVmrMegCoregIhcATWM1()

clear all
clc

global iStudy
global strGroup
global strSubject

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);
parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersDataSubFolders    = eval(['parametersDataSubFolders', iStudy]);
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);
parametersNiftiExport       = eval(['parametersNiftiExport', iStudy]);

parametersStructuralMriSequence         = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersPreprocessingStructuralMri    = eval(['parametersPreprocessingStructuralMri', iStudy]);

hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%%% Check server access
bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    return
end

%%{
%%% REMOVE
aStrSubject = {
    'DJ32GUZ'
    %'NT90DXA'
    %'YK95HMC'
    };
strGroup = 'CONT';
nSubjects = numel(aStrSubject);
%}
%%% REINSTATE
%{
%%% Select subjects
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'multiple';
%iSession = 1;

[strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end
%}
fprintf('Creating merged VMR(s) and NIFTI(s) %s_%s\n\n', parametersStudy.strMegCoregistration, parametersPreprocessingStructuralMri.strIntensityInhomogeneityCorrection);

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
    %%{
    %%% REMOVE
    strPath = 'D:\Daten\ATWM1\Single_Subject_Data\zzzTEST\_TEST\';
    folderDefinition.strCurrentSubjectDataFolder = strcat(strPath, strSubject, '\');
    %%%
    %}
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    [strPathVmrBrainIhc, strPathVmrMegCoreg, strPathVmrMegCoregIhc] = defineVmrFilesToBeMergedATWM1(parametersStudy, parametersProjectFiles, parametersStructuralMriSequence, parametersPreprocessingStructuralMri, structProjectDataSubFolders);
    if exist(strPathVmrBrainIhc, 'file') && exist(strPathVmrMegCoreg, 'file')
        createMissingV16FilesATWM1(parametersProjectFiles, strPathVmrMegCoreg, strPathVmrBrainIhc)
        [strPathVmrMegCoregIhc, strPathNiftiMegCoregIhc] = createMegCoregIhcFilesATWM1(parametersProjectFiles, parametersNiftiExport, strPathVmrMegCoreg, strPathVmrBrainIhc, strPathVmrMegCoregIhc);
        [bFileTransferSuccessful] = transferNiftiMegCoregIhcToServerATWM1(folderDefinition, strPathNiftiMegCoregIhc);
    else
        displayMissingVmrFilesForMergingATWM1(strPathVmrBrainIhc, strPathVmrMegCoreg, strPathVmrMegCoregIhc);
    end
end


end