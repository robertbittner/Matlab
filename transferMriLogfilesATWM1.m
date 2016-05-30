function transferMriLogfilesATWM1();
clear all 
clc

global iStudy

iStudy = 'ATWM1';

%folderDefinition = folderDefinitionATWM1;

folderDefinition.BEOSRV1T = '\\BEOSRV1-T\';
strFolder = strcat(folderDefinition.BEOSRV1T, 'projects\');

%folderDefinition.BEOSRV1T = '\\KPSY-526-054\'
%strFolder = strcat(folderDefinition.BEOSRV1T);

tset = mfilename

try
    cd(strFolder)
catch
    strMessage = sprintf('Error! Server %s cannot be accessed!\nPlease log on to the sever manually and restart function.', folderDefinition.BEOSRV1T)
    return
end

%return

addpath(strcat(folderDefinition.BEOSRV1T, 'projects\ATWM1\Study_Parameters'));
addpath(strcat(folderDefinition.BEOSRV1T, 'projects\ATWM1\Matlab'));

%bSeverCanBeAccessed = checkSeverAccessATWM1(folderDefinition)



strLocalFolderMriLogfiles           = strcat('D:\presentation\Bittner\', iStudy, '\Logfiles\');
strDataTransferFolderMriLogfiles    = strcat('\\', folderDefinition.BEOSRV1T, '\projects\', iStudy, '\Data_Transfer\MRI\Logfiles\');


iSubject = 'VW42LKU';

aStrLogfiles = {
    sprintf('%s-%s_Working_Memory_MRI_Nonsalient_Cued_Run1.log', iSubject, iStudy);
    sprintf('%s-%s_Working_Memory_MRI_Nonsalient_Uncued_Run1.log', iSubject, iStudy);
    sprintf('%s-%s_Working_Memory_MRI_Salient_Cued_Run1.log', iSubject, iStudy);
    sprintf('%s-%s_Working_Memory_MRI_Salient_Uncued_Run1.log', iSubject, iStudy);
    sprintf('%s-%s_LOCALIZER_MRI.log', iSubject, iStudy);
    };

nrOfLogfiles = numel(aStrLogfiles);

for clf = 1:nrOfLogfiles
    aStrSourcePathLogfiles{clf} = strcat(strLocalFolderMriLogfiles, aStrLogfiles{clf});    
    aStrTargetPathLogfiles{clf} = strcat(strDataTransferFolderMriLogfiles, aStrLogfiles{clf});

end


for clf = 1:nrOfLogfiles
    if exist(aStrSourcePathLogfiles{clf}, 'file')
       [success(clf)] = copyfile(aStrSourcePathLogfiles{clf}, aStrTargetPathLogfiles{clf}, 'f');
    end
end

if isequal(nrOfLogfiles, sum(success))
    strMessage = sprintf('Successful transfer of all logfiles for subject %s', iSubject);
    disp(strMessage);
end




end