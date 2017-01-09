function delayedTerminationOfMatlabCommandWindowsATWM1(matlabCommandWindowProcessId, processDuration)

global iStudy

parametersMatlab            = eval(['parametersMatlab', iStudy]);
parametersProcessDuration	= eval(['parametersProcessDuration', iStudy]);

maximumDelay = processDuration * parametersProcessDuration.factorMaximumDelay;
currentDelay = 0;
bMatlabCommandWindowRunning = true;
while bMatlabCommandWindowRunning == true
    parametersMatlabInstances = detectActiveProgramInstancesATWM1(parametersMatlab.strMatlabExecutable);
    nMatlabCommandWindowsProcesses = numel(matlabCommandWindowProcessId);
    if matlabCommandWindowProcessId.nNewMatlabCommandWindowsProcesses ~= 0
        for cp = 1:matlabCommandWindowProcessId.nNewMatlabCommandWindowsProcesses
            iMatlabCommandWindowRunning(cp) = ~isempty(cell2mat(strfind(parametersMatlabInstances.pid, matlabCommandWindowProcessId.strNewProcessId{cp})));
        end
        bMatlabCommandWindowRunning = sum(iMatlabCommandWindowRunning);
        if bMatlabCommandWindowRunning == true
            parametersComProcess = detectBrainVoyagerComProcessATWM1;
            pause(parametersProcessDuration.delayBeforeUpdate)
            currentDelay = currentDelay + parametersProcessDuration.delayBeforeUpdate;
            if currentDelay >= maximumDelay || ~parametersComProcess.bBrainVoyagerRunningAsCom
                for cmcwp = 1:nMatlabCommandWindowsProcesses
                    [~, ~] = system(['taskkill /f /pid ' matlabCommandWindowProcessId.strNewProcessId{cmcwp}]);
                end
                bMatlabCommandWindowRunning = false;
            end
        end
    else
        bMatlabCommandWindowRunning = false;
    end
end


end