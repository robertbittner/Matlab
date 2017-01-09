function [vSessionIndex, bAbort] = determineMriSessionATWM1(aStrSubject, nSubjects)

bParametersEntered = false;
while ~bParametersEntered
    strTitle = sprintf('MRI session index');
    aStrPrompt = {};
    aStrDefaultAnswer = {};
    for cs = 1:nSubjects
        strSubject = aStrSubject{cs};
        strPrompt = sprintf('Please enter index of MRI session of subject %s.', strSubject);
        aStrPrompt = [aStrPrompt, strPrompt];
        strDefaultAnswer = '1';
        aStrDefaultAnswer = [aStrDefaultAnswer, strDefaultAnswer];
    end
    nrOfLines = 1;
    aStrAnswer = inputdlg(aStrPrompt, strTitle, nrOfLines, aStrDefaultAnswer);
    if ~isempty(aStrAnswer)
        bParametersEntered = true;
        bAbort = false;
        for cs = 1:nSubjects
            vSessionIndex(cs) = str2num(aStrAnswer{cs});
        end
    else
        vSessionIndex = [];
        bAbort = openInvalidParametersDialogATWM1;
    end
    if bAbort == true
        break
    end
end


end