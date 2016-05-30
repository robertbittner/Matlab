function delayedTerminationOfMatlabCommandWindowsATWM1(matlabCommandWindowProcessId, processDuration);
global iStudy

parametersMatlab            = eval(['parametersMatlab', iStudy]);
parametersProcessDuration	= eval(['parametersProcessDuration', iStudy]);


maximumDelay = processDuration * parametersProcessDuration.factorMaximumDelay;
currentDelay = 0;
bMatlabCommandWindowRunning = true;
while bMatlabCommandWindowRunning == true
    parametersMatlabInstances = detectActiveProgramInstancesATWM1(parametersMatlab.strMatlabExecutable);
    nMatlabCommandWindowsProcesses = numel(matlabCommandWindowProcessId);
    for cp = 1:matlabCommandWindowProcessId.nNewMatlabCommandWindowsProcesses
        iMatlabCommandWindowRunning(cp) = ~isempty(cell2mat(strfind(parametersMatlabInstances.pid, matlabCommandWindowProcessId.strNewProcessId{cp})));
    end
    bMatlabCommandWindowRunning = sum(iMatlabCommandWindowRunning);
    if bMatlabCommandWindowRunning == true
        pause(parametersProcessDuration.delayBeforeUpdate)
        currentDelay = currentDelay + parametersProcessDuration.delayBeforeUpdate;
        if currentDelay >= maximumDelay
            for cmcwp = 1:nMatlabCommandWindowsProcesses
                system(['taskkill /f /pid ' matlabCommandWindowProcessId{cmcwp}])
            end
            bMatlabCommandWindowRunning = false;
        end
    end
end

%{
while bMatlabCommandWindowRunning == true
    parametersMatlabInstances = detectActiveProgramInstancesATWM1(parametersMatlab.strMatlabExecutable);
    nMatlabCommandWindowsProcesses = numel(matlabCommandWindowProcessId);
    for cmcwp = 1:nMatlabCommandWindowsProcesses
        bMatlabCommandWindowRunning(cmcwp) = ~isempty(cell2mat(strfind(parametersMatlabInstances.pid, matlabCommandWindowProcessId{cmcwp})));
    end
    pause(parametersProcessDuration.delayBeforeUpdate)
    currentDelay = currentDelay + parametersProcessDuration.delayBeforeUpdate;
    if currentDelay >= maximumDelay
        for cmcwp = 1:nMatlabCommandWindowsProcesses
            system(['taskkill /f /pid ' matlabCommandWindowProcessId{cmcwp}])
        end
        bMatlabCommandWindowRunning = false;
    end
end
%}


end