function [strGroup, strSubject, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject)

global iStudy

strDialogSelectionMode = 'single';
bSubjectInformationCorrect = false;
while bSubjectInformationCorrect == false
    
    %% Select group
    strPrompt = 'Please select the group';
    strTitle = 'Group selection';
    vListSize = [300, 100];
    
    [iGroup] = listdlg('ListString', parametersGroups.aStrShortGroups, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionMode);
    if isempty(iGroup)
        strMessage = sprintf('\n\nNo group selected!\n');
        error(strMessage);
    end
    strGroup        = parametersGroups.aStrShortGroups{iGroup};
    strGroupLong    = parametersGroups.aStrLongGroups{iGroup};
    
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
    
    %% Verify information
    hFunction = str2func(sprintf('verifySubjectAndGroupInformation%s', iStudy));
    [bAbort, bSubjectInformationCorrect] = feval(hFunction, strSubject, strGroupLong);
    if bAbort == true
        return
    end
    
end

end


function [bAbort, bSubjectInformationCorrect] = verifySubjectAndGroupInformationATWM1(strSubject, strGroupLong);

global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strSubjectAndGroup = sprintf('Subject:\n%s\n\nGroup:\n%s', strSubject, strGroupLong);
strTitle = 'Verify subject information';
strOption1 = sprintf('%sCorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sIncorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strSubjectAndGroup, strTitle, strOption1, strOption2, strOption3, strOption1);
if ~isempty(choice)
    
    switch choice
        case strOption1
            bSubjectInformationCorrect = true;
            bAbort = false;
        case strOption2
            bSubjectInformationCorrect = false;
            bAbort = false;
        case strOption3
            bSubjectInformationCorrect = false;
            bAbort = true;
            strMessage = sprintf('No subject selected.\nAborting function.');
            disp(strMessage);
    end
    
else
    bSubjectInformationCorrect = false;
    bAbort = true;
    strMessage = sprintf('No subject selected.\nAborting function.');
    disp(strMessage);
end

end

