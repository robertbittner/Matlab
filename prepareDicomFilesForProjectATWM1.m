function [parametersProjectFiles, bAbortFunction] = prepareDicomFilesForProjectATWM1(folderDefinition, parametersProjectFiles, parametersMriSession)

global iStudy
global strSubject
global iSession

parametersDicomFiles = eval(['parametersDicomFiles', iStudy]);

%%% Determine the names of the DICOM files of the project
hFunction = str2func(sprintf('determineDicomFilesForProject%s', iStudy));
[aStrPathSourceFiles, strPathFirstSourceFile, bDicomFilesComplete] = feval(hFunction, folderDefinition, parametersProjectFiles.strCurrentProjectType, parametersProjectFiles.iDicomFileRun, parametersProjectFiles.nrOfDicomFilesForProject);

%%% Detect and add deviating DICOM file names
if bDicomFilesComplete
    bAbortFunction = false;
else
    bDicomFilesComplete = false;
    [aStrPathOriginalDicomFiles, bDicomFilesComplete] = determineDeviatingDicomFileNamesATWM1(parametersDicomFiles, parametersMriSession, folderDefinition.strDicomFilesSubFolderCurrentSession, bDicomFilesComplete);
    if ~bDicomFilesComplete
        bAbortFunction = true;
    end
    indDicomFileName = sprintf('%s-%04i', strSubject, parametersProjectFiles.iDicomFileRun);
    index = strfind(aStrPathOriginalDicomFiles, indDicomFileName);
    aStrPathSourceFiles = aStrPathOriginalDicomFiles(not(cellfun('isempty', index)));
end

%%% Copy DICOM files to project subfolder
aStrPathSourceFilesProjectSubfolder = strrep(aStrPathSourceFiles, folderDefinition.strDicomFilesSubFolderCurrentSession, folderDefinition.strCurrentProjectDataSubFolder);
parametersProjectFiles.strPathFirstSourceFile = aStrPathSourceFilesProjectSubfolder{1};
bAbortFunction = false;
success = [];
fprintf('Copying DICOM files to folder %s\n', folderDefinition.strCurrentProjectDataSubFolder);
for cdic = 1:parametersProjectFiles.nrOfDicomFilesForProject
    success(cdic) = copyfile(aStrPathSourceFiles{cdic}, aStrPathSourceFilesProjectSubfolder{cdic});
end
if sum(success) ~= parametersProjectFiles.nrOfDicomFilesForProject
    nfOfFilesNotCopied = parametersProjectFiles.nrOfDicomFilesForProject - sum(success);
    bAbortFunction = true;
    fprintf('Error!\n%i DICOM files could not be copied to folder %s\n', nfOfFilesNotCopied, folderDefinition.strCurrentProjectDataSubFolder);
else
    %%% Define path to all source files 
    parametersProjectFiles.aStrPathSourceFilesProjectSubfolder = aStrPathSourceFilesProjectSubfolder;
    fprintf('Copying DICOM files to folder %s complete!\n', folderDefinition.strCurrentProjectDataSubFolder);
end
if bAbortFunction
    return
end


end