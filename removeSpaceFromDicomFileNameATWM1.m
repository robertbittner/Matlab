function removeSpaceFromDicomFileNameATWM1(folderDefinition)
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function renames DICOM Files

global iStudy;

iStudy = 'ATWM1';
%extDicom = '.dcm';

parametersDicomFiles = eval(['parametersDicomFiles', iStudy]);


strSpace = ' ';
strNoSpace = '';

%strTargetFolder = 'D:\Daten\ATWM1\Single_Subject_Data\CONT\VE85QGL\';

aStrDicomFiles = dir(strcat(folderDefinition.strDicomFilesSubFolderCurrentSession, '*', parametersDicomFiles.extDicomFile ));
nrOfDicomFiles = numel(aStrDicomFiles);
for cf = 1:nrOfDicomFiles
   if ~isempty(strfind(aStrDicomFiles(cf).name, strSpace))
       strOldDicomFileName = aStrDicomFiles(cf).name;
       strNewDicomFileName = strrep(strOldDicomFileName, strSpace, strNoSpace);
       strPathOldDicomFile = fullfile(folderDefinition.strDicomFilesSubFolderCurrentSession, strOldDicomFileName);
       strPathNewDicomFile = fullfile(folderDefinition.strDicomFilesSubFolderCurrentSession, strNewDicomFileName);
       movefile(strPathOldDicomFile, strPathNewDicomFile)
   end
end


end