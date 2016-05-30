function terminateBrainVoyagerATWM1(processDuration, bFunctionCalledByAdditionalMatlabInstance, varargin);
%%% varargin is used to receive the ASCII code for iStudy
global iStudy

if numel(varargin) > 1 && iscell(varargin)
    %%% Decode iStudy variable from ASCII code
    nVarargs = length(varargin);
    nCodeLetters = varargin{1};
    for cv = 2:nVarargs
        asciiCodeStudy(cv - 1) = varargin{cv};
    end
    iStudy = char(asciiCodeStudy);
end

parametersBrainVoyager = eval(sprintf('parametersBrainVoyager%s', iStudy));

if ~exist('parametersBrainVoyagerProgramInstances', 'var')
    parametersBrainVoyagerProgramInstances = [];
end

parametersProgramInstances = detectActiveProgramInstancesATWM1(parametersBrainVoyager.strBrainVoyagerExecutable);

%%% Pause for variable duration depending on the command(s) processed by
%%% BrainVoyager to ensure they can be finished properly
pause(processDuration)

for cp = 1:parametersProgramInstances.nRunningProgamInstances
    system(['taskkill /f /pid ' parametersProgramInstances.pid{cp}]);
end

if bFunctionCalledByAdditionalMatlabInstance == true
    quit force
end


end



