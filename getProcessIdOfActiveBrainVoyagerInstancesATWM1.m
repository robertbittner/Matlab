function parametersProcessId = getProcessIdOfActiveBrainVoyagerInstancesATWM1();
global iStudy

parametersBrainVoyager = eval(['parametersBrainVoyager', iStudy]);
strProgramExecutable = parametersBrainVoyager.strBrainVoyagerExecutable;

strSeparator = '","';

%%% Search tasklist for instances of specified program
strCommand = sprintf('tasklist /v /fo "CSV" /fi "imagename eq %s"', strProgramExecutable);
[~,tasks] = system(strCommand);

iRunningProgramInstances = strfind(tasks, strProgramExecutable);
parametersProcessId.nRunningProgamInstances = numel(iRunningProgramInstances);

if parametersProcessId.nRunningProgamInstances == 0
    parametersProcessId.pid          = [];
    parametersProcessId.memoryUsage  = [];
    parametersProcessId.cpuTime      = [];
    parametersProcessId.windowTitle  = [];
else
    iCarriageReturnA = find(tasks == 10); % Unix & PC
    iCarriageReturnB = find(tasks == 13); % Mac & PC
    iCarriageReturn = sort([iCarriageReturnA, iCarriageReturnB]);
    
    iSeparator = strfind(tasks, strSeparator);
    iSeparatorProgramInstance = [];
    for cp = 1:parametersProcessId.nRunningProgamInstances 
        iSeparatorProgramInstance(cp, :) = iSeparator(iSeparator > iCarriageReturn(cp) & iSeparator < iCarriageReturn(cp + 1));
    end

    %%% Get PID
    for cp = 1:parametersProcessId.nRunningProgamInstances
        indexStart  = iSeparatorProgramInstance(cp, 1) + length(strSeparator);
        indexEnd    = iSeparatorProgramInstance(cp, 2) - 1;
        parametersProcessId.pid{cp} = tasks(indexStart:indexEnd);
    end
end


end