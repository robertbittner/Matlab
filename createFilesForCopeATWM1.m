function createFilesForCopeATWM1 ();
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function creates GRE field mapping data as fmr projects.
%%%
%%% The variables 'iStudy' and 'iSubject' must be declared as
%%% global variables in functions calling this function!

global iStudy;
%global indexMethod;
%global indexExperiment;
global iSubject;

iStudy = 'ATWM1';
iSubject = 'ERRA90';

folder = 'D:\Daten\ATWM1\Single_Subject_Data\Pilot_Scans\ERRA90\';

%%% Check compatibility of currently installed version of BrainVoyager and
%%% start software
[bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = runBrainVoyagerATWM1();
if bIncompatibleBrainVoyagerVersion == true
    return
end



%%{
folderDefinition                    = eval(['folderDefinition', iStudy]);
%parametersParadigm = eval(['parametersParadigm', iStudy, '_', indexMethod, '_', indexExperiment]);
%parametersCopeSequence = eval(['parametersCopeSequence', iStudy]);
%parametersCopeSequence = eval(['parametersCopeSequence', iStudy]);
%parametersCopeSequence              = eval(['parametersCopeSequence', iStudy]);
%parametersFunctionalMriSequence_WM = eval(['parametersFunctionalMriSequence_WM', iStudy]);%ATWM1
parametersFunctionalMriSequence_WM = parametersFunctionalMriSequence_WM_ATWM1
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', iStudy]);
%parametersMriScan = eval([iSubject, iStudy, 'ParametersMriScan']);


parametersParadigm.nRuns = 3;

parametersParadigm.strParadigmType = 'WM';
strProjectType = 'fmr';

parametersMriScan.fileIndexFmr = [
    4
    6
    8
    ];



parametersMriScan.fileIndexInversePhaseEncoding = [
    3
    5
    7
    ];

parametersMriScan.fileIndexStandardPhaseEncoding = parametersMriScan.fileIndexFmr;

aFileIndexSequencesForCope = {
    parametersMriScan.fileIndexStandardPhaseEncoding
    parametersMriScan.fileIndexInversePhaseEncoding
    };

parametersEpiDistortionCorrection.aStrPhaseEncodingDirections       = {
                                                                        parametersEpiDistortionCorrection.strStandardPhaseEncodingDirection
                                                                        parametersEpiDistortionCorrection.strInversePhaseEncodingDirection
                                                                        };
                                                                    
aNrOfDicomFilesForProject = [
    270
    10
    270
    10
    270
    10
    ];
    
                                                                    
aStrPhaseEncodingDirections = parametersEpiDistortionCorrection.aStrPhaseEncodingDirections;
                                                                    
%%% Check, whether parameters used for file creation match
if numel(aFileIndexSequencesForCope) ~= numel(aStrPhaseEncodingDirections)
    strMessage = sprintf('Parameters for creation of files for COPE do not match!\nAborting function.');
    disp(strMessage);
    return
end

rawDataPath = folder;
projectDataPath = rawDataPath;
folderDefinition.strProjectDataSubFolder = folder;


%%% Add parameters for additional sequences
parametersFunctionalMriSequence                 = parametersFunctionalMriSequence_WM;

%%% Adjust parameters defining the number of volumes for the COPE method
parametersFunctionalMriSequence.nVolumes        = parametersEpiDistortionCorrection.nVolumes; %                         = 5;%270;
parametersFunctionalMriSequence.nVolumesToSkip  = parametersEpiDistortionCorrection.nVolumesToSkip;
parametersFunctionalMriSequence.nVolumesFmr     = parametersEpiDistortionCorrection.nVolumesFmr;                       %= parametersEpiDistortionCorrection.nVolumes-parametersEpiDistortionCorrection.nVolumesToSkip;

%strPathCopeSubfolder = strcat(folder, 'COPE', '\');
%mkdir(strPathCopeSubfolder);
for iRun = 1:parametersParadigm.nRuns
    for cf = 1:numel(aFileIndexSequencesForCope)
        
        strPhaseEncodingDirection = parametersEpiDistortionCorrection.aStrPhaseEncodingDirections{cf};
        
        %%% Determine the first source file
        %iDicomFile = aFileIndexSequencesForCope{cf}(iRun);
        iDicomFileRun = aFileIndexSequencesForCope{cf}(iRun);
        nDicomFilesForProject = aNrOfDicomFilesForProject(cf);
        hFunction = str2func(sprintf('determineDicomFilesForProject%s', iStudy));
        [aStrPathSourceFile, strPathFirstSourceFile, bAbortFunction] = feval(hFunction, folderDefinition, parametersMriScan, strProjectType, iDicomFileRun, nDicomFilesForProject);
        pathFirstSourceFile = strPathFirstSourceFile;%strcat(rawDataPath, strFirstSourceFile);
        if ~exist(pathFirstSourceFile, 'file')
            strMessage = sprintf('%s could not be found!\nAborting function.', firstSourceFile);
            disp(strMessage);
            return
        end
        
        strFmrFile = sprintf('%s_%s_%s_%s_%s_run%i.fmr', iSubject, iStudy, parametersParadigm.strParadigmType, parametersEpiDistortionCorrection.strMethod, strPhaseEncodingDirection, iRun);
        pathFmrFile = strcat(projectDataPath, strFmrFile);

        fmr = bvqx.CreateProjectMosaicFMR(parametersFunctionalMriSequence.fileType, pathFirstSourceFile, parametersFunctionalMriSequence.nVolumes, parametersFunctionalMriSequence.nVolumesToSkip, parametersFunctionalMriSequence.createAmr, parametersFunctionalMriSequence.nSlices, parametersFunctionalMriSequence.prefixStc, parametersFunctionalMriSequence.swapBytes, parametersFunctionalMriSequence.mosaicResX, parametersFunctionalMriSequence.mosaicResY, parametersFunctionalMriSequence.nBytes, projectDataPath, parametersFunctionalMriSequence.nVolumesInImage, parametersFunctionalMriSequence.resX, parametersFunctionalMriSequence.resY);
        fmr.TimeResolutionVerified = true;
        fmr.VoxelResolutionVerified = true;
        fmr.SaveAs(strFmrFile);
        fmr.Close();
    end
end

parametersFunctionalMriSequence                 = parametersFunctionalMriSequence_WM;
for iRun = 1:parametersParadigm.nRuns
    strFmrFile = sprintf('%s_%s_%s_run%i.fmr', iSubject, iStudy, parametersParadigm.strParadigmType, iRun);
    pathFmrFile = strcat(projectDataPath, strFmrFile);
    
    fmr = bvqx.CreateProjectMosaicFMR(parametersFunctionalMriSequence.fileType, pathFirstSourceFile, parametersFunctionalMriSequence.nVolumes, parametersFunctionalMriSequence.nVolumesToSkip, parametersFunctionalMriSequence.createAmr, parametersFunctionalMriSequence.nSlices, parametersFunctionalMriSequence.prefixStc, parametersFunctionalMriSequence.swapBytes, parametersFunctionalMriSequence.mosaicResX, parametersFunctionalMriSequence.mosaicResY, parametersFunctionalMriSequence.nBytes, projectDataPath, parametersFunctionalMriSequence.nVolumesInImage, parametersFunctionalMriSequence.resX, parametersFunctionalMriSequence.resY);
    fmr.TimeResolutionVerified = true;
    fmr.VoxelResolutionVerified = true;
    fmr.SaveAs(strFmrFile);
    fmr.Close();
end

%}
bvqx.Exit;

end
        