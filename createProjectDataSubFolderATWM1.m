function createProjectDataSubFolderATWM1(strSubjectDataFolder);
%%%

clear all
clc

global iStudy
global iSubject
global iGroup

iStudy = 'ATWM1';
iSubject = 'Test_001';

folderDefinition    = eval(['folderDefinition', iStudy]);
parametersGroups    = eval(['parametersGroups', iStudy]);

iGroup = parametersGroups.strShortControls;

strSubjectDataFolder = strcat(folderDefinition.singleSubjectData, iGroup, '\', iSubject, '\');

hFunction = str2func(sprintf('defineProjectDataSubFolder%s', iStudy));
structProjectDataSubFolder = feval(hFunction, strSubjectDataFolder);

for cf = 1:structProjectDataSubFolder.nDataSubFolder
    if ~exist(structProjectDataSubFolder.aStrProjectDataSubFolder{cf}, 'dir')
        success = mkdir(structProjectDataSubFolder.aStrProjectDataSubFolder{cf});
        if success == 0
            strMessage = sprintf('Could not create folder %s', structProjectDataSubFolder.aStrProjectDataSubFolder{cf});
            disp(strMessage);
        end
    end
end


end