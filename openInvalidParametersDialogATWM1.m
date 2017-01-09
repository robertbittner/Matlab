function bAbort = openInvalidParametersDialogATWM1()

global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

strSubjectAndGroup = sprintf('No valid parameters were entered!');
strTitle = '';
strOption1 = sprintf('%sRe-Enter values%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strSubjectAndGroup, strTitle, strOption1, strOption2, strOption1);
if ~isempty(choice)
    switch choice
        case strOption1
            bAbort = false;
        case strOption2
            bAbort = true;
            strMessage = sprintf('No parameters entered.\nAborting function.');
            disp(strMessage);
    end
else
    bAbort = true;
    strMessage = sprintf('No parameters entered.\nAborting function.');
    disp(strMessage);
end


end