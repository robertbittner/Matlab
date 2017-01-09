function [structProjectDataSubFolders] = createProjectDataSubFoldersATWM1(strSubjectDataFolder)
%%%

global iStudy
global nrOfSessions

if isempty(nrOfSessions)
    nrOfSessions = 1;
end

hFunction = str2func(sprintf('defineProjectDataSubFolders%s', iStudy));
structProjectDataSubFolders = feval(hFunction, strSubjectDataFolder);

for cf = 1:structProjectDataSubFolders.nDataSubFolder
    if ~exist(structProjectDataSubFolders.aStrProjectDataSubFolder{cf}, 'dir')
        success = mkdir(structProjectDataSubFolders.aStrProjectDataSubFolder{cf});
        if success == 1
            fprintf('Creating subfolder %s\n', structProjectDataSubFolders.aStrProjectDataSubFolder{cf});
        else
            fprintf('Could not create subfolder %s\n', structProjectDataSubFolders.aStrProjectDataSubFolder{cf});
        end
    end
end
fprintf('\n');


end