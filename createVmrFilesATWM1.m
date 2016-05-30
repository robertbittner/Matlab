function [strPathVmrFile, bFilesCreated, bIncompatibleBrainVoyagerVersion] = createVmrFilesATWM1(indexProject);
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function creates VMR Projects.

%clear all
%clc

global iStudy;
global iGroup;
global iGroupLabel;
global iSubject;

%global bvqx
%global bIncompatibleBrainVoyagerVersion

%{
iStudy = 'ATWM1';
iSubject = 'PAT01';
%}

folderDefinition                  = eval(['folderDefinition', iStudy]);
parametersStudy                   = eval(['parametersStudy', iStudy]);



%pathDefinition                  = eval(['pathDefinition', iStudy]);
parametersStudy                 = eval(['parametersStudy', iStudy]);
%parametersParadigm              = eval(['parametersParadigm', iStudy]);
parametersProcessDuration       = eval(['parametersProcessDuration', iStudy]);
parametersStructuralMriSequence = eval(['parametersStructuralMriSequence', iStudy]);
parametersDicomFiles            = eval(['parametersDicomFiles', iStudy]);
%parametersScanningSessions      = eval(['parametersScanningSessions', iStudy]);
parametersMriScan               = eval([iSubject, iStudy, 'ParametersMriScan']);

strProjectType = 'vmr';
processDuration = parametersProcessDuration.vmrFileCreation;


%%% Set default values for output variables
bFilesCreated = false;
strPathVmrFile = [];
bIncompatibleBrainVoyagerVersion = false;


iSessionAnatomy = 'session_anatomy';

%indexProject = parametersMriScan.fileIndexVmr(1);



folderDefinition.strProjectDataFolder = [folderDefinition.singleSubjectData, iSubject, '\'];
folderDefinition.strProjectDataFolder = 'D:\Daten\ATWM1\Single_Subject_Data\Pilot_Scans\Script_Test\PAT01\';

%{
aStrProjectDataSubFolder = createArrayProjectDataSubFolderAWMS(parametersParadigm, parametersDicomFiles, folderDefinition.strProjectDataFolder);
if length(aStrProjectDataSubFolder) > parametersParadigm.nSessions + 1
    nAnatomicalScans = length(aStrProjectDataSubFolder) - parametersParadigm.nSessions;
    bMultipleAnatomicalScans = true;
else
    nAnatomicalScans = 1;
    bMultipleAnatomicalScans = false;
end
%}
%nAnatomicalScans = 1;

%for cas = 1:nAnatomicalScans

folderDefinition.strProjectDataSubFolder = folderDefinition.strProjectDataFolder; %aStrProjectDataSubFolder{parametersParadigm.nSessions + cas};

%%% Determine the names of the DICOM files of the VMR project
iDicomFileRun = indexProject;
nDicomFilesForProject = parametersStructuralMriSequence.nSlices;
hFunction = str2func(sprintf('determineDicomFilesForProject%s', iStudy));
[aStrPathSourceFile, strPathFirstSourceFile, bAbortFunction] = feval(hFunction, folderDefinition, parametersMriScan, strProjectType, iDicomFileRun, nDicomFilesForProject);
if bAbortFunction == true
    return
end

%{
bMultipleAnatomicalScans = false;
if bMultipleAnatomicalScans == false
    strVmrFile = [iSubject, '_', iStudy, '_', parametersStructuralMriSequence.indexSequence, '.vmr'];
else
    strVmrFile = [iSubject, '_', iStudy, '_', parametersStructuralMriSequence.indexSequence, '_', iSessionAnatomy, '_', num2str(cas), '.vmr'];
end
%}

strVmrFile = [iSubject, '_', iStudy, '_', parametersStructuralMriSequence.indexSequence, '.vmr'];
strPathVmrFile = strcat(folderDefinition.strProjectDataSubFolder, strVmrFile);

%%% Check compatibility of the currently installed version of BrainVoyager 
%%% and run BrainVoyager as a COM object
hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
[bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
bIncompatibleBrainVoyagerVersion = true
if bIncompatibleBrainVoyagerVersion == true
    return
end

%%% Open additional Matlab command window to terminate crashed BrainVoyager
%%% COM objects
hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);

try
    strMessage = sprintf('Creating VMR for study: %s\t\tsubject: %s\t\tanatomical sequence: %s', iStudy, iSubject, parametersStructuralMriSequence.indexSequence);
    disp(strMessage);
    bvqx.PrintToLog(strMessage);
    vmr = bvqx.CreateProjectVMR(parametersStructuralMriSequence.fileType, strPathFirstSourceFile, parametersStructuralMriSequence.nSlices, parametersStructuralMriSequence.isLittleEndian, parametersStructuralMriSequence.xSize, parametersStructuralMriSequence.ySize, parametersStructuralMriSequence.nBytes);
    vmr.SaveAs(strVmrFile);
    vmr.Close();
    bvqx.Exit
catch
    strMessage = sprintf('%s not created!', strVmrFile);
    disp(strMessage);
end

if exist(strPathVmrFile, 'file')
    bFilesCreated = true;
else
    bFilesCreated = false;
end

hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
feval(hFunction, matlabCommandWindowProcessId, processDuration);


end



