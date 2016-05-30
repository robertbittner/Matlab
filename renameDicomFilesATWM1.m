function renameDicomFilesATWM1(targetFolder);
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function renames DICOM Files

global iStudy;

parametersProcessDuration       = eval(['parametersProcessDuration', iStudy]);
processDuration = parametersProcessDuration.renameDicomFiles;

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

try
    renameDicomFiles = bvqx.RenameDicomFilesInDirectory(targetFolder);
    bvqx.Exit;    
catch
    
hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
feval(hFunction, matlabCommandWindowProcessId, processDuration);
    
end

