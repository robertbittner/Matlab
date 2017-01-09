function createStructuralMriFilesInNiftiFormatATWM1()
%%% © 2015 Robert Bittner
%%% This function uses the NeuroElf toolboox to create anatomy files in
%%% nifti format from DICOM files

%{
clc 
clear all

global indexStudy;
global indexMethod;
global indexExperiment;
global indexSubject;

indexStudy = 'WMC2';
experimentNo = 1;
parametersStudy = eval(['parametersStudy', indexStudy]);

indexMethod     = parametersStudy.indexMRI;
indexExperiment = [parametersStudy.indexExperiment, num2str(experimentNo)];

pathDefinition                  = eval(['pathDefinition', indexStudy]);
parametersStructuralMriSequence = eval(['parametersStructuralMriSequence', indexStudy]);

strNiftiDataFolder = '__NIFTI';
strRawDataSubFolder = 'raw_data';


subjectArray = eval(['subjectArray', indexStudy]);

subjectArray = subjectArray.WMC2_MRI_EXP_1;
subjectArray = {
                %'TNJX757786834'
                %'RPCU886627594'
                'XJCU798590662'
                };

for s = 1:length(subjectArray)
    indexSubject = subjectArray{s};
    parametersMriScan               = eval([indexSubject, indexStudy, 'ParametersMriScan']); 

    rawDataPath     = [pathDefinition.singleSubjectData, indexExperiment, '\', indexSubject, '\'];
    projectDataPath = [pathDefinition.singleSubjectData, indexExperiment, '\', strNiftiDataFolder, '\', indexSubject, '\'];
    newRawDataPath  = [pathDefinition.singleSubjectData, indexExperiment, '\', strNiftiDataFolder, '\', indexSubject, '\', strRawDataSubFolder, '\'];
    
    if ~exist(projectDataPath, 'dir')
        mkdir(projectDataPath)
    end
    if ~exist(newRawDataPath, 'dir')
        mkdir(newRawDataPath)
    end
    dicomFileIndex = parametersMriScan.fileIndexVmr;
    dicomFileName = eval(['determineDicomFileName', indexStudy, '(indexSubject, dicomFileIndex)']);

    %%% create array containing all dcm-files of the anatomical scan
    for cSlice = 1:parametersStructuralMriSequence.nSlices
        aDicomFileName{cSlice} = sprintf('%s -%04i-0001-%05i.dcm', indexSubject, dicomFileIndex, cSlice);
    end
    
    %%% Check, whether dicom files exist in the renamed version, otherwise
    %%% rename them
    if ~exist(strcat(rawDataPath, aDicomFileName{1}), 'file')
        renameDicomFilesWMC2
    end
    %%% copy dcm-files to nifti folder
    bDataComplete = true;
    for cSlice = 1:parametersStructuralMriSequence.nSlices
        if ~exist(strcat(newRawDataPath, aDicomFileName{cSlice}), 'file')
            if exist(strcat(rawDataPath, aDicomFileName{cSlice}), 'file')
                copyfile(strcat(rawDataPath, aDicomFileName{cSlice}), strcat(newRawDataPath, aDicomFileName{cSlice}));
            else
                bDataComplete = false;
                strMessage = sprintf('File %s missing', aDicomFileName{cSlice});
                disp(strMessage);
                break
            end
        end
    end
%}
    %%% create nifti file
    %if bDataComplete == true;

    clear all
clc

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);
parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersDataSubFolders    = eval(['parametersDataSubFolders', iStudy]);
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);
 
%%% DELETE
%%{
aStrSubject = {
    'VE85QGL'
    };
nSubjects = numel(aStrSubject);
iSession = 1;
strGroup = parametersGroups.strShortControls;
vSessionIndex(1:nSubjects) = 1;
%}
strSubject = aStrSubject{1}
parametersMriSession = analyzeParametersMriScanFileATWM1;
 
parametersStructuralMriSequenceHighRes = eval(['parametersStructuralMriSequenceHighRes', iStudy]);

        parametersStructuralMriSequence                 = parametersStructuralMriSequenceHighRes;
    parametersProjectFiles.iDicomFileRun            = parametersMriSession.fileIndexVmrHighRes;
    parametersProjectFiles.nrOfDicomFilesForProject = parametersStructuralMriSequence.nSlices;
    %%% Determine subfolder and copy DICOM files
    parametersProjectFiles.strCurrentProject = sprintf('%s_%s', parametersStructuralMriSequence.strSequence , parametersStructuralMriSequence.strResolution);
    %[folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders);
    
    folderDefinition.strDicomFilesSubFolderCurrentSession = 'D:\Daten\ATWM1\Single_Subject_Data\CONT\VE85QGL\14_DICOM_session_1\';
    folderDefinition.strCurrentProjectDataSubFolder = 'D:\Daten\ATWM1\Single_Subject_Data\NIFTI\'
    parametersProjectFiles.strCurrentProjectType = parametersProjectFiles.strStructuralProject;

    [parametersProjectFiles, bAbortFunction] = prepareDicomFilesForProjectATWM1(folderDefinition, parametersProjectFiles)


    
    
    %%% Detect current NeuroElf toolbox folder
    strProgramFolder = 'Program';
    strMatlab = 'MATLAB';
    strMatlabToolbox = 'toolbox';
    strNeuroElf = 'NeuroElf';
    
    strNeuroElfSubfolder = '@neuroelf\private\'
    
    
    strPathNeuroElfToolbox = toolboxdir(strNeuroElf);
    
    return
    strucFolderMainDrive = dir('C:\');
    counterMatlabProgramFolder = 0;
    for cf = 1:numel(strucFolderMainDrive)
        if ~isempty(strfind(strucFolderMainDrive(cf).name, strProgramFolder))
            strPathMatlabProgramFolders = fullfile(strucFolderMainDrive(cf).folder, strucFolderMainDrive(cf).name, '\', strMatlab, '\', strCurrentMatlabVersion, '\', strMatlabToolbox);
            if exist(strPathMatlabProgramFolders, 'dir')
                counterMatlabProgramFolder = counterMatlabProgramFolder + 1;
                strPathMatlabProgramFolders= strPathMatlabProgramFolders
            end
        end
    end
    
    return
    
    
    strPathSpm12 = 'D:\Tools & Programme\SPM12\';
    strPathNeuroElf = 'C:\Program Files\MATLAB\R2016b\toolbox\NeuroElf_v11_6405\@neuroelf\private\';
    strPathCurrentMatlab = pwd;
    
    if exist(strPathSpm12, 'dir')
        cd(strPathNeuroElf);
        addpath(strPathSpm12);
        dcm2nii(folderDefinition.strCurrentProjectDataSubFolder, folderDefinition.strCurrentProjectDataSubFolder, struct('format', 'nii'));
        rmpath(strPathSpm12);
        cd(strPathCurrentMatlab);
    else
        fprintf('Error\nDirectory containing SPM12 toolbox not found!\n');
        fprintf('Could not create NIFTI version of MriSequenceHighRes for subject %s\n', strSubject);
    end
    
    %{
    flags       optional settings
         .disdaqs   if given, remove first N volumes of 4D data (0)
         .dtype     datatype, either of 'int16' or {'single'}
         .flip      additionally flip data (e.g. 'xy')
         .mosaic    flag to force mosaic processing
         .mosdimord mosaic dimension order (default: [1, 2])
         .nslices   number of slices for 1-slice DCM files
         .xyres     functional x/y resolution (default [64, 64])
   
    
    %flags.disdaqs   % given, remove first N volumes of 4D data (0)
        flags.dtype = 'int16'    %datatype, either of 'int16' or {'single'}
         %flags.flip     %additionally flip data (e.g. 'xy')
         %flags.mosaic    %flag to force mosaic processing
         %flags.mosdimord %mosaic dimension order (default: [1, 2])
         flags.nslices = 192  %number of slices for 1-slice DCM files
         flags.xyres = [256, 256]    %functional x/y resolution (default [64, 64])
    nii = dicom2nii(parametersProjectFiles.aStrPathSourceFilesProjectSubfolder)
    
    nii.SaveAs(fullfile(folderDefinition.strCurrentProjectDataSubFolder, 'TEST.nii'))
     %}
    
    %newRawDataPath = 'D:\Daten\ATWM1\Single_Subject_Data\TEST\'
%        dcm2nii(newRawDataPath, projectDataPath, struct('format', 'nii'))
    %{
    else
        strMessage = sprintf('Data incomplete for subject %s!/nProceeding to next subject', indexSubject);
        disp(strMessage);
    end
    %%% delete raw data
    rmdir(newRawDataPath,'s')
    %}
end
