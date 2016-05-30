function [textElements, parametersDialog] = defineDialogTextElementsATWM1();

textElements.strFirstName               = 'First name';
textElements.strFamilyName              = 'Family name';
textElements.strDateOfBirth             = 'Date of birth';
textElements.strGroup                   = 'Group';
textElements.strDateOfStudyEnrollment   = 'Enrollment date';

textElements.strStudy                   = 'Study';
textElements.strStudyCode               = 'Study Code';
textElements.strPrincipalInvestigator   = 'Principal Investigator';
textElements.strSubjectInformation      = 'Subject Information';
textElements.strSubjectNumber           = 'Subject Number';


%%% Strings used for dialogs
parametersDialog.strEmpty                   = '          ';
parametersDialog.strEmptyDouble             = [parametersDialog.strEmpty, parametersDialog.strEmpty];
parametersDialog.strFirstName               = sprintf('%s:    ', textElements.strFirstName);
parametersDialog.strFamilyName              = sprintf('%s: ', textElements.strFamilyName);
parametersDialog.strDateOfBirth             = sprintf('%s:  ', textElements.strDateOfBirth);
parametersDialog.strGroup                   = sprintf('%s:           ', textElements.strGroup);
parametersDialog.strDateOfStudyEnrollment   = sprintf('%s:      ', textElements.strDateOfStudyEnrollment);

end