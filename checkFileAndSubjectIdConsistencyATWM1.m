function checkFileAndSubjectIdConsistencyATWM1(aStrAllSubjects, aStrSubjectBarcode, aStrSubjectCode, nrOfSubjects, nrOfBarcodeFiles, nrOfSubjectCodeFiles);

%%% Check, whether the number of files matches the number of enrolled subjects and whether the subject IDs match as well
bCorrectNrOfFiles   = isequal(nrOfSubjectCodeFiles, nrOfSubjects) && isequal(nrOfBarcodeFiles, nrOfSubjects);
bMatchingSubjectId  = isequal(aStrSubjectCode, aStrSubjectBarcode) && isequal(aStrAllSubjects, aStrSubjectBarcode) && isequal(aStrAllSubjects, aStrSubjectCode);

if bCorrectNrOfFiles == false
    strMessage = sprintf('Number of subject code files: %i.', nrOfSubjectCodeFiles);
    disp(strMessage);
    strMessage = sprintf('Number of subjects: %i.', nrOfSubjects);
    disp(strMessage);
    strMessage = sprintf('Number of barcode files: %i.', nrOfBarcodeFiles);
    disp(strMessage);
    strMessage = sprintf('Number of files does not match the expected number!\nAborting function.');
    error(strMessage);
elseif bMatchingSubjectId == false
    strMessage = sprintf('Subject IDs do not match!\nAborting function.');
    error(strMessage);
end

end