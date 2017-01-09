function parametersComProcess = detectBrainVoyagerComProcessATWM1()

global iStudy

parametersBrainVoyager  = eval(['parametersBrainVoyager', iStudy]);
parametersComProcess    = eval(['parametersComProcess', iStudy]);

hFunction = str2func(sprintf('detectActiveProgramInstances%s', iStudy));
parametersProgramInstances = feval(hFunction, parametersBrainVoyager.strBrainVoyagerExecutable);

parametersComProcess.iProcess       = find(strcmp(parametersProgramInstances.windowTitle, parametersBrainVoyager.strBrainVoyagerComProcess));
parametersComProcess.nComProcesses  = numel(parametersComProcess.iProcess);
for cp = 1:parametersComProcess.nComProcesses
    parametersComProcess.pid{cp} = parametersProgramInstances.pid{parametersComProcess.iProcess(cp)};
end

if sum(strcmp(fieldnames(parametersComProcess), parametersComProcess.strProcessId)) == 1
    parametersComProcess.bBrainVoyagerRunningAsCom = true;
else
    parametersComProcess.bBrainVoyagerRunningAsCom = false;
end


end