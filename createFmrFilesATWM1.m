function [strPathFmrFile, bFileCreated, bIncompatibleBrainVoyagerVersion] = createFmrFilesATWM1(indexProject);
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function creates a MosaicFMR project.


global iStudy;
global iGroup;
global iGroupLabel;
global iSubject;

%{
iStudy = 'ATWM1';
iSubject = 'PAT01';
indexProject = 1;
%}

folderDefinition                  = eval(['folderDefinition', iStudy]);
parametersStudy                   = eval(['parametersStudy', iStudy]);
parametersProcessDuration       = eval(['parametersProcessDuration', iStudy]);
%parametersParadigm              = eval(['parametersParadigm', iStudy]);
%parametersFunctionalMriSequence = eval(['parametersFunctionalMriSequence', iStudy]);
%parametersDicomFiles            = eval(['parametersDicomFiles', iStudy]);
parametersMriScan               = eval([iSubject, iStudy, 'ParametersMriScan']);


parametersFunctionalMriSequenceWorkingMemory = eval(['parametersFunctionalMriSequence_WM', iStudy]);

parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', iStudy]);

parametersMriScan               = eval([iSubject, iStudy, 'ParametersMriScan']);

processDuration = parametersProcessDuration.fmrFileCreation;

strProjectType = 'fmr';


parametersFunctionalMriSequenceWorkingMemory.nVolumes = 209;

parametersFunctionalMriSequence = parametersFunctionalMriSequenceWorkingMemory;



%%% Determine the run number
iFunctionalRun = find(ismember(parametersMriScan.fileIndexFmr, indexProject));

    %strProjectDataFolder = [folderDefinition.singleSubjectData, iGroup, '\', iSubject, '\'];
    
    
    folderDefinition.strProjectDataFolder = 'D:\Daten\ATWM1\Single_Subject_Data\Pilot_Scans\Script_Test\PAT01\';
    
    %%% Define differently
    strParadigm = parametersStudy.aStrParadigm{1} %% e.g. WMT or LOC
    
    %%% Check compatibility of the currently installed version of BrainVoyager
    %%% and run BrainVoyager as a COM object
    hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
    [bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
    if bIncompatibleBrainVoyagerVersion == true
        return
    end
    
    %%% Open additional Matlab command window to terminate crashed BrainVoyager
    %%% COM objects
    hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
    matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
    
    
    %%% Define project data subfolder (?)
    folderDefinition.strProjectDataSubFolder =  folderDefinition.strProjectDataFolder
    
    %%{
    folderDefinition.strProjectDataSubFolder = folderDefinition.strProjectDataFolder; %aStrProjectDataSubFolder{parametersParadigm.nRuns + cas};
    
    %%% Determine the names of the DICOM files of the project
    iDicomFileRun = indexProject;
    nDicomFilesForProject = parametersFunctionalMriSequence.nVolumes;
    hFunction = str2func(sprintf('determineDicomFilesForProject%s', iStudy));
    [aStrPathSourceFile, strPathFirstSourceFile, bAbortFunction] = feval(hFunction, folderDefinition, parametersMriScan, strProjectType, iDicomFileRun, nDicomFilesForProject);
    if bAbortFunction == true
        return
    end

    
    %%% Create FMR file name
    strFmrFile = sprintf('%s_%s_%s_%s%i.fmr', iSubject, iStudy, strParadigm, parametersStudy.strRun, iFunctionalRun);
    strPathFmrFile = strcat(folderDefinition.strProjectDataSubFolder, strFmrFile);
    
    %%% A blank protocol file for event-related averaging is created.
    %strAvgPrtFile = strcat(iSubject, '_', iStudy, '_', parametersStudy.strRun, num2str(iFunctionalRun), '_avg', '.prt');
    strAvgPrtFile = sprintf('%s_%s_%s_%s%i_avg.prt', iSubject, iStudy, strParadigm, parametersStudy.strRun, iFunctionalRun)
    strPathAvgPrtFile = strcat(folderDefinition.strProjectDataSubFolder, strAvgPrtFile);
    
    fid = fopen(strPathAvgPrtFile, 'wt');
    fclose(fid);
    %%%
    try
        bvqx.PrintToLog(['Creating FMR for study: ' iStudy '     subject: ' iSubject '     session: ' num2str(iFunctionalRun)]);
        
        fmr = bvqx.CreateProjectMosaicFMR(parametersFunctionalMriSequence.fileType, strPathFirstSourceFile, parametersFunctionalMriSequence.nVolumes, parametersFunctionalMriSequence.nVolumesToSkip, parametersFunctionalMriSequence.createAmr, parametersFunctionalMriSequence.nSlices, parametersFunctionalMriSequence.prefixStc, parametersFunctionalMriSequence.swapBytes, parametersFunctionalMriSequence.mosaicResX, parametersFunctionalMriSequence.mosaicResY, parametersFunctionalMriSequence.nBytes, folderDefinition.strProjectDataFolder, parametersFunctionalMriSequence.nVolumesInImage, parametersFunctionalMriSequence.resX, parametersFunctionalMriSequence.resY);
        fmr.TimeResolutionVerified = true;
        fmr.VoxelResolutionVerified = true;
        
        fmr.LinkStimulationProtocol(strPathAvgPrtFile);
        fmr.SaveAs(strPathFmrFile);
        fmr.Close();
        bvqx.Exit
    catch
        strMessage = sprintf('%s not created!', strFmrFile);
        disp(strMessage);
    end
    

    if exist(strPathFmrFile, 'file')
        bFileCreated = true;
    else
        bFileCreated = false;
    end
    
    
    hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
    feval(hFunction, matlabCommandWindowProcessId, processDuration);

end
%}


function createFmrFiles_NEW_ATWM1();

clear all
clc

global iStudy
global iSubject
global iGroup

iStudy = 'ATWM1';
iSubject = 'Test_001';


folderDefinition                = eval(['folderDefinition', iStudy]);
parametersStudy                 = eval(['parametersStudy', iStudy]);
parametersGroups                = eval(['parametersGroups', iStudy]);
parametersStructuralMriSequence = eval(['parametersStructuralMriSequence', iStudy]);



strProjectDataType = parametersStudy.strWorkingMemoryTask;
iRun = 1;
strProjectDataType = parametersStructuralMriSequence.indexSequence;
iRun = [];

iGroup = parametersGroups.strShortControls;

strSubjectDataFolder = strcat(folderDefinition.singleSubjectData, iGroup, '\', iSubject, '\');

strProjectDataSubFolder = selectProjectDataSubFolderATWM1(strSubjectDataFolder, strProjectDataType, [])


end