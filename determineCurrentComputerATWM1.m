function parametersNetwork = determineCurrentComputerATWM1()
%% Determine current computer

global iStudy

parametersNetwork = eval(['parametersNetwork', iStudy]);

strDialogSelectionMode = 'single';
strPrompt = 'Please select computer you are currently working on';
strTitle = 'Select computer';
vListSize = [300, 500];

[indCurrentComputer] = listdlg('ListString', parametersNetwork.aStrCurrentComputer, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(indCurrentComputer)
    strMessage = sprintf('\n\nNo computer selected!\n');
    error(strMessage);
end

parametersNetwork.strCurrentComputer = parametersNetwork.aStrCurrentComputer{indCurrentComputer};


end