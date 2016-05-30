function enrollSubjectInStudyATWM1();

clear all
clc

global iStudy
global m_cfg

iStudy = 'ATWM1';

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);
parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);


%%% Check, whether all relevant local and server folders can be accessed
hFunction = str2func(sprintf('checkFolderAccess%s', iStudy));
bAllFoldersCanBeAccessed = feval(hFunction, folderDefinition);
if bAllFoldersCanBeAccessed == false
    error('Folders for study %s cannot be accessed.', iStudy);
end

%%% Load text and dialog elements
[textElements, parametersDialog] = eval(['defineDialogTextElements', iStudy]);

%%% Open dialog to select enrollment options
%%% - enroll new subject
%%% - recreate & reprint subject information sheet for an already enrolled 
%%%   subject
[bFullEnrollment, bRecreateSheet] = selectEnrollmentOptionsATWM1(parametersDialog);
if isempty(bFullEnrollment) || isempty(bRecreateSheet)
    return
end

%%% Proceed here for simple recreation of subject information sheet
if bFullEnrollment == false
    hFunction = str2func(sprintf('recreateSubjectInformationSheet%s', iStudy));
    feval(hFunction, parametersStudy, parametersGroups, parametersDialog, textElements, bFullEnrollment);
    return      
end

%%% Proceed here for full subject enrollment
%%% Open dialog to enter subject information
hFunction = str2func(sprintf('enterSubjectInformation%s', iStudy));
[subjectInformation] = feval(hFunction, parametersGroups, parametersDialog, bFullEnrollment);
if isempty(subjectInformation)
    return
end

%%% Generate random subject code
hFunction = str2func(sprintf('generateSubjectCode%s', iStudy));
[aSubject, subjectInformation] = feval(hFunction, subjectInformation);

%%% Update aSubject and subjectInformation variables
hFunction = str2func(sprintf('updateSubjectInformation%s', iStudy));
[aSubject, subjectInformation] = feval(hFunction, aSubject, subjectInformation, parametersStudy, parametersGroups);

%{
subjectInformation = subjectInformation
aAdditionalSubjectInformation = processAdditionalSubjectInformationATWM1_IMAGING

nSubjectsNew = aAdditionalSubjectInformation.nSubjects + 1;
    aAdditionalSubjectInformation.aStrSubjectNumber{nSubjectsNew}     = subjectInformation.strSubjectNumber
    aAdditionalSubjectInformation.aStrSubjectCode{nSubjectsNew}       = subjectInformation.strSubjectCode
    aAdditionalSubjectInformation.aStrEnrollmentDate{nSubjectsNew}    = subjectInformation.strDateOfStudyEnrollment
%end
%}
%return

%%% Print sheet with subject information
hFunction = str2func(sprintf('createAndPrintSubjectInformationSheet%s', iStudy));
bPrintSuccessful = feval(hFunction, parametersStudy, textElements, subjectInformation);
if bPrintSuccessful == false
    return
end

%%% Create output file with new subject code
hFunction = str2func(sprintf('createOutputFileWithNewSubjectCode%s', iStudy));
[pathSubjectCodeOutputFile] = feval(hFunction, folderDefinition, parametersSubjectCode, subjectInformation, textElements);

%%% Create backup of aSubject file before updating it
hFunction = str2func(sprintf('createBackupOfSubjectArrayFile%s', iStudy));
feval(hFunction, folderDefinition, parametersStudy, aSubject, pathSubjectCodeOutputFile);

%%% Generate barcode and file for printing
hFunction = str2func(sprintf('createBarcodeFile%s', iStudy));
feval(hFunction, subjectInformation, pathSubjectCodeOutputFile);

%%% Add new subject code to selected group in aSubject
hFunction = str2func(sprintf('updateSubjectArrayFile%s', iStudy));
feval(hFunction, aSubject, subjectInformation, pathSubjectCodeOutputFile);

%%% Confirm successful enrollment of subject
hFunction = str2func(sprintf('confirmEnrollmentOfSubject%s', iStudy));
feval(hFunction, subjectInformation);

%%% Backup current data and transfer it to the server
backupSubjectDataATWM1;
transferCurrentSubjectDataToServerATWM1;

end


function [bFullEnrollment, bRecreateSheet] = selectEnrollmentOptionsATWM1(parametersDialog);
strTitle = 'Enrollment options';
strPrompt = 'Select options for subject enrollment:';

strButton1 = sprintf('%sFull Enrollment of Subject%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strButton2 = sprintf('%sRecreate Subject Information Sheet%s', parametersDialog.strEmpty, parametersDialog.strEmpty);%'Incorrect';
default = strButton1;
choice = questdlg(strPrompt, strTitle, strButton1, strButton2, default);
if isempty(choice)
    strMessage = sprintf('No option selected!\nAborting function.');
    disp(strMessage);
        bFullEnrollment = {};
        bRecreateSheet  = {};
    return
end

switch choice
    case strButton1
        bFullEnrollment = true;
        bRecreateSheet  = false;
    case strButton2
        bFullEnrollment = false;
        bRecreateSheet  = true;
end

end


function recreateSubjectInformationSheetATWM1(parametersStudy, parametersGroups, parametersDialog, textElements, bFullEnrollment);

global iStudy

%%% Open dialog to enter subject information
hFunction = str2func(sprintf('enterSubjectInformation%s', iStudy));
[subjectInformation] = feval(hFunction, parametersGroups, parametersDialog, bFullEnrollment);
if isempty(subjectInformation)
    return
end

%%% Create dialog to select subject code
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);
aStrSubjectCodes = aSubject.ATWM1_IMAGING.Groups.(matlab.lang.makeValidName(subjectInformation.strSelectedShortGroup));

strTitle = 'Study code selection';
strPrompt = 'Please select study code of previously enrolled subject.';
listSize = [300 100];
[iSelectedSubjectCode] = listdlg('ListString', aStrSubjectCodes, 'Name', strTitle, 'PromptString', strPrompt, 'SelectionMode', 'single', 'ListSize', listSize);
if isempty(iSelectedSubjectCode)
    strMessage = sprintf('No study code selected.\nAborting function.');
    disp(strMessage);
    return
end
subjectInformation.strSubjectCode = aStrSubjectCodes{iSelectedSubjectCode};

%%% Create dialog to select subject number
nSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects;
for cs = 1:nSubjects
    aStrSubjectNumber{cs} = sprintf('%03i', cs);
end
strTitle = 'Subject number selection';
strPrompt = 'Please select subject number of previously enrolled subject.';
listSize = [300 100];
[iSelectedSubjectNumber] = listdlg('ListString', aStrSubjectNumber, 'Name', strTitle, 'PromptString', strPrompt, 'SelectionMode', 'single', 'ListSize', listSize);
if isempty(iSelectedSubjectNumber)
    strMessage = sprintf('No subject number selected.\nAborting function.');
    disp(strMessage);
    return
end
subjectInformation.strSubjectNumber = aStrSubjectNumber{iSelectedSubjectNumber};

%%% Print sheet with subject information
hFunction = str2func(sprintf('createAndPrintSubjectInformationSheet%s', iStudy));
bPrintSuccessful = feval(hFunction, parametersStudy, textElements, subjectInformation);
if bPrintSuccessful == false
    return
end

end


function [textElements, parametersDialog] = defineDialogTextElementsATWM1();

global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

textElements.strFirstName               = 'First name';
textElements.strFamilyName              = 'Family name';
textElements.strDateOfBirth             = 'Date of birth';
textElements.strGroup                   = 'Group';
textElements.strDateOfStudyEnrollment   = 'Enrollment date';

textElements.strStudy                   = 'Study';
textElements.strStudyCode               = 'Study Code';
textElements.strColorCode               = 'Color Code';
textElements.strPrincipalInvestigator   = 'Principal Investigator';
textElements.strSubjectInformation      = 'Subject Information';
textElements.strSubjectNumber           = 'Subject Number';


%%% Strings used for dialogs
%parametersDialog.strEmpty                   = '          ';
%parametersDialog.strEmptyDouble             = [parametersDialog.strEmpty, parametersDialog.strEmpty];
parametersDialog.strFirstName               = sprintf('%s:    ', textElements.strFirstName);
parametersDialog.strFamilyName              = sprintf('%s: ', textElements.strFamilyName);
parametersDialog.strDateOfBirth             = sprintf('%s:  ', textElements.strDateOfBirth);
parametersDialog.strGroup                   = sprintf('%s:           ', textElements.strGroup);
parametersDialog.strDateOfStudyEnrollment   = sprintf('%s:      ', textElements.strDateOfStudyEnrollment);

end


function subjectInformation = enterSubjectInformationATWM1(parametersGroups, parametersDialog, bFullEnrollment);

global iStudy

%%% While loop to insure, that the correct subject information has been
%%% entered.
bSubjectInformationCorrect = false;
bUpdateDefaultSubjectInformation = false;
while bSubjectInformationCorrect == false
    if bUpdateDefaultSubjectInformation == false
        %%% Dummy information
        subjectInformation.strFirstName     = 'First-Name';
        subjectInformation.strFamilyName    = 'Family-Name';
        subjectInformation.strDateOfBirth   = '01.01.1970';
    end
    
    %%% Determine date of study enrollment (current date)
    [strDateOfStudyEnrollment] = determineDateOfStudyEnrollmentATWM1(parametersDialog, bFullEnrollment);
    if isempty(strDateOfStudyEnrollment)
        subjectInformation = {};
        return
    end
    
    hFunction = str2func(sprintf('createSubjectInformationDialog%s', iStudy));
    subjectInformation = feval(hFunction, parametersDialog, subjectInformation);
    if isempty(subjectInformation)
        return
    end
    
    hFunction = str2func(sprintf('createSubjectGroupDialog%s', iStudy));
    subjectInformation = feval(hFunction, parametersGroups, subjectInformation, strDateOfStudyEnrollment);
    if isempty(subjectInformation)
        return
    end
    
    hFunction = str2func(sprintf('verifySubjectInformation%s', iStudy));
    [subjectInformation, bSubjectInformationCorrect, bUpdateDefaultSubjectInformation] = feval(hFunction, parametersDialog, subjectInformation, bUpdateDefaultSubjectInformation);
    if isempty(subjectInformation)
        return
    end
    
end

end


function [strDateOfStudyEnrollment] = determineDateOfStudyEnrollmentATWM1(parametersDialog, bFullEnrollment);
%%% Determine date of study enrollment (current date)
format shortg
currentTime = clock;
if bFullEnrollment == true
    strDateOfStudyEnrollment = sprintf('%02i.%02i.%i', currentTime(3), currentTime(2), currentTime(1));
else
    lengthDialog = 75;
    strDefaultEnrollmentDate = sprintf('01.01.%i', currentTime(1));
    strDateOfStudyEnrollment = inputdlg({parametersDialog.strDateOfStudyEnrollment}, 'Please enter original date of enrollment', [1 lengthDialog], {strDefaultEnrollmentDate});
    if isempty(strDateOfStudyEnrollment)
        strMessage = sprintf('No enrollment date entered.\nAborting function.');
        disp(strMessage);
        return
    else
        strDateOfStudyEnrollment = strDateOfStudyEnrollment{1};
    end
end

end


function subjectInformation = createSubjectInformationDialogATWM1(parametersDialog, subjectInformation);
%%% Create dialog to enter subject name and date of birth
aStrDefaultAnswers = {subjectInformation.strFirstName, subjectInformation.strFamilyName, subjectInformation.strDateOfBirth};

lengthDialog = 75;
aStrSubjectInformation = inputdlg({parametersDialog.strFirstName, parametersDialog.strFamilyName, parametersDialog.strDateOfBirth}, 'Please enter subject information', [1 lengthDialog; 1 lengthDialog; 1 lengthDialog], aStrDefaultAnswers);

if isempty(aStrSubjectInformation)
    strMessage = sprintf('No subject information entered.\nAborting function.');
    disp(strMessage);
    subjectInformation = {};
    return
else
    for c = 1:numel(aStrSubjectInformation)
        if isempty(aStrSubjectInformation{c})
            strMessage = sprintf('Missing subject information.\nAborting function.');
            disp(strMessage);
            subjectInformation = {};
            return
        end
    end
end
subjectInformation.strFirstName     = aStrSubjectInformation{1};
subjectInformation.strFamilyName    = aStrSubjectInformation{2};
subjectInformation.strDateOfBirth   = aStrSubjectInformation{3};

end

function subjectInformation = createSubjectGroupDialogATWM1(parametersGroups, subjectInformation, strDateOfStudyEnrollment);

%%% Create dialog to select group
strTitle = 'Group selection';
strPrompt = 'Please select the group.';
listSize = [300 100];
[iSelectedGroup] = listdlg('ListString', parametersGroups.aStrLongGroups, 'Name', strTitle, 'PromptString', strPrompt, 'SelectionMode', 'single', 'ListSize', listSize);
if isempty(iSelectedGroup)
    strMessage = sprintf('No group selected.\nAborting function.');
    disp(strMessage);
    subjectInformation = {};
    return
end
subjectInformation.strSelectedShortGroup    = parametersGroups.aStrShortGroups{iSelectedGroup};
subjectInformation.strSelectedGroup         = parametersGroups.aStrLongGroups{iSelectedGroup};
subjectInformation.strDateOfStudyEnrollment = strDateOfStudyEnrollment;
subjectInformation.strSelectedColorGroup    = upper(parametersGroups.aStrColorGroups{iSelectedGroup});

end


function [subjectInformation, bSubjectInformationCorrect, bUpdateDefaultSubjectInformation] = verifySubjectInformationATWM1(parametersDialog, subjectInformation, bUpdateDefaultSubjectInformation);

%%% Display subject information and subject code for final check
strTitle = 'Verify subject information';

strSubjectInformation = sprintf('%s%s%s\n\n%s%s%s\n\n%s%s%s\n\n%s%s%s\n\n%s%s%s', parametersDialog.strFirstName, parametersDialog.strEmpty, subjectInformation.strFirstName, parametersDialog.strFamilyName, parametersDialog.strEmpty, subjectInformation.strFamilyName, parametersDialog.strDateOfBirth, parametersDialog.strEmpty, subjectInformation.strDateOfBirth, parametersDialog.strGroup, parametersDialog.strEmpty, subjectInformation.strSelectedGroup, parametersDialog.strDateOfStudyEnrollment, subjectInformation.strDateOfStudyEnrollment);

strButton1 = sprintf('%sCorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strButton2 = sprintf('%sIncorrect%s', parametersDialog.strEmpty, parametersDialog.strEmpty);%'Incorrect';
strButton3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);%= 'Abort';
default = strButton3;
choice = questdlg(strSubjectInformation, strTitle, strButton1, strButton2, strButton3, default);
if isempty(choice)
    strMessage = sprintf('Subject information not verified!\nAborting function.');
    disp(strMessage);
    bSubjectInformationCorrect = false;
    subjectInformation = {};
    return
end

switch choice
    case strButton1
        bSubjectInformationCorrect = true;
    case strButton2
        bSubjectInformationCorrect = false;
        bUpdateDefaultSubjectInformation = true;
    case strButton3
        strMessage = sprintf('Subject information not verified!\nAborting function.');
        disp(strMessage);
        bSubjectInformationCorrect = false;
        subjectInformation = {};
        return
end

end


function [aSubject, subjectInformation] = updateSubjectInformationATWM1(aSubject, subjectInformation, parametersStudy, parametersGroups);

global iStudy

%%% Count the number of subjects across group and add the new subject
aSubjectsSelectedGroup = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).(matlab.lang.makeValidName(subjectInformation.strSelectedShortGroup));
aSubject.nPreviousSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL;
aSubjectsSelectedGroup = sort([aSubjectsSelectedGroup', subjectInformation.strSubjectCode])';

aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).(matlab.lang.makeValidName(subjectInformation.strSelectedShortGroup)) = aSubjectsSelectedGroup;
aSubject.nCurrentSubjects = aSubject.nPreviousSubjects + 1;
aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL = aSubject.nCurrentSubjects;

%%% Define the subject number of the new subject
subjectInformation.strSubjectNumber = sprintf('%03i', aSubject.nCurrentSubjects);

end


function [success, pathBackupFile] = backupArraySubjectFileATWM1(folderDefinition, parametersStudy, aSubject);

global iStudy

%%% Create timestamped backup of aSubject
strSubjectArrayFile = sprintf('aSubject%s_%s.m', iStudy, parametersStudy.strImaging);
pathSubjectArrayFile = strcat(folderDefinition.studyParameters, strSubjectArrayFile);
if ~exist(pathSubjectArrayFile, 'file')
    strMessage = sprintf('Could not find file %s!\nAborting function.', pathSubjectArrayFile);
    disp(strMessage);
    success = -1;
    return
end

%%% Create timestamp
format shortg
currentTime = clock;
currentSecond = num2str(currentTime(6));
iPoint = strfind(currentSecond, '.');
currentSecond = str2num(currentSecond(1:(iPoint-1)));
strTimeStamp = sprintf('%02i_%02i_%i_%02i-%02i-%02i', currentTime(3), currentTime(2), currentTime(1), currentTime(4), currentTime(5), currentSecond);

strBackupFile = sprintf('aSubject%s_%s__%03i_SUBJ__%s.m', iStudy, parametersStudy.strImaging, aSubject.nPreviousSubjects, strTimeStamp);
pathBackupFile = strcat(folderDefinition.subjectArrayBackup, strBackupFile);

success = copyfile(pathSubjectArrayFile, pathBackupFile);

end

function [pathSubjectCodeOutputFile] = createOutputFileWithNewSubjectCodeATWM1(folderDefinition, parametersSubjectCode, subjectInformation, textElements);

global iStudy

%%% Create output file with new subject code
strSubjectCodeOutputFile = sprintf('%s_%s_#%s.txt', iStudy, parametersSubjectCode.strSubjectCode, subjectInformation.strSubjectNumber);
pathSubjectCodeOutputFile = strcat(folderDefinition.subjectCodes, strSubjectCodeOutputFile);

try
    fid = fopen(pathSubjectCodeOutputFile, 'wt');
    if fid == -1
        status = 1;
        return
    else
        fprintf(fid, '%s:\t%s', textElements.strSubjectNumber, subjectInformation.strSubjectNumber);
        fprintf(fid, '\n');
        fprintf(fid, 'Subject Code:\t%s', subjectInformation.strSubjectCode);
        fprintf(fid, '\n');
        fprintf(fid, 'Group:\t\t%s', subjectInformation.strSelectedGroup);
        
        status = fclose(fid);
    end
    if status ~= 0
        error('File %s could not be created!', pathSubjectCodeOutputFile);
    end
catch
    error('File containing subject code could not be created!');
end

end


function bPrintSuccessful = createAndPrintSubjectInformationSheetATWM1(parametersStudy, textElements, subjectInformation);

global iStudy

try
    parametersInstitutionLogo = eval(['parametersInstitutionLogo', iStudy]);
    parametersSubjectInformationFigureElements = eval(['parametersSubjectInformationFigureElements', iStudy]);
    
    hFunction = str2func(strcat('generateTextSubjectInformation', iStudy));
    textSubjectInformation = feval(hFunction, textElements);
    
    hFunction = str2func(strcat('updateParametersSubjectInformationFigureElements', iStudy));
    parametersSubjectInformationFigureElements = feval(hFunction, parametersSubjectInformationFigureElements, parametersStudy, subjectInformation, textElements, textSubjectInformation);
    
    hFunction = str2func(strcat('createFigureWithSubjectInformation', iStudy));
    hFigure = feval(hFunction, parametersSubjectInformationFigureElements);
    
    hFunction = str2func(strcat('addTextBoxesToSubjectInformationFigure', iStudy));
    feval(hFunction, parametersSubjectInformationFigureElements)
    
    hFunction = str2func(strcat('addLogoToSubjectInformationFigure', iStudy));
    feval(hFunction, parametersInstitutionLogo, parametersSubjectInformationFigureElements)
    
    hFunction = str2func(strcat('printFigureWithSubjectInformation', iStudy));
    bPrintSuccessful = feval(hFunction, hFigure, subjectInformation);
    
    if bPrintSuccessful == true
        close(hFigure)
    else
        strMessage = sprintf('Subject information could not be printed!\nAborting function.');
        disp(strMessage);
    end
catch
    bPrintSuccessful = false;
    strMessage = sprintf('Subject information could not be printed!\nAborting function.');
    disp(strMessage);
end


end

function textSubjectInformation = generateTextSubjectInformationATWM1(textElements);

textSubjectInformation.strEnrollmentDate    = sprintf('%s:', textElements.strDateOfStudyEnrollment);
textSubjectInformation.strSubjectNumber     = sprintf('%s:', textElements.strSubjectNumber);
textSubjectInformation.strFirstName         = sprintf('%s:', textElements.strFirstName);
textSubjectInformation.strFamilyName        = sprintf('%s:', textElements.strFamilyName);
textSubjectInformation.strDateOfBirth       = sprintf('%s:', textElements.strDateOfBirth);
textSubjectInformation.strColorGroup        = sprintf('%s:', textElements.strColorCode );
textSubjectInformation.strGroup             = sprintf('%s:', textElements.strGroup);
textSubjectInformation.strStudyCode         = sprintf('%s:', textElements.strStudyCode);

end

function parametersSubjectInformationFigureElements = updateParametersSubjectInformationFigureElementsATWM1(parametersSubjectInformationFigureElements, parametersStudy, subjectInformation, textElements, textSubjectInformation)

global iStudy

%%% Define sheet title
parametersSubjectInformationFigureElements.strTitle                   = sprintf('%s', textElements.strSubjectInformation);

%%% Define study information to be displayed
parametersSubjectInformationFigureElements.strLegendStudyInformation  = sprintf('%s:\n%s:', textElements.strStudy, textElements.strPrincipalInvestigator);
parametersSubjectInformationFigureElements.strStudyInformation        = sprintf('%s\n%s', iStudy, parametersStudy.strPrincipalInvestigator);

aStrTextSubjectInformation = {
    textSubjectInformation.strEnrollmentDate
    textSubjectInformation.strSubjectNumber
    textSubjectInformation.strFirstName
    textSubjectInformation.strFamilyName
    textSubjectInformation.strDateOfBirth
    textSubjectInformation.strColorGroup
    textSubjectInformation.strGroup
    textSubjectInformation.strStudyCode
    };

aStrSubjectInformation = {
    subjectInformation.strDateOfStudyEnrollment
    subjectInformation.strSubjectNumber
    subjectInformation.strFirstName
    subjectInformation.strFamilyName
    subjectInformation.strDateOfBirth
    subjectInformation.strSelectedColorGroup
    subjectInformation.strSelectedShortGroup
    subjectInformation.strSubjectCode
    };

parametersSubjectInformationFigureElements.strLegendSubjectInformation = '';
for ctsi = 1:numel(aStrTextSubjectInformation)
    parametersSubjectInformationFigureElements.strLegendSubjectInformation = sprintf('%s\n\n%s', parametersSubjectInformationFigureElements.strLegendSubjectInformation, aStrTextSubjectInformation{ctsi});
end

parametersSubjectInformationFigureElements.strSubjectInformation = '';
for csi = 1:numel(aStrSubjectInformation)
    parametersSubjectInformationFigureElements.strSubjectInformation = sprintf('%s\n\n%s', parametersSubjectInformationFigureElements.strSubjectInformation, aStrSubjectInformation{csi});
end

end


function hFigure = createFigureWithSubjectInformationATWM1(parametersSubjectInformationFigureElements)
%%% Create figure containing the subject information
hFigure = figure('Visible', parametersSubjectInformationFigureElements.visible);%('PaperType','A4')%('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])

%%% Set layout parameters for figure
set(gcf, 'PaperType', parametersSubjectInformationFigureElements.paperType)
set(gcf, 'color', parametersSubjectInformationFigureElements.backgroundColor);
set(gcf, 'PaperUnits', parametersSubjectInformationFigureElements.units);
set(gcf, 'PaperSize', parametersSubjectInformationFigureElements.paperSize);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 parametersSubjectInformationFigureElements.paperSize(1) parametersSubjectInformationFigureElements.paperSize(2)])

end

function addTextBoxesToSubjectInformationFigureATWM1(parametersSubjectInformationFigureElements);

%%% Textbox containing the figure title
textBoxTitle            = annotation('textbox');
textBoxTitle.String     = parametersSubjectInformationFigureElements.strTitle;
textBoxTitle.FontSize   = parametersSubjectInformationFigureElements.fontSizeTitle;
textBoxTitle.Units      = parametersSubjectInformationFigureElements.units;
textBoxTitle.Position   = [parametersSubjectInformationFigureElements.Position.xBeginLeft 1.5 6.0 3.0];
textBoxTitle.LineStyle  = parametersSubjectInformationFigureElements.lineStyle;
textBoxTitle.FontName   = parametersSubjectInformationFigureElements.font;
textBoxTitle.FontWeight = 'bold';

%%% Textbox containing legend for general study information
textBoxLegendStudyInformation       	= annotation('textbox');
textBoxLegendStudyInformation.String    = parametersSubjectInformationFigureElements.strLegendStudyInformation;
textBoxLegendStudyInformation.FontSize  = parametersSubjectInformationFigureElements.fontSize;
textBoxLegendStudyInformation.Units     = parametersSubjectInformationFigureElements.units;
textBoxLegendStudyInformation.Position  = [parametersSubjectInformationFigureElements.Position.xBeginLeft 2.0 7.0 2.0];
textBoxLegendStudyInformation.LineStyle = parametersSubjectInformationFigureElements.lineStyle;
textBoxLegendStudyInformation.FontName  = parametersSubjectInformationFigureElements.font;

%%% Textbox containing general study information
textBoxStudyInformation                 = annotation('textbox');
textBoxStudyInformation.String          = parametersSubjectInformationFigureElements.strStudyInformation;
textBoxStudyInformation.FontSize        = parametersSubjectInformationFigureElements.fontSize;
textBoxStudyInformation.Units           = parametersSubjectInformationFigureElements.units;
textBoxStudyInformation.Position        = [parametersSubjectInformationFigureElements.Position.xBeginRight 2.0 7.0 2.0];
textBoxStudyInformation.LineStyle       = parametersSubjectInformationFigureElements.lineStyle;
textBoxStudyInformation.FontName        = parametersSubjectInformationFigureElements.font;

%%% Textbox containing legend for subject information
textBoxLegendSubjectInformation             = annotation('textbox');
textBoxLegendSubjectInformation.String      = parametersSubjectInformationFigureElements.strLegendSubjectInformation;
textBoxLegendSubjectInformation.FontSize    = parametersSubjectInformationFigureElements.fontSize;
textBoxLegendSubjectInformation.Units       = parametersSubjectInformationFigureElements.units;
textBoxLegendSubjectInformation.Position    = [parametersSubjectInformationFigureElements.Position.xBeginLeft parametersSubjectInformationFigureElements.Position.ySubjectInformation 7.0 5.0];
textBoxLegendSubjectInformation.LineStyle   = parametersSubjectInformationFigureElements.lineStyle;
textBoxLegendSubjectInformation.FontName    = parametersSubjectInformationFigureElements.font;

%%% Textbox containing subject information
textBoxSubjectInformation                   = annotation('textbox');
textBoxSubjectInformation.String            = parametersSubjectInformationFigureElements.strSubjectInformation;
textBoxSubjectInformation.FontSize          = parametersSubjectInformationFigureElements.fontSize;
textBoxSubjectInformation.Units             = parametersSubjectInformationFigureElements.units;
textBoxSubjectInformation.Position          = [parametersSubjectInformationFigureElements.Position.xBeginRight parametersSubjectInformationFigureElements.Position.ySubjectInformation 7.0 5.0];
textBoxSubjectInformation.LineStyle         = parametersSubjectInformationFigureElements.lineStyle;
textBoxSubjectInformation.FontName          = parametersSubjectInformationFigureElements.font;


end


function addLogoToSubjectInformationFigureATWM1(parametersInstitutionLogo, parametersSubjectInformationFigureElements);

%%% Add hospital logo
image = imread(parametersInstitutionLogo.pathLogo);
hImage = imshow(image);

hImage.XData = [1 parametersInstitutionLogo.adjustedLogoSize(1)];
hImage.YData = [1 parametersInstitutionLogo.adjustedLogoSize(2)];

hImage.Parent.Units = parametersSubjectInformationFigureElements.units;

hImage.Parent.Position = parametersInstitutionLogo.positionLogo;

end


function bPrintSuccessful = printFigureWithSubjectInformationATWM1(hFigure, subjectInformation)
%%% Print figure containing subject information
nrOfPrintsOfSubjectInformationSheet = 2;
bPrintSuccessful = false;
while bPrintSuccessful == false
    %%% Open dialog to remind user to print two copies of subject
    %%% information sheet
    strMessage = sprintf('Please print %i copies of subject information sheet', nrOfPrintsOfSubjectInformationSheet);
    strDialogTitle = 'Prepare printing';
    h = msgbox(strMessage, strDialogTitle);
    pause(3)
    delete(h);
    
    %%% Open print dialog
    printpreview
    
    %%% Open dialog to check, whether print was successful
    strQuestion = sprintf('Printing of %i copies sucessful?', nrOfPrintsOfSubjectInformationSheet);
    strDialogTitle = 'Evaluate printing result';
    strEmpty = '     ';
    strYes = sprintf('%sYes%s', strEmpty, strEmpty);
    strNo = sprintf('%sNo%s', strEmpty, strEmpty);
    strAbort = sprintf('%sAbort%s', strEmpty, strEmpty);
    choice = questdlg(strQuestion, strDialogTitle, strYes, strNo, strAbort, strAbort);
    
    switch choice
        case strYes
            strMessage = sprintf('Print of subject information sheet for subject %s successful!', subjectInformation.strSubjectCode);
            disp(strMessage);
            bPrintSuccessful = true;
        case strNo
            strMessage = sprintf('Print not successful!\nRestarting print process.');
            disp(strMessage);
            bPrintSuccessful = false;
        case strAbort
            strMessage = sprintf('Printing aborted by user!');
            disp(strMessage);
            close(hFigure)
            bPrintSuccessful = false;
            return
    end
end

end


function createBarcodeFileATWM1(subjectInformation, pathSubjectCodeOutputFile)
global iStudy
global m_cfg

%%% Generate barcode and file for printing
try
    %%% This function creates the global variable m_cfg
    hFunction = str2func(sprintf('barcodeGenerator%s', iStudy));
    feval(hFunction, subjectInformation.strSubjectCode);
catch
    delete(pathSubjectCodeOutputFile)
    strMessage = sprintf('Barcode file for subject %s could not be created!\nAborting function.', subjectInformation.strSubjectCode);
    error(strMessage);
end

if m_cfg.bCreateLabelSheetPDFSuccess == true
    strBarcodeLabelsPDF = m_cfg.strOutputLaTeXLabelsPDF;
else
    delete(pathSubjectCodeOutputFile)
    strMessage = sprintf('Barcode file for subject %s could not be created!\nAborting function.', subjectInformation.strSubjectCode);
    error(strMessage);
end


end


function pathBackupFile = createBackupOfSubjectArrayFileATWM1(folderDefinition, parametersStudy, aSubject, pathSubjectCodeOutputFile)
global iStudy
%%% Create backup of aSubject file before updating it
try
    hFunction = str2func(sprintf('backupArraySubjectFile%s', iStudy));
    [success, pathBackupFile] = feval(hFunction, folderDefinition, parametersStudy, aSubject);
catch
    delete(pathSubjectCodeOutputFile)
    strMessage = sprintf('Backup of subject array could not be created!\nAborting function.');
    error(strMessage);
end

if success ~= 1
    delete(pathSubjectCodeOutputFile)
    error('Backup file %s could not be created!\nAborting function.', pathBackupFile');
else
    strMessage = sprintf('Backup of %s created.', pathBackupFile);
    disp(strMessage);
end


end


function [pathSubjectArrayFile] = updateSubjectArrayFileATWM1(aSubject, subjectInformation, pathSubjectCodeOutputFile)
global iStudy

%%% Add new subject code to selected group in aSubject
try
    hFunction = str2func(sprintf('addNewSubjectCode%s', iStudy));
    [status, pathSubjectArrayFile] = feval(hFunction, aSubject);
catch
    delete(pathSubjectCodeOutputFile)
    error('File containing subject array could not be updated!');
end
    
if status ~= 0
    delete(pathSubjectCodeOutputFile);
    delete(strBarcodeLabelsPDF);
    error('File %s could not be created!', pathSubjectArrayFile);
else
    strMessage = sprintf('Added subject code %s to file %s.', subjectInformation.strSubjectCode, pathSubjectArrayFile);
    disp(strMessage);
end


end


function confirmEnrollmentOfSubjectATWM1(subjectInformation)
global iStudy

%%% Confirm successful enrollment of subject
strMessage = sprintf('\nSubject %s successfully enrolled in study %s!', subjectInformation.strSubjectCode, iStudy);
strDialogTitle = 'Enrollment completed';
h = msgbox(strMessage, strDialogTitle);
pause(10)
delete(h);
disp(strMessage);


end