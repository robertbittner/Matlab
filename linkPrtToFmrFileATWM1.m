function [fmr] = linkPrtToFmrFileATWM1(fmr, strFmrFile, strPathAvgPrtFile, strAvgPrtFile)

fprintf('Linking PRT: %s\t\t to FMR: %s\t\t\n', strAvgPrtFile, strFmrFile);
try
    fmr.LinkStimulationProtocol(strPathAvgPrtFile)
catch
    fprintf('Error!\PRT %s could not be linked to FMR %s!\n\n', strAvgPrtFile, strFmrFile);
end


end