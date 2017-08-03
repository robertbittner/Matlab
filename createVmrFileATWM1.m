function [bFileCreated] = createVmrFileATWM1(folderDefinition, parametersProjectFiles, parametersStructuralMriSequence, parametersProcessDuration)
%%% © 2016 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function creates VMR Projects.

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions

processDuration = parametersProcessDuration.vmrFileCreation;

%%% Determine the name and path of the project file
%strVmrFile = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, parametersProjectFiles.extStructuralProject);
strVmrFile = sprintf('%s_%s_%s%s', strSubject, iStudy, parametersProjectFiles.strCurrentProject, parametersProjectFiles.extStructuralProject);
strPathVmrFile = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strVmrFile);

%%% Determine the name and path of the v16 project file
strVmrFileV16 = strcat(strSubject, '_', iStudy, '_', parametersProjectFiles.strCurrentProject, parametersProjectFiles.extStructuralProjectV16);
strPathVmrFileV16 = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strVmrFileV16);

if ~exist(strPathVmrFile, 'file') || ~exist(strPathVmrFileV16, 'file')
    
    %%% Check compatibility of the currently installed version of BrainVoyager
    %%% and run BrainVoyager as a COM object
    hFunction = str2func(sprintf('runBrainVoyagerQX%s', iStudy));
    %hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
    [bvqx, parametersComProcess, parametersBrainVoyager, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
    if bIncompatibleBrainVoyagerVersion == true
        return
    end
    
    %%% Open additional Matlab command window to terminate crashed BrainVoyager
    %%% COM objects
    hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
    matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
    
    try
        fprintf('Creating VMR for study: %s\t\tsubject: %s\t\tanatomical sequence: %s\n', iStudy, strSubject, parametersProjectFiles.strCurrentProject);
        vmr = bvqx.CreateProjectVMR(parametersStructuralMriSequence.strFileType, parametersProjectFiles.strPathFirstSourceFile, parametersStructuralMriSequence.nSlices, parametersStructuralMriSequence.isLittleEndian, parametersStructuralMriSequence.xSize, parametersStructuralMriSequence.ySize, parametersStructuralMriSequence.nBytes);
        vmr.SaveAs(strPathVmrFile);
        vmr.Close();
        bvqx.Exit
        fprintf('File %s was created.\n\n', strVmrFile);
        bFileCreated = true;
    catch
        fprintf('Error!\nFile %s could not be created!\n\n', strVmrFile);
        bFileCreated = false;
    end
    
    hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
    feval(hFunction, matlabCommandWindowProcessId, processDuration);
    
else
    fprintf('File %s already exists!\n', strVmrFile);
    fprintf('File %s already exists!\n\n', strVmrFileV16);
    bFileCreated = true;
end


end