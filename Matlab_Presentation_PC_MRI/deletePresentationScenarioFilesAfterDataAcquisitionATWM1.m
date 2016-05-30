function deletePresentationScenarioFilesAfterDataAcquisitionATWM1(folderDefinition, strSubject)
global iStudy

strSubjectScenarioFilesFolder = sprintf('%s_%s_Presentation_Scenario_Files', strSubject, iStudy);
strPathSubjectScenarioFilesFolder = strcat(folderDefinition.dataAcquisition, strSubjectScenarioFilesFolder, '\');
if exist(strPathSubjectScenarioFilesFolder, 'dir')
    rmdir(strPathSubjectScenarioFilesFolder, 's');
else
    strMessage = sprintf('Folder %s not found.\nFolder was not deleted.', strPathSubjectScenarioFilesFolder);
    disp(strMessage);
end


end