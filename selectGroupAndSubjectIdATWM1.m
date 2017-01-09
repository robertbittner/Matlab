function [strGroup, strSubject, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, varargin)

global iStudy

test = nargin

strDialogSelectionModeGroup = 'single'; 
if nargin > 0
    strDialogSelectionModeSubject = varargin{1};
else
    strDialogSelectionModeSubject = 'single';
end


bSubjectInformationCorrect = false;
while bSubjectInformationCorrect == false
    
    %% Select group
    strPrompt = 'Please select the group';
    strTitle = 'Group selection';
    vListSize = [300, 100];
    
    [iGroup] = listdlg('ListString', parametersGroups.aStrShortGroups, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionModeGroup);
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
    [iSubject] = listdlg('ListString', aStrSubjectsGroup, 'PromptString', strPrompt, 'Name', strTitle, 'ListSize', vListSize, 'SelectionMode', strDialogSelectionModeSubject);
    if isempty(iSubject)
        strMessage = sprintf('\n\nNo subject(s)selected!\n');
        error(strMessage);
    end
    aStrSubject = aSubject.ATWM1_IMAGING.Groups.(genvarname(strGroup))(iSubject);
    nSubjects = numel(aStrSubject);
    %% Verify information
    hFunction = str2func(sprintf('verifySubjectAndGroupInformation%s', iStudy));
    [bAbort, bSubjectInformationCorrect] = feval(hFunction, aStrSubject, strGroupLong, nSubjects);
    if bAbort == true
        strSubject = '';
        return
    end
    
end

if nSubjects == 1 && strcmp(strDialogSelectionModeSubject, 'single')
    strSubject = aStrSubject{1};
else
    strSubject = '';
end

end


function [bAbort, bSubjectInformationCorrect] = verifySubjectAndGroupInformationATWM1(aStrSubject, strGroupLong, nSubjects);

global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strSubjectInfo = sprintf('');
for cs = 1:nSubjects
    strSubjectInfo = sprintf('%s%s\n', strSubjectInfo, aStrSubject{cs});
end
strSubjectAndGroup = sprintf('Subject:\n%s\n\nGroup:\n%s', strSubjectInfo, strGroupLong);
strTitle = 'Verify subject information';
strOption1 = sprintf('%sCorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sIncorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strSubjectAndGroup, strTitle, strOption1, strOption2, strOption3, strOption1);

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
        strMessage = sprintf('No subject(s)selected.\nAborting function.');
        disp(strMessage);
    otherwise
        bSubjectInformationCorrect = false;
        bAbort = true;
        strMessage = sprintf('No subject(s)selected.\nAborting function.');
        disp(strMessage);
end


end

