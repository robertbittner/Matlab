function [bAbort] = selectConfigurationForProjectFileProcessingATWM1()
%%% Setting for full functionality
%%% bTestConfiguration = false
%%% Setting for programming and debugging:
%%% bTestConfiguration = true

global iStudy
global bTestConfiguration

%%% Load text and dialog elements
[textElements, parametersDialog] = eval(['defineDialogTextElements', iStudy]);

strTitle = 'Full mode or test configuration';
strPrompt = 'Select mode for project file creation:';

parametersDialog.strFullProcessingMode = 'Full processing mode';
parametersDialog.strTestConfiguration = 'Test configuration';

strButton1 = sprintf('%s%s%s', parametersDialog.strEmpty, parametersDialog.strFullProcessingMode, parametersDialog.strEmpty);
strButton2 = sprintf('%s%s%s', parametersDialog.strEmpty, parametersDialog.strTestConfiguration, parametersDialog.strEmpty);
default = strButton1;
choice = questdlg(strPrompt, strTitle, strButton1, strButton2, default);

switch choice
    case strButton1
        bTestConfiguration = false;
        bAbort = false;
        fprintf('%s selected\n', parametersDialog.strFullProcessingMode);
    case strButton2
        bTestConfiguration = true;
        bAbort = false;
        fprintf('%s selected\n', parametersDialog.strTestConfiguration);
    otherwise
        bTestConfiguration = true;
        bAbort = true;
        fprintf('Error!\nNeither %s nor %s selected\nAborting function!\n', parametersDialog.strFullProcessingMode, parametersDialog.strTestConfiguration);
end


end