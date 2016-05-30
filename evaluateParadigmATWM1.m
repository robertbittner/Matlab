function evaluateParadigmATWM1();
%%% This function creates stimulation protocols
%%% Written for BVQX 2.8.4

clear all
clc

%%% Define the study
global iStudy;
global iSubject;

iStudy = 'ATWM1';

strLocalizer = 'LOC';

bOverwriteExistingFiles = false;
%bOverwriteExistingFiles = true;


parametersStimulationProtocol = parametersStimulationProtocolATWM1;

strScenarioFile = 'SCE';
strProtocolFile = 'PRT';
strDesignMatrixFile = 'SDM';

%strFolderScenarioFiles = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\Scenario_Files\';
strEvaluationFolder = 'D:\Daten\ATWM1\Design_Matrix\Evaluation\Localizer\';

aStrDesign = {
    'V5_ITI_2s_every_10th_to_14th_trial_144_Trials'
    };

for cd = 1:numel(aStrDesign)
    aStrSubfolder{cd} = sprintf('%s_%s', aStrDesign{cd}, strScenarioFile);
end

%return
%%% Define dummy files necessary for prt and sdm creation
strVmrInTalFile = 'TEST_BRAIN_IIHC_aTAL.vmr';
pathVmrInTalFile = strcat(strEvaluationFolder, strVmrInTalFile);
strVtcFile = 'TEST_176_vol.vtc';
strVtcFile = 'TEST_170_vol_TAL.vtc';
pathVtcFile = strcat(strEvaluationFolder, strVtcFile);


%{
vtc = xff(pathVtcFile);
nrOfVolumesVtc = vtc.NrOfVolumes;
vtc.ClearObject;

if nrOfVolumesVtc
    
end
%}



nrOfSubfolders = numel(aStrSubfolder);
%nrOfSubfolders = 1
%%{
for cfol = 1:nrOfSubfolders
    strFolderScenarioFiles{cfol} = strcat(strEvaluationFolder, aStrSubfolder{cfol}, '\');
    strucScenarioFiles = dir(strFolderScenarioFiles{cfol});
    strucScenarioFiles = strucScenarioFiles(3:end);
    nScenarioFiles = numel(strucScenarioFiles);
    
    %nScenarioFiles = 5
    startingScenarioFile = 500;
    strFolderPrtFiles{cfol} = sprintf('%s_%s', aStrDesign{cfol}, strProtocolFile);
    strFolderPrtFiles{cfol} = strcat(strEvaluationFolder, strFolderPrtFiles{cfol}, '\'); 
    if ~exist(strFolderPrtFiles{cfol}, 'dir')
        mkdir(strFolderPrtFiles{cfol})
    end
    %{
    for csf = startingScenarioFile:nScenarioFiles
        aStrScenarioFiles{csf} = strucScenarioFiles(csf).name;
        strScenarioFile = aStrScenarioFiles{csf};
        strPathScenarioFile = strcat(strFolderScenarioFiles{cfol}, strScenarioFile);
        parametersParadigm = readScenarioFileLocalizerATWM1(strPathScenarioFile);
        parametersParadigm.nAnalyses = 1
        for ca = 1:parametersParadigm.nAnalyses
            parametersStimulationProtocol.aStrConditions        = parametersParadigm.aConditions{ca, 1};
            parametersStimulationProtocol.nConditions           = parametersParadigm.aConditions{ca, 2};
            parametersStimulationProtocol.startVolumeCondition  = parametersParadigm.startVolumeCondition{ca};
            parametersStimulationProtocol.endVolumeCondition    = parametersParadigm.endVolumeCondition{ca};
            parametersStimulationProtocol.nTrialsCondition      = parametersParadigm.nTrialsCondition(ca, :);
            
            strAnalysis = parametersParadigm.aConditions{ca, 4};
            
            strPrtFile = sprintf('%s_%02i_%s_%s_%s.prt', aStrSubfolder{cfol}, csf, iStudy, strLocalizer, strAnalysis);
            pathPrtFile{csf, ca} = strcat(strFolderPrtFiles{cfol}, strPrtFile);
            if bOverwriteExistingFiles == false && exist(pathPrtFile{csf, ca}, 'file')
                continue
            else
                strMessage = sprintf('Creating protocol %s', pathPrtFile{csf, ca});
                disp(strMessage);
                bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
                createStimulationPrtFileATWM1(bvqx, parametersStimulationProtocol, pathPrtFile{csf, ca}, pathVmrInTalFile, pathVtcFile );
                bvqx.Exit;
            end
        end
    
    end
    %}
end

%evaluateSdmFilesATWM1(aStrSubfolder, strFolderPrtFiles, parametersStimulationProtocol)
for cfol = 1:nrOfSubfolders
    strucPrtFiles{cfol} = dir(strFolderPrtFiles{cfol});
    strucPrtFiles{cfol} = strucPrtFiles{cfol}(3:end);    

    nPrtFiles = numel(strucPrtFiles{cfol});
    startingPrtFile = 1;
    parametersParadigm.nAnalyses = 1

    %nPrtFiles = 5

    strFolderSdmFiles{cfol} = sprintf('%s_%s', aStrDesign{cfol}, strDesignMatrixFile);
    strFolderSdmFiles{cfol} = strcat(strEvaluationFolder, strFolderSdmFiles{cfol}, '\');

    %{
    if ~exist(strFolderSdmFiles{cfol}, 'dir')
        mkdir(strFolderSdmFiles{cfol})
    end
    for csf = startingPrtFile:nPrtFiles
        for ca = 1%:parametersParadigm.nAnalyses
            strPrtFile = strucPrtFiles{cfol}(csf).name;
            pathPrtFile{csf, ca} = strcat(strFolderPrtFiles{cfol}, strPrtFile);
            strSdmFile = sprintf('%s', strrep(strPrtFile, 'prt', 'sdm'));
            pathSdmFile{csf, ca} = strcat(strFolderSdmFiles{cfol}, strSdmFile);
            createSdmFilesATWM1(parametersStimulationProtocol, pathVmrInTalFile, pathVtcFile, pathPrtFile{csf, ca}, pathSdmFile{csf, ca}, bOverwriteExistingFiles);
        end
    end
    %}
end


for cfol = 1:nrOfSubfolders
    
    strucSdmFiles{cfol} = dir(strFolderSdmFiles{cfol});
    strucSdmFiles{cfol} = strucSdmFiles{cfol}(3:end);    
    nSdmFiles = numel(strucSdmFiles{cfol});
    
    
    startingSdmFile = 1;
    %nSdmFiles = 5
    for csf = startingSdmFile:nSdmFiles
        for ca = 1%:parametersParadigm.nAnalyses
            strSdmFile = strucSdmFiles{cfol}(csf).name;
            pathSdmFile{csf, ca} = strcat(strFolderSdmFiles{cfol}, strSdmFile);
            efficiency(cfol, csf, ca) = analyzeDesignMatrixATWM1(pathSdmFile{csf, ca});
            meanEfficiency(cfol) = mean(efficiency(cfol, :, :));
            minEfficiency(cfol) = min(efficiency(cfol, :, :));
            maxEfficiency(cfol) = max(efficiency(cfol, :, :));
        end
    end
end


%%% Find the most efficient SDM files
fraction = 0.02;
%fraction = 0.5;

nrOfEfficientSdmFiles = ceil(nSdmFiles * fraction);

strEfficiencyResultsFile = 'SDMListEffciencyResultsFile.txt';
pathEfficiencyResultsFile = strcat(strEvaluationFolder, strEfficiencyResultsFile);

fid = fopen(pathEfficiencyResultsFile, 'wt');


for cfol = 1:nrOfSubfolders
    vEfficiency = sort(efficiency(cfol, :, :));
    vEfficiency = vEfficiency(nSdmFiles - nrOfEfficientSdmFiles + 1:end);
    %full = efficiency(cfol, :, :);
    [~,idxEfficiency] = ismember(vEfficiency, efficiency(cfol, :, :));
    idxEfficiency = fliplr(idxEfficiency);
    %aStrEfficientSdmFiles = 
    fprintf(fid, 'DM: %s\n', strFolderSdmFiles{cfol});
    fprintf(fid, 'Mean Efficiency: %f\n\n\n', mean(efficiency(cfol, :, :)));
    for cedm = 1:nrOfEfficientSdmFiles
        aStrEfficientSdmFiles{cfol, cedm} = strucSdmFiles{cfol}(idxEfficiency(cedm)).name;
        pathSdmFile = strcat(strFolderSdmFiles{cfol}, aStrEfficientSdmFiles{cfol, cedm});
        %pathSdmFile = createSdmFilesATWM1(parametersStimulationProtocol, pathVmrInTalFile, pathVtcFile, pathPrtFile{csf, ca}, bOverwriteExistingFiles);
        
        fprintf(fid, 'Rank: %i\n', cedm);
        fprintf(fid, 'File: %s\n', pathSdmFile);
        fprintf(fid, 'Efficiency: %f\n\n', efficiency(cfol, csf, ca));
    end
    fprintf(fid, '\n');
end
fclose(fid);



end

function evaluateSdmFilesATWM1(aStrSubfolder, strFolderPrtFiles);
%%% This part of the code only analyzes SDM files
%{
aStrSubfolder = {
    %'_SCE_FILES'
    %'V4_ITI_2s_every_4th_trial_112_Trials'
    %'V4_ITI_2s_every_8th_trial_128_Trials'
    'V4_ITI_2s_every_12th_trial_144_Trials_SDM'
    'V5_ITI_2s_every_9th_to_15th_trial_144_Trials_SDM'
    };
%}
for cfol = 1:nrOfSubfolders
    %strFolderPrtFiles = sprintf('%s_%s', aStrDesign{cfol}, strProtocolFile);
    %strFolderPrtFiles = strcat(strEvaluationFolder, strFolderPrtFiles, '\');
    
    strFolderSdmFiles{cfol} = sprintf('%s_%s', aStrDesign{cfol}, strDesignMatrixFile);
    strFolderSdmFiles{cfol} = strcat(strEvaluationFolder, strFolderSdmFiles{cfol}, '\');
    
    strFolderSdmFiles{cfol} = strcat(strEvaluationFolder, aStrSubfolder{cfol}, '\');
    strucSdmFiles{cfol} = dir(strFolderSdmFiles{cfol});
    strucSdmFiles{cfol} = strucSdmFiles{cfol}(3:end);    
    nSdmFiles = numel(strucSdmFiles{cfol});
    %nSdmFiles = 10
    %nSdmFiles = 500
    %startingScenarioFile = 1;
    parametersParadigm.nAnalyses = 1
    

    
    %strDesignMatrixFile
    
    %%{
    if ~exist(strFolderSdmFiles{cfol}, 'dir')
        mkdir(strFolderSdmFiles{cfol})
    end
    for csf = 1:nSdmFiles
        for ca = 1%:parametersParadigm.nAnalyses
            strSdmFile = strucSdmFiles{cfol}(csf).name;
            pathSdmFile = strcat(strFolderSdmFiles{cfol}, strSdmFile);
            pathSdmFile = createSdmFilesATWM1(parametersStimulationProtocol, pathVmrInTalFile, pathVtcFile, pathPrtFile{csf, ca}, bOverwriteExistingFiles);
            efficiency(cfol, csf, ca) = analyzeDesignMatrixATWM1(pathSdmFile);
            sprintf('SDM file: %s\nEfficiency: %f', pathSdmFile, efficiency(cfol, csf, ca))
        end
    end
    
    %}
end
end


function calculateEfficiencyATWM1();

%%{
for cfol = 1:nrOfSubfolders
    meanEfficiency(cfol) = mean(efficiency(cfol, :, :))
    minEfficiency(cfol) = min(efficiency(cfol, :, :));
    maxEfficiency(cfol) = max(efficiency(cfol, :, :));
end

%%% Find the most efficient SDM files
fraction = 0.02;
%fraction = 0.5;

nrOfEfficientSdmFiles = ceil(nSdmFiles * fraction);

strEfficiencyResultsFile = 'SDMListEffciencyResultsFile.txt';
pathEfficiencyResultsFile = strcat(strEvaluationFolder, strEfficiencyResultsFile);

fid = fopen(pathEfficiencyResultsFile, 'wt');


for cfol = 1:nrOfSubfolders
    vEfficiency = sort(efficiency(cfol, :, :));
    vEfficiency = vEfficiency(nSdmFiles - nrOfEfficientSdmFiles + 1:end);
    full = efficiency(cfol, :, :);
    [~,idxEfficiency] = ismember(vEfficiency, efficiency(cfol, :, :));
    idxEfficiency = fliplr(idxEfficiency);
    %aStrEfficientSdmFiles = 
    fprintf(fid, 'DM: %s\n', strFolderSdmFiles{cfol});
    fprintf(fid, 'Mean Efficiency: %f\n', mean(efficiency(cfol, :, :)));
    for cedm = 1:nrOfEfficientSdmFiles
        aStrEfficientSdmFiles{cfol, cedm} = strucSdmFiles{cfol}(idxEfficiency(cedm)).name;
        pathSdmFile = strcat(strFolderSdmFiles{cfol}, aStrEfficientSdmFiles{cfol, cedm});
        %pathSdmFile = createSdmFilesATWM1(parametersStimulationProtocol, pathVmrInTalFile, pathVtcFile, pathPrtFile{csf, ca}, bOverwriteExistingFiles);
        efficiency(cfol, csf, ca) = analyzeDesignMatrixATWM1(pathSdmFile);
        fprintf(fid, 'Rank: %i\n', cedm);
        fprintf(fid, 'File: %s\n', pathSdmFile);
        fprintf(fid, 'Efficiency: %f\n', efficiency(cfol, csf, ca));
    end
    fprintf(fid, '\n');
end
fclose(fid);


end



function createStimulationPrtFileATWM1(bvqx, parametersStimulationProtocol, pathPrtFile, pathVmrInTalFile, pathVtcFile );

global iStudy

doc = bvqx.OpenDocument(pathVmrInTalFile);
doc.LinkVTC(pathVtcFile);
doc.ClearStimulationProtocol();
doc.StimulationProtocolExperimentName = iStudy;
doc.StimulationProtocolResolution = parametersStimulationProtocol.iResolution;


for cc = 1:parametersStimulationProtocol.nConditions
    strCondition = parametersStimulationProtocol.aStrConditions{cc};
    
    %%% Add conditions to protocol
    doc.AddCondition(strCondition);
    
    %%% Add intervals to protocol
    for ct = 1:parametersStimulationProtocol.nTrialsCondition{cc}
        doc.AddInterval(strCondition, parametersStimulationProtocol.startVolumeCondition{cc}{ct}, parametersStimulationProtocol.endVolumeCondition{cc}{ct});
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
doc.SaveStimulationProtocol(pathPrtFile);
doc.Save();
doc.Close();


end


