function [aStrPresentationLogfilesLocal, nLogfiles] = defineNamesOfPresentationLogfilesATWM1(parametersStudy, parametersParadigm_WM_MRI)
%%% function [aStrPresentationLogfilesLocal, nLogfiles, nMissingFiles] = determineLogfileInformationATWM1(parametersStudy, parametersParadigm_WM_MRI)
global iStudy
global strGroup
global strSubject

% Determine names of logfiles
nLogfiles = 0;
for cco = 1:parametersParadigm_WM_MRI.nConditions
    % WM instruction
    nLogfiles = nLogfiles + 1;
    aStrPresentationLogfilesLocal{nLogfiles} = sprintf('%s-%s_%s_%s_%s_Instruction.log', strSubject, iStudy, parametersStudy.strFullWorkingMemoryTask, parametersStudy.strMRI, parametersParadigm_WM_MRI.aConditions{cco});
    % WM task
    nLogfiles = nLogfiles + 1;
    aStrPresentationLogfilesLocal{nLogfiles} = sprintf('%s-%s_%s_%s_%s_Run1.log', strSubject, iStudy, parametersStudy.strFullWorkingMemoryTask, parametersStudy.strMRI, parametersParadigm_WM_MRI.aConditions{cco});
end
% Localizer
nLogfiles = nLogfiles + 1;
aStrPresentationLogfilesLocal{nLogfiles} = sprintf('%s-%s_%s_%s.log', strSubject, iStudy, parametersStudy.strFullLocalizerTask, parametersStudy.strMRI);

%{
nMissingFiles = 0;
for cf = 1:nLogfiles
    if ~exist(aStrPresentationLogfilesLocal{cf}, 'file')
        strMessage = sprintf('Logfile %s not found\n', aStrPresentationLogfilesLocal{cf});
        disp(strMessage);
        nMissingFiles = nMissingFiles + 1;
    end
end

% Add special prompt for incomplete files
if nMissingFiles > 0
    strMessage = sprintf('\nError: %i missing logfiles for subject %s!\n', nMissingFiles, strSubject);
    disp(strMessage);
else
    strMessage = sprintf('\nLogfiles complete for subject %s!\n', strSubject);
    disp(strMessage);
end
%}

end