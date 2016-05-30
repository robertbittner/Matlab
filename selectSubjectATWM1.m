function [iSubject, iGroup, iGroupLong, bAbort] = selectSubjectATWM1(strStudyType);

global iStudy

parametersGroups    = eval(['parametersGroups', iStudy]);

%%% Read the subject data
%strStudyType = sprintf('%s_%s', iStudy, parametersStudy.strImaging);
hFunction = str2func(sprintf('aSubject%s', strStudyType));
aSubject = feval(hFunction);
aSubject = aSubject.(genvarname(strStudyType)).(genvarname(parametersGroups.strGroups));

bSubjectInformationCorrect = false;
while bSubjectInformationCorrect == false
    aStrCombinedSubject = {};
    for cg = 1:parametersGroups.nGroups
        aStrSubject{cg} = (aSubject.(genvarname(parametersGroups.aStrShortGroups{cg})))';
        aStrCombinedSubject = [aStrCombinedSubject, aStrSubject{cg}];
    end
    aStrCombinedSubject = (sort(aStrCombinedSubject))';
    
    strTitle = 'Subject selection';
    strPrompt = 'Please select the subject you want to process';
    [iSelectedSubject] = listdlg('ListString', aStrCombinedSubject, 'SelectionMode', 'single', 'Name', strTitle, 'PromptString', strPrompt, 'ListSize', [300 100]);
    if isempty(iSelectedSubject)
        strMessage = sprintf('No subject selected.\nAborting function.');
        disp(strMessage);
        iSubject = [];
        iGroup = [];
        iGroupLong = [];
        bAbort = true;
        return
    end
    iSubject = aStrCombinedSubject{iSelectedSubject};
    
    %%% Determine the group of the selected subject
    for cg = 1:parametersGroups.nGroups
        if ~isempty(cell2mat(strfind(aStrSubject{cg}, iSubject)))
            iGroup = parametersGroups.aStrShortGroups{cg};
            iGroupLong = parametersGroups.aStrLongGroups{cg};
        end
    end
    
    hFunction = str2func(sprintf('verifySubjectInformation%s', iStudy));
    [bAbort, bSubjectInformationCorrect] = feval(hFunction, iSubject, iGroupLong);
    if bAbort == true
        return
    end
end


end


function [bAbort, bSubjectInformationCorrect] = verifySubjectInformationATWM1(iSubject, iGroupLong);

global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strSubjectAndGroup = sprintf('Subject:\n%s\n\nGroup:\n%s', iSubject, iGroupLong);
strTitle = 'Verify subject information';
strButton1 = sprintf('%sCorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strButton2 = sprintf('%sIncorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strButton3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strSubjectAndGroup, strTitle, strButton1, strButton2, strButton3, strButton1);
if ~isempty(choice)
    
    switch choice
        case strButton1
            bSubjectInformationCorrect = true;
            bAbort = false;
        case strButton2
            bSubjectInformationCorrect = false;
            bAbort = false;
        case strButton3
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

