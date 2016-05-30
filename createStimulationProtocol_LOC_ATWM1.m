function createStimulationProtocol_LOC_ATWM1();
%%% This function creates stimulation protocols
%%% Written for BVQX 2.8.4

clear all
clc

%%% Define the study
global iStudy;
%global indexMethod;
%global indexExperiment;
global iSubject;
%global iDataSource
%global fileNameOfPreprocessedFmrArray;

iStudy = 'ATWM1';
%experimentNo = 1;
%parametersStudy = eval(['parametersStudy', iStudy]);
%parametersStudy.experimentNumber = experimentNo;

%indexMethod = parametersStudy.indexMRI;
%indexExperiment = [parametersStudy.indexExperiment, num2str(experimentNo)];

indexCorrectTrial = 1;
indexIncorrectTrial = 0;
indexMissingAnswer = -1;

indexConditionMerged = 'combined_cond';

indexCorrectTrials = 'corr_trials';

strCorrect      = 'correct';
strIncorrect    = 'incorrect';
aStrAccuracy = {
    strCorrect
    strIncorrect
    };
nResponseTypes = length(aStrAccuracy);
strLocalizer = 'LOC';


parametersStimulationProtocol = parametersStimulationProtocolATWM1;

%strFolderScenarioFiles = 'D:\Forschung\Projekte\ATWM1\Paradigma\ATWM1_Paradigm_MRI_07.12.15\ATWM1_Localizer_MRI\';
strFolderScenarioFiles = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\Scenario_Files\';

strEvaluationFolder = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\';

%%% Define dummy files necessary for prt and sdm creation
strVmrInTalFile = 'TEST_BRAIN_IIHC_aTAL.vmr';
pathVmrInTalFile = strcat(strEvaluationFolder, strVmrInTalFile);
strVtcFile = 'TEST_176_vol.vtc';
pathVtcFile = strcat(strEvaluationFolder, strVtcFile);


%%% Detect presentation scenario files
aStrucFiles = dir(strFolderScenarioFiles);
aStrucFiles = aStrucFiles(3:end);
nScenarioFiles = numel(aStrucFiles);

%nScenarioFiles = 1


for csf = 1:nScenarioFiles
    strScenarioFile = aStrucFiles(csf).name;

    pathScenarioFile = strcat(strFolderScenarioFiles, strScenarioFile);
    
    
    parametersParadigm_LOC = readScenarioFileLocalizerATWM1(pathScenarioFile);
    aConditions = parametersParadigm_LOC.aConditions;
    
  
    for ca = 1:parametersParadigm_LOC.nAnalyses
        %strSubject = 'TEST';
        strPrtFile = sprintf('%s_%s_%s_%s.prt', strScenarioFile, iStudy, strLocalizer, aConditions{ca, 4});%sprintf('%s_%s_%s%i_%s_%s_stim.prt', iSubject, iStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, indexCorrectTrials);
        pathPrtFile{csf, ca} = strcat(strEvaluationFolder, strPrtFile);
        strMessage = sprintf('Creating protocol %s', pathPrtFile{csf, ca});
        disp(strMessage);
        
        %%{
        bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

        doc = bvqx.OpenDocument(pathVmrInTalFile);
        doc.LinkVTC(pathVtcFile);
        doc.ClearStimulationProtocol();
        doc.StimulationProtocolExperimentName = iStudy;
        doc.StimulationProtocolResolution = parametersStimulationProtocol.iResolution;
        
        nConditionsCurrentProtocol = aConditions{ca, 2};
        for cc = 1:nConditionsCurrentProtocol
            strCondition = aConditions{ca, 1}{cc};
            
            %%% Add conditions to protocol
            doc.AddCondition(strCondition);
            
            %%% Add intervals to protocol
            for ct = 1:parametersParadigm_LOC.nTrialsCondition{ca, cc}
                doc.AddInterval(strCondition, parametersParadigm_LOC.startVolumeCondition{ca}{cc}{ct}, parametersParadigm_LOC.endVolumeCondition{ca}{cc}{ct});
            end
        end
        
        %%% Set additional protocol parameters and save protocol
        doc.StimulationProtocolBackgroundColorR = 0;
        doc.StimulationProtocolBackgroundColorG = 0;
        doc.StimulationProtocolBackgroundColorB = 0;
        doc.StimulationProtocolTimeCourseColorR = 255;
        doc.StimulationProtocolTimeCourseColorG = 255;
        doc.StimulationProtocolTimeCourseColorB = 255;
        doc.StimulationProtocolTimeCourseThickness = 4;
        doc.SaveStimulationProtocol(pathPrtFile{csf, ca});
        doc.Save();
        doc.Close();
        bvqx.Exit;
        %}
    end
end



for csf = 1:nScenarioFiles
    for ca = 1:parametersParadigm_LOC.nAnalyses
        createSdmFilesATWM1(parametersStimulationProtocol, pathVmrInTalFile, pathVtcFile, pathPrtFile{csf, ca})
    end
end

%}
end



%end
