function terminateBrainVoyagerComProcessATWM1(processId, processDuration, bFunctionCalledByAdditionalMatlabInstance, varargin)
%%% varargin is used to receive the ASCII code for iStudy
global iStudy

processId = num2str(processId);

if numel(varargin) > 1 && iscell(varargin)
    %%% Decode iStudy variable from ASCII code
    nVarargs = length(varargin);
    nCodeLetters = varargin{1};
    for cv = 2:nVarargs
        asciiCodeStudy(cv - 1) = varargin{cv};
    end
    iStudy = char(asciiCodeStudy);
end

%%% Pause for variable duration depending on the command(s) processed by
%%% BrainVoyager to ensure they can be finished properly
pause(processDuration)

%%% Get updated information about BrainVoyager proce
hFunction = str2func(sprintf('getProcessIdOfActiveBrainVoyagerInstances%s', iStudy));
parametersProcessId = feval(hFunction);

for cp = 1:parametersProcessId.nRunningProgamInstances
    %%% Verify that selected COM process is still active
    if strcmp(processId, parametersProcessId.pid{cp})
        %%% Kill COM process
        system(['taskkill /f /pid ' processId])
    end
end
if bFunctionCalledByAdditionalMatlabInstance == true
    quit force
end


end
