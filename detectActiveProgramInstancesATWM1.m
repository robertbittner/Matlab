function parametersProgramInstances = detectActiveProgramInstancesATWM1(strProgramExecutable);

strSeparator = '","';

%%% Search tasklist for instances of specified program
strCommand = sprintf('tasklist /v /fo "CSV" /fi "imagename eq %s"', strProgramExecutable);
[~,tasks] = system(strCommand);

iRunningProgramInstances = strfind(tasks, strProgramExecutable);
parametersProgramInstances.nRunningProgamInstances = numel(iRunningProgramInstances);

if parametersProgramInstances.nRunningProgamInstances == 0
    parametersProgramInstances.pid          = [];
    parametersProgramInstances.memoryUsage  = [];
    parametersProgramInstances.cpuTime      = [];
    parametersProgramInstances.windowTitle  = [];
else
    iCarriageReturnA = find(tasks == 10); % Unix & PC
    iCarriageReturnB = find(tasks == 13); % Mac & PC
    iCarriageReturn = sort([iCarriageReturnA, iCarriageReturnB]);
    
    iSeparator = strfind(tasks, strSeparator);
    iSeparatorProgramInstance = [];
    for cp = 1:parametersProgramInstances.nRunningProgamInstances 
        iSeparatorProgramInstance(cp, :) = iSeparator(iSeparator > iCarriageReturn(cp) & iSeparator < iCarriageReturn(cp + 1));
    end

    %%% Get PID
    for cp = 1:parametersProgramInstances.nRunningProgamInstances
        indexStart  = iSeparatorProgramInstance(cp, 1) + length(strSeparator);
        indexEnd    = iSeparatorProgramInstance(cp, 2) - 1;
        parametersProgramInstances.pid{cp} = tasks(indexStart:indexEnd);
    end
    
    %%% Get information about memory usage
    for cp = 1:parametersProgramInstances.nRunningProgamInstances
        indexStart  = iSeparatorProgramInstance(cp, 4) + length(strSeparator);
        indexEnd    = iSeparatorProgramInstance(cp, 5) - 2;
        parametersProgramInstances.memoryUsage(cp) = str2double(strtrim(tasks(indexStart:indexEnd)));
    end
    
    %%% Get information about CPU time
    for cp = 1:parametersProgramInstances.nRunningProgamInstances
        indexStart  = iSeparatorProgramInstance(cp, 7) + length(strSeparator);
        indexEnd    = iSeparatorProgramInstance(cp, 8) - 1;
        parametersProgramInstances.cpuTime{cp} = tasks(indexStart:indexEnd);
    end
    
    %%% Get information about window title
    for cp = 1:parametersProgramInstances.nRunningProgamInstances
        indexStart  = iSeparatorProgramInstance(cp, end) + length(strSeparator);
        indexEnd    = iCarriageReturn(cp + 1) - 2;
        parametersProgramInstances.windowTitle{cp} = tasks(indexStart:indexEnd);
    end
end


end