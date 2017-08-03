function [bFileCreated] = createFmrFileATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersFunctionalMriSequence, parametersEpiDistortionCorrection, parametersProcessDuration)
%%% © 2016 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function creates a MosaicFMR project including a firstvol version
%%% of the same MosaicFMR


global iStudy
global strSubject
global bTestConfiguration


processDuration = parametersProcessDuration.fmrFileCreation;

[aStrFmrFile, aStrPathFmrFile] = determineFmrFileNameATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection);
[parametersProjectFiles] = prepareFirstVolFmrFileCreationATWM1(parametersFunctionalMriSequence, parametersProjectFiles);
for cf = 1:parametersProjectFiles.nrOfFmrFilesToBeCreated
    [parametersProjectFiles, strFmrFile, strPathFmrFile, nrOfVolumesFmrFile, nrVolumesToSkipFmrFile] = setFullRunAndFirstVolFmrParametersATWM1(parametersProjectFiles, parametersFunctionalMriSequence, aStrFmrFile, aStrPathFmrFile, cf);
    if ~exist(strPathFmrFile, 'file')
        %%% Create empty protocol file for event-related averaging for full
        %%% functional runs
        if parametersProjectFiles.bFunctionalRun && parametersProjectFiles.bFmrFileFullRun
            [strAvgPrtFile, strPathAvgPrtFile] = createEmptyPrtFileATWM1(parametersStudy, folderDefinition, parametersProjectFiles);
        end
        
        %%% Check compatibility of the currently installed version of BrainVoyager
        %%% and run BrainVoyager as a COM object
        hFunction = str2func(sprintf('runBrainVoyagerQX%s', iStudy));
        %hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
        [bvqx, parametersComProcess, parametersBrainVoyager, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
        if bIncompatibleBrainVoyagerVersion == true
            bFileCreated = false;
            return
        end
        
        %%% Open additional Matlab command window to terminate crashed BrainVoyager
        %%% COM objects
        hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
        matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
        
        try
            fprintf('Creating FMR for study: %s\t\tsubject: %s\t\trun: %i\t\tfile: %s\n', iStudy, strSubject, parametersProjectFiles.iRunCurrentProject, strFmrFile);
            fmr = bvqx.CreateProjectMosaicFMR(parametersFunctionalMriSequence.fileType, parametersProjectFiles.strPathFirstSourceFile, nrOfVolumesFmrFile, nrVolumesToSkipFmrFile, parametersFunctionalMriSequence.createAmr, parametersFunctionalMriSequence.nSlices, parametersFunctionalMriSequence.prefixStc, parametersFunctionalMriSequence.swapBytes, parametersFunctionalMriSequence.mosaicResX, parametersFunctionalMriSequence.mosaicResY, parametersFunctionalMriSequence.nBytes, folderDefinition.strCurrentProjectDataSubFolder, parametersFunctionalMriSequence.nVolumesInImage, parametersFunctionalMriSequence.resX, parametersFunctionalMriSequence.resY);
            fmr.TimeResolutionVerified = true;
            fmr.VoxelResolutionVerified = true;
            if parametersProjectFiles.bFunctionalRun && parametersProjectFiles.bFmrFileFullRun
                [fmr] = linkPrtToFmrFileATWM1(fmr, strFmrFile, strPathAvgPrtFile, strAvgPrtFile);
            end
            fmr.SaveAs(strPathFmrFile);
            fmr.Close();
            [strPosFile, strPathPosFile] = renamePosFileATWM1(folderDefinition, parametersStudy, parametersProjectFiles);
            fprintf('File %s was created.\n\n', strFmrFile);
            bvqx.Exit
            bFileCreated = true;
        catch
            fprintf('Error!\nFile %s could not be created!\n\n', strFmrFile);
            bFileCreated = false;
        end
        
        hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
        feval(hFunction, matlabCommandWindowProcessId, processDuration);
        
    else
        fprintf('File %s already exists!\n\n', strFmrFile);
        bFileCreated = true;
    end
end

end


function [parametersProjectFiles] = prepareFirstVolFmrFileCreationATWM1(parametersFunctionalMriSequence, parametersProjectFiles)
if ~parametersFunctionalMriSequence.bCreateFirstVol
    parametersProjectFiles.nrOfFmrFilesToBeCreated = 1;
else
    parametersProjectFiles.nrOfFmrFilesToBeCreated = 2;
end
parametersProjectFiles.aBooleanFmrFileFullRun  = {
                                                    true
                                                    false
                                                    };


end


function [parametersProjectFiles, strFmrFile, strPathFmrFile, nrOfVolumesFmrFile, nrVolumesToSkipFmrFile] = setFullRunAndFirstVolFmrParametersATWM1(parametersProjectFiles, parametersFunctionalMriSequence, aStrFmrFile, aStrPathFmrFile, cf)
%%% Define parameters which differ between full-run and firstvol fmr
parametersProjectFiles.bFmrFileFullRun = parametersProjectFiles.aBooleanFmrFileFullRun{cf};

strFmrFile      = aStrFmrFile{cf};
strPathFmrFile  = aStrPathFmrFile{cf};

if parametersProjectFiles.bFmrFileFullRun
    nrOfVolumesFmrFile = parametersFunctionalMriSequence.nVolumes
else
    nrOfVolumesFmrFile = parametersFunctionalMriSequence.nVolumesFirstVol;
end

if parametersProjectFiles.bFmrFileFullRun
    nrVolumesToSkipFmrFile = parametersFunctionalMriSequence.nVolumesToSkip;
else
    nrVolumesToSkipFmrFile = parametersFunctionalMriSequence.nVolumesToSkipFirstVol;
end


end


function [strPosFile, strPathPosFile] = renamePosFileATWM1(folderDefinition, parametersStudy, parametersProjectFiles)
%%% Rename POS file, which is automatically created during creation of FMR
%%% but does not receive the appropriate name automatically.
%%% POS files appear to be obsolete, position information is contained
%%% in the VMR and FMR files.

global iStudy
global strSubject

if parametersProjectFiles.nrOfTotalRuns == 1
    strPosFile = sprintf('%s_%s_%s_%s%s', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, upper(parametersProjectFiles.strFunctionalProject), parametersProjectFiles.extPositionFile);
else
    strPosFile = sprintf('%s_%s_%s_%s%i_%s%s', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, parametersProjectFiles.iRunCurrentProject, upper(parametersProjectFiles.strFunctionalProject), parametersProjectFiles.extPositionFile);
end
if ~parametersProjectFiles.bFmrFileFullRun
    strPosFile = strrep(strPosFile, parametersProjectFiles.extPositionFile, ['_', parametersProjectFiles.strFirstVolume, parametersProjectFiles.extPositionFile]);
end

strPathPosFile = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strPosFile);
strucFiles = dir([folderDefinition.strCurrentProjectDataSubFolder, ['*', parametersProjectFiles.extPositionFile]]);
nrOfPosFiles = numel(strucFiles);
if ~exist(strPathPosFile, 'file') || nrOfPosFiles > 1
    if nrOfPosFiles ~= 0
        [indexNewest, indexNewest] = sort([strucFiles.datenum],'descend');
        strNewestPosFile = strucFiles(indexNewest(1)).name;
        strPathNewestPosFile = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strNewestPosFile);
        movefile(strPathNewestPosFile, strPathPosFile);
        if nrOfPosFiles > 1
            indexOldFiles = indexNewest(2:end);
            for cf = 1:numel(indexOldFiles)
                delete(fullfile(folderDefinition.strCurrentProjectDataSubFolder, strucFiles(indexOldFiles(cf)).name));
            end
        end
    end
end


end