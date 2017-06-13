function [bv, parametersComProcess, bIncompatibleBrainVoyagerVersion] = runBrainVoyagerATWM1()
%%% © 2017 Robert Bittner
%%% Written for BrainVoyager 20.4
%%% This function calls BrainVoyager 20 using the COM interface and checks
%%% whether the currently installed version is compatible with the study
%%% scripts

global iStudy

parametersBrainVoyager = eval(['parametersBrainVoyager', iStudy]);

bIncompatibleBrainVoyagerVersion = false;
bv = actxserver(parametersBrainVoyager.strBrainVoyagerProgId);

if bv.VersionMajor < parametersBrainVoyager.iVersionMajor
    bIncompatibleBrainVoyagerVersion = true;
elseif bv.VersionMinor < parametersBrainVoyager.iVersionMinor
    bIncompatibleBrainVoyagerVersion = true;
elseif bv.VersionPatch < parametersBrainVoyager.iVersionPatch
    bIncompatibleBrainVoyagerVersion = true;
elseif bv.BuildNumber < parametersBrainVoyager.iBuildNumber
    bIncompatibleBrainVoyagerVersion = true;
elseif bv.Is64Bits ~= parametersBrainVoyager.bIs64Bits
    bIncompatibleBrainVoyagerVersion = true;
end

if bv.Is64Bits == true
    strBit = parametersBrainVoyager.str64Bits;
else
    strBit = parametersBrainVoyager.str32Bits;
end
strBrainVoyagerVersion = sprintf('%i.%i.%i - Build %i - %s', bv.VersionMajor, bv.VersionMinor, bv.VersionPatch, bv.BuildNumber, strBit);

if bIncompatibleBrainVoyagerVersion
    parametersComProcess = [];
    bv.Exit;
    fprintf('\nERROR:\nCurrently used version of %s %s\nis incompatible with scripts of study %s!\nAborting function.\n\n', parametersBrainVoyager.strBrainVoyager, strBrainVoyagerVersion, iStudy);
    return
else
    fprintf('Running %s %s\n', parametersBrainVoyager.strBrainVoyager, strBrainVoyagerVersion);
    parametersComProcess = detectBrainVoyagerComProcessATWM1();
end

end