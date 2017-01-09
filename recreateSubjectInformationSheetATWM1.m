function recreateSubjectInformationSheetATWM1();

clear all
clc

global iStudy
global m_cfg

iStudy = 'ATWM1';

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);
parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);

%{
%%% Check, whether all relevant local and server folders can be accessed
hFunction = str2func(sprintf('checkFolderAccess%s', iStudy));
bAllFoldersCanBeAccessed = feval(hFunction, folderDefinition);
if bAllFoldersCanBeAccessed == false
    error('Folders for study %s cannot be accessed.', iStudy);
end
%}

%%% Load text and dialog elements
[textElements, parametersDialog] = eval(['defineDialogTextElements', iStudy]);

%%% Open dialog to enter subject information
hFunction = str2func(sprintf('enterSubjectInformation%s', iStudy));
[subjectInformation] = feval(hFunction, parametersGroups, parametersDialog);
if isempty(subjectInformation)
    return
end

%%% Generate random subject code
hFunction = str2func(sprintf('generateSubjectCode%s', iStudy));
[aSubject, subjectInformation] = feval(hFunction, subjectInformation);

%%% Update aSubject and subjectInformation variables
hFunction = str2func(sprintf('updateSubjectInformation%s', iStudy));
[aSubject, subjectInformation] = feval(hFunction, aSubject, subjectInformation, parametersStudy, parametersGroups);

%%% Print sheet with subject information
try
    hFunction = str2func(sprintf('createAndPrintSubjectInformationSheet%s', iStudy));
    bPrintSuccessful = feval(hFunction, parametersStudy, textElements, subjectInformation);
catch
    strMessage = sprintf('Subject information could not be printed!\nAborting function.');
    disp(strMessage);
    return
end

if bPrintSuccessful == false
    strMessage = sprintf('Subject information could not be printed!\nAborting function.');
    disp(strMessage);
    return
end


%{
%%% Create output file with new subject code
try
    hFunction = str2func(sprintf('createOutputFileWithNewSubjectCode%s', iStudy));
    [pathSubjectCodeOutputFile, status] = feval(hFunction, folderDefinition, parametersSubjectCode, subjectInformation, textElements);
catch
    error('File containing subject code could not be created!');
end
if status ~= 0
    error('File %s could not be created!', pathSubjectCodeOutputFile);
end

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

strMessage = sprintf('\nSubject %s successfully enrolled in study %s!', subjectInformation.strSubjectCode, iStudy);
disp(strMessage);
%}

end

%{
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


function subjectInformation = enterSubjectInformationATWM1(parametersGroups, parametersDialog);

global iStudy

%%% Determine date of study enrollment (current date)
format shortg
currentTime = clock;
strCurrentDate = sprintf('%02i.%02i.%i', currentTime(3), currentTime(2), currentTime(1));%, currentTime(4), currentTime(5), currentSecond);

%%% While loop to insure, that the correct subject information has been
%%% entered.
bSubjectInformationCorrect = false;
bUpdateDefaultSubjectInformation = false;
while bSubjectInformationCorrect == false
    if bUpdateDefaultSubjectInformation == false
        %%% Dummy subject information
        subjectInformation.strFirstName     = 'First-Name';
        subjectInformation.strFamilyName    = 'Family-Name';
        subjectInformation.strDateOfBirth   = '01.01.1970';
    end
    
    hFunction = str2func(sprintf('createSubjectInformationDialog%s', iStudy));
    subjectInformation = feval(hFunction, parametersDialog, subjectInformation);
    if isempty(subjectInformation)
        return
    end
    
    hFunction = str2func(sprintf('createSubjectGroupDialog%s', iStudy));
    subjectInformation = feval(hFunction, parametersGroups, subjectInformation, strCurrentDate);
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

function subjectInformation = createSubjectGroupDialogATWM1(parametersGroups, subjectInformation, strCurrentDate);

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
subjectInformation.strDateOfStudyEnrollment = strCurrentDate;
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
aSubject.nPreviousSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects;
aSubjectsSelectedGroup = sort([aSubjectsSelectedGroup', subjectInformation.strSubjectCode])';

aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).(matlab.lang.makeValidName(subjectInformation.strSelectedShortGroup)) = aSubjectsSelectedGroup;
aSubject.nCurrentSubjects = aSubject.nPreviousSubjects + 1;
aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects = aSubject.nCurrentSubjects;

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

function [pathSubjectCodeOutputFile, status] = createOutputFileWithNewSubjectCodeATWM1(folderDefinition, parametersSubjectCode, subjectInformation, textElements);

global iStudy

%%% Create output file with new subject code
strSubjectCodeOutputFile = sprintf('%s_%s_#%s.txt', iStudy, parametersSubjectCode.strSubjectCode, subjectInformation.strSubjectNumber);
pathSubjectCodeOutputFile = strcat(folderDefinition.subjectCodes, strSubjectCodeOutputFile);

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

end


function bPrintSuccessful = createAndPrintSubjectInformationSheetATWM1(parametersStudy, textElements, subjectInformation);

global iStudy

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
bPrintSuccessful = false;
while bPrintSuccessful == false
    printpreview
    
    %%% Open dialog to check, whether print was successful
    strQuestion = sprintf('Print sucessful?');
    strDialogTitle = 'Evaluate print result';
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

%}
