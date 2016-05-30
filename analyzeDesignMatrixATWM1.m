function efficiency = analyzeDesignMatrixATWM1(pathSdmFile);
%%% Original formula:
%%%
%%% trace( C'*inv(X'X)*C )^-1
%%%
%%% taken from: http://imaging.mrc-cbu.cam.ac.uk/imaging/DesignEfficiency#Mathematics_.28statistics.29

contrast = [3 -1 -1 -1; -1 3 -1 -1; -1 -1 3 -1; -1 -1 -1 3];

sdm = xff(pathSdmFile);

designMatrix = sdm.SDMMatrix;

efficiency = trace( contrast'*inv(designMatrix'*designMatrix)*contrast )^-1;
sdm.ClearObject;

end