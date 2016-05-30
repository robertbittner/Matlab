function createAnatomyFilesInNiftiFormatWMC2 ();
%%% © 2015 Robert Bittner
%%% This function uses the NeuroElf toolboox to create anatomy files in
%%% nifti format from DICOM files

strFolder = 'D:\Daten\ATWM1\Single_Subject_Data\VW42LKU\';
strFile = 'VW42LKU_MPRAGE.vmr';
strPathVmrFile = fullfile(strFolder, strFile);

vmr = xff(strPathVmrFile)

end

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
    %%% create nifti file
    if bDataComplete == true;
        dcm2nii(newRawDataPath, projectDataPath, struct('format', 'nii'))
    else
        strMessage = sprintf('Data incomplete for subject %s!/nProceeding to next subject', indexSubject);
        disp(strMessage);
    end
    %%% delete raw data
    rmdir(newRawDataPath,'s')
    
end
%}