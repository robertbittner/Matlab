function [bvqx, parametersComProcess, parametersBrainVoyager, bIncompatibleBrainVoyagerVersion] = runBrainVoyagerQXATWM1()
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface and checks
%%% whether the currently installed version is compatible with the study
%%% scripts

global iStudy

parametersBrainVoyager = eval(['parametersBrainVoyagerQX', iStudy]);

bvqx = actxserver(parametersBrainVoyager.strBrainVoyagerProgId);

[parametersBrainVoyager, bIncompatibleBrainVoyagerVersion] = determineCompatibilityOfBrainVoyagerVersion(parametersBrainVoyager, bvqx);

if bIncompatibleBrainVoyagerVersion
    parametersComProcess = [];
    bvqx.Exit;
    fprintf('\nERROR:\nCurrently used version of BrainVoyager (%s)\nis incompatible with scripts of study %s!\nAborting function.\n\n', parametersBrainVoyager.strBrainVoyagerVersion, iStudy);
    return
else
    parametersComProcess = detectBrainVoyagerComProcessATWM1();
end


end