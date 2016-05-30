function evaluateParadigm_WM_ATWM1();

clear all
clc

parametersParadigm = parametersParadigm_WM_MRI_ATWM1;

%%% CHange definition
parametersParadigm.TR = 2000;

strFolderScenarioFiles = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\Scenario_Files_WM\';
strEvaluationFolder = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\';
%strScenarioFile = 'ATWM1_Working_Memory_MRI_Nonsalient_Cued_Run1.sce';

aStrScenarioFiles = {
    'ATWM1_Working_Memory_MRI_Nonsalient_Cued_Run1.sce'
    'ATWM1_Working_Memory_MRI_Nonsalient_Uncued_Run1.sce'
    };

for cf = 1:numel(aStrScenarioFiles)
    pathScenarioFile = strcat(strFolderScenarioFiles, aStrScenarioFiles{cf});
    parametersParadigmRun{cf} = readScenarioFile_WM_ATWM1(parametersParadigm, pathScenarioFile)
end


end