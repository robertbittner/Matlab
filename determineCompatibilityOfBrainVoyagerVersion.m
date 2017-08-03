function [parametersBrainVoyager, bIncompatibleBrainVoyagerVersion] = determineCompatibilityOfBrainVoyagerVersion(parametersBrainVoyager, bv)
%%% © 2017 Robert Bittner
%%% This function determines whether the currently called version of
%%% BrainVoyager is compatible with the study scripts

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
else
    bIncompatibleBrainVoyagerVersion = false;
end

if bv.Is64Bits == true
    strBit = parametersBrainVoyager.str64Bits;
else
    strBit = parametersBrainVoyager.str32Bits;
end
parametersBrainVoyager.strBrainVoyagerVersion = sprintf('%i.%i.%i - Build %i - %s', bv.VersionMajor, bv.VersionMinor, bv.VersionPatch, bv.BuildNumber, strBit);


end
