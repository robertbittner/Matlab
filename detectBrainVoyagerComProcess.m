function parametersComProcess = detectBrainVoyagerComProcess();
global iStudy

parametersBrainVoyager = eval(['parametersBrainVoyager', iStudy]);

hFunction = str2func(sprintf('detectActiveProgramInstances%s', iStudy));
parametersProgramInstances = feval(hFunction, parametersBrainVoyager.strBrainVoyagerExecutable);

parametersComProcess.iProcess       = find(strcmp(parametersProgramInstances.windowTitle, parametersBrainVoyager.strBrainVoyagerComProcess));
parametersComProcess.nComProcesses  = numel(parametersComProcess.iProcess);
for cp = 1:parametersComProcess.nComProcesses
    parametersComProcess.pid{cp} = parametersProgramInstances.pid{parametersComProcess.iProcess(cp)};
end


end