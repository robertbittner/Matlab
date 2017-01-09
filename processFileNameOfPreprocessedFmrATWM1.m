function [parametersProjectFiles, bPreprocessingSuccessful] = processFileNameOfPreprocessedFmrATWM1(parametersProjectFiles, bPreprocessingSuccessful)
%%% Compare name of preprocessed FMR given by BrainVoyager with the name
%%% predefined in the scripts. 

%%% Replace path delimiter '/' with '\'
parametersProjectFiles.strFileNameOfPreprocessedFmr = strrep(parametersProjectFiles.strFileNameOfPreprocessedFmr, '/', '\');

if ~strcmp(parametersProjectFiles.strFileNameOfPreprocessedFmr, parametersProjectFiles.strPathCurrentFmrFileAfterPreprocessing)
    fprintf('\n');
    fprintf('Warning!\nFile name %s does not match pre-specified\n', parametersProjectFiles.strFileNameOfPreprocessedFmr);
    fprintf('file name %s\n', parametersProjectFiles.strPathCurrentFmrFileAfterPreprocessing);
    fprintf('after preprocessing step %s\n', lower(parametersProjectFiles.strCurrentPreprocessingStep));
    fprintf('\n');
    bPreprocessingSuccessful = false;
end


end