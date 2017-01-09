function [bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = runBrainVoyagerATWM1()
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface and checks
%%% whether the currently installed version is compatible with the study
%%% scripts

global iStudy

parametersBrainVoyager = eval(['parametersBrainVoyager', iStudy]);

bIncompatibleBrainVoyagerVersion = false;
bvqx = actxserver(parametersBrainVoyager.strBrainVoyagerProgId);

if bvqx.VersionMajor < parametersBrainVoyager.iVersionMajor
    bIncompatibleBrainVoyagerVersion = true;
elseif bvqx.VersionMinor < parametersBrainVoyager.iVersionMinor
    bIncompatibleBrainVoyagerVersion = true;
elseif bvqx.BuildNumber < parametersBrainVoyager.iBuildNumber
    bIncompatibleBrainVoyagerVersion = true;
elseif bvqx.Is64Bits ~= parametersBrainVoyager.bIs64Bits
    bIncompatibleBrainVoyagerVersion = true;
end

if bvqx.Is64Bits == true
    strBit = parametersBrainVoyager.str64Bits;
else
    strBit = parametersBrainVoyager.str32Bits;
end
strBrainVoyagerVersion = sprintf('Version %i.%i - Build %i - %s', bvqx.VersionMajor, bvqx.VersionMinor, bvqx.BuildNumber, strBit);

if bIncompatibleBrainVoyagerVersion
    parametersComProcess = [];
    bvqx.Exit;
    fprintf('\nERROR:\nCurrently used version of BrainVoyager (%s)\nis incompatible with scripts of study %s!\nAborting function.\n\n', strBrainVoyagerVersion, iStudy);
    return
else
    parametersComProcess = detectBrainVoyagerComProcessATWM1();
end


end