function removeSpaceFromDicomFileNameATWM1(targetFolder);
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function renames DICOM Files

global iStudy;

iStudy = 'ATWM1';
extDicom = '.dcm';

strSpace = ' ';
strNoSpace = '';

targetFolder = 'D:\Daten\ATWM1\Single_Subject_Data\VW42LKU\';

aStrDicomFiles = dir(strcat(targetFolder, '*', extDicom));
nrOfDicomFiles = numel(aStrDicomFiles);
for cf = 1:nrOfDicomFiles
   %strDicomFileName = aStrDicomFiles(cf).name
   if ~isempty(strfind(aStrDicomFiles(cf).name, strSpace))
       strOldDicomFileName = aStrDicomFiles(cf).name;
       strNewDicomFileName = strrep(strOldDicomFileName, strSpace, strNoSpace);
       strPathOldDicomFile = fullfile(targetFolder, strOldDicomFileName);
       strPathNewDicomFile = fullfile(targetFolder, strNewDicomFileName);
       movefile(strPathOldDicomFile, strPathNewDicomFile)
   end
    
end


end