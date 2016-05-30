function matlabCommandWindowProcessId = initiateDelayedTerminationOfBrainVoyagerComProcessesATWM1(parametersComProcess, processDuration);
global iStudy

%%% Transform iStudy into ASCII code and prepare its transfer into another
%%% instance of Matlab
asciiCodeStudy = double(iStudy);
nLettersCode = numel(asciiCodeStudy);
strAsciiCode = sprintf('%i', nLettersCode);
for cl = 1:nLettersCode
    strAsciiCode = sprintf('%s, %i', strAsciiCode, asciiCodeStudy(cl));
end

parametersMatlab = eval(['parametersMatlab', iStudy]);

parametersMatlabInstances = detectActiveProgramInstancesATWM1(parametersMatlab.strMatlabExecutable);
parametersMatlabInstancesPre = parametersMatlabInstances;

bFunctionCalledByAdditionalMatlabInstance = true;
strCalledFunction = sprintf('terminateBrainVoyagerComProcess%s', iStudy);

for cp = 1:parametersComProcess.nComProcesses
    %%% Terminate each running COM process
    strCommand = sprintf('!matlab -automation -r "%s(%s, %i, %i, %s)" &', strCalledFunction, parametersComProcess.pid{cp} , processDuration, bFunctionCalledByAdditionalMatlabInstance, strAsciiCode);
    eval(strCommand);
end

%%% Get process ID of the newly opened matlab command window
parametersMatlabInstances = detectActiveProgramInstancesATWM1(parametersMatlab.strMatlabExecutable);
parametersMatlabInstancesPost = parametersMatlabInstances;
strNewProcessId = setxor(parametersMatlabInstancesPre.pid, parametersMatlabInstancesPost.pid);
matlabCommandWindowProcessId.strNewProcessId = strNewProcessId;
matlabCommandWindowProcessId.nNewMatlabCommandWindowsProcesses = numel(matlabCommandWindowProcessId.strNewProcessId);

%%% Confirm that 
counterMatlabCommandWindows = 0;
for cp = 1:parametersMatlabInstances.nRunningProgamInstances
    if strcmp(parametersMatlab.strMatlabCommandWindow, parametersMatlabInstances.windowTitle{cp})
        counterMatlabCommandWindows = counterMatlabCommandWindows + 1;
        matlabCommandWindowProcessId.aStrAllProcessIds{counterMatlabCommandWindows} = parametersMatlabInstances.pid{cp};
    end
end

end