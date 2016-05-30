function [aStrPathCreatedFiles, bAllFilesCreated, bIncompatibleBrainVoyagerVersion] = createProjectFilesDuringDataTransferATWM1(folderDefinition, aStrPathCreatedFiles, bCreateProjectFiles, bAllFilesCreated, bIncompatibleBrainVoyagerVersion);

global iStudy
global iSubject

%%% Remove!
%%{
iStudy = 'ATWM1';
iSubject = 'PAT01';
bIncompatibleBrainVoyagerVersion = false;

maximumNumberOfRuns = 12;
bAllFilesCreated(1:maximumNumberOfRuns) = 0;

aStrPathCreatedFiles = {}
folderDefinition            = eval(['folderDefinition', iStudy]);

%}

%%% Update all files to ensure that the latest version is read (e.g.
%%% parametersMriScan
rehash

if bCreateProjectFiles == false
    return
end

parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersDicomFileTransfer = eval(['parametersDicomFileTransfer', iStudy]);
parametersMriScan           = eval([iSubject, iStudy, 'ParametersMriScan']);



for fileCreation = 1
    if bIncompatibleBrainVoyagerVersion == false
        
        %{
        %%% Create VMR projects
        nVmrProjects = numel(parametersMriScan.fileIndexVmr);
        for cp = 1:nVmrProjects
            indexProject = parametersMriScan.fileIndexVmr(cp);
            if ~isempty(indexProject) && bAllFilesCreated(indexProject) ~= 1
                try
                    [strPathVmrFile, bFileCreated, bIncompatibleBrainVoyagerVersion] = createVmrFilesATWM1(indexProject);
                    aStrPathCreatedFiles{indexProject} = strPathVmrFile;
                catch
                    
                end
                bAllFilesCreated(indexProject) = bFileCreated
                
                if bIncompatibleBrainVoyagerVersion == true
                    break
                end
            end
        end
        %}
        
        %%{
        %%% Create FMR projects
        nFmrProjects = numel(parametersMriScan.fileIndexFmr);
        for cp = 1:nFmrProjects
            indexProject = parametersMriScan.fileIndexFmr(cp);
            if ~isempty(indexProject) && bAllFilesCreated(indexProject) ~= 1
                try
                    [strPathFmrFile, bFileCreated, bIncompatibleBrainVoyagerVersion] = createFmrFilesATWM1(indexProject);
                    aStrPathCreatedFiles{indexProject} = strPathFmrFile;
                catch
                    
                end
                bAllFilesCreated(indexProject) = bFileCreated;
                
                if bIncompatibleBrainVoyagerVersion == true
                    break
                end
            end
        end
        %}
        
        %%{
        %%% Create FMR projects used for EPI distortion correction
        strFunctional
        nCopeFmrProjects = numel(parametersMriScan.fileIndexCopeFmr);
        for cp = 1:nCopeFmrProjects
            indexProject = parametersMriScan.fileIndexCopeFmr(cp);
            if ~isempty(indexProject) && bAllFilesCreated(indexProject) ~= 1
                try
                    %%%
                    createFilesForCopeATWM1
                    %%%
                    [strPathCopeFmrFile, bFileCreated, bIncompatibleBrainVoyagerVersion] = createFmrFilesATWM1(indexProject);
                    %%%
                    
                    aStrPathCreatedFiles{indexProject} = strPathCopeFmrFile;
                catch
                    
                end
                bAllFilesCreated(indexProject) = bFileCreated;
                
                if bIncompatibleBrainVoyagerVersion == true
                    break
                end
            end
        end
        %}
    end
end

test = aStrPathCreatedFiles
