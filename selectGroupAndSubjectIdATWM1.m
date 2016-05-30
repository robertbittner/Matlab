function [strGroup, strSubject] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject)

strDialogSelectionMode = 'single';

%% Select group
strPrompt = 'Please select the group';
strTitle = 'Group selection';
vListSize = [300, 100];

[iGroup] = listdlg('ListString', parametersGroups.aStrShortGroups, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(iGroup)
    strMessage = sprintf('\n\nNo group selected!\n');
    error(strMessage);
end
strGroup = parametersGroups.aStrShortGroups{iGroup};

%% Select subject
strPrompt = 'Please select the subject code';
strTitle = 'Subject code';
vListSize = [300, 600];
aStrSubjectsGroup = aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup));
[iSubject] = listdlg('ListString', aStrSubjectsGroup, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
if isempty(iSubject)
    strMessage = sprintf('\n\nNo subject selected!\n');
    error(strMessage);
end
strSubject = aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup)){iSubject};

end
