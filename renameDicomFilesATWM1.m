function bRenameDicomFilesSuccessful = renameDicomFilesATWM1(folderDefinition, parametersDicomFiles, bRenameDicomFilesSuccessful)
%%% © 2016 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function renames DICOM Files

global iStudy
global strSubject

parametersProcessDuration       = eval(['parametersProcessDuration', iStudy]);
%parametersDicomFiles            = eval(['parametersDicomFiles', iStudy]);

processDuration = parametersProcessDuration.renameDicomFiles;
strTargetFolder = folderDefinition.strDicomFilesSubFolderCurrentSession;

[bDicomFilesFound, bUnrenamedDicomFilesFound] = detectUnrenamedDicomFilesATWM1(parametersDicomFiles, strTargetFolder);

if bDicomFilesFound && bUnrenamedDicomFilesFound
    %%% Check compatibility of the currently installed version of BrainVoyager
    %%% and run BrainVoyager as a COM object
    hFunction = str2func(sprintf('runBrainVoyagerQX%s', iStudy));
    %hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
    [bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
    if bIncompatibleBrainVoyagerVersion == true
        return
    end
    
    %%% Open additional Matlab command window to terminate crashed BrainVoyager
    %%% COM objects
    hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
    matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
    
    try
        bvqx.RenameDicomFilesInDirectory(strTargetFolder);
        bvqx.Exit;
        removeSpaceFromDicomFileNameATWM1(strTargetFolder);
    catch
        hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
        feval(hFunction, matlabCommandWindowProcessId, processDuration);
    end
end

[bRenameDicomFilesSuccessful] = determineRenameDicomFilesSuccessATWM1(parametersDicomFiles, strTargetFolder, bRenameDicomFilesSuccessful);


end


function [bRenameDicomFilesSuccessful] = determineRenameDicomFilesSuccessATWM1(parametersDicomFiles, strTargetFolder, bRenameDicomFilesSuccessful)

global strSubject

[bDicomFilesFound, bUnrenamedDicomFilesFound] = detectUnrenamedDicomFilesATWM1(parametersDicomFiles, strTargetFolder);

if ~bUnrenamedDicomFilesFound && bDicomFilesFound
    bRenameDicomFilesSuccessful = true;
    fprintf('Rename DICOM files in folder %s successful!\n\n', strTargetFolder);
elseif bDicomFilesFound
    fprintf('Rename DICOM files in folder %s incomplete!\nRepeating process.\n', strTargetFolder);
else
    bRenameDicomFilesSuccessful = true;
    fprintf('No DICOM files found in folder %s\n', strTargetFolder);
end

end