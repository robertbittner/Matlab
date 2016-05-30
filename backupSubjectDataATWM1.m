function backupSubjectDataATWM1();

clear all
clc

global iStudy

iStudy = 'ATWM1';

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);
%parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);
%parametersBarcode       = eval(['parametersBarcode', iStudy]);

%{
parametersBarcode.extPdf = '.pdf';
parametersBarcode.strBarcode = 'Barcodes';
parametersBarcode.lengthBarcode = 7;
parametersBarcode.lengthBarcodeFileName = parametersBarcode.lengthBarcode + length(iStudy) + length(parametersBarcode.strBarcode) + length(parametersBarcode.extPdf) + 2;

parametersSubjectCode.extTxt = '.txt';
parametersSubjectCode.strSubjectCode = 'Subject_Code';
parametersSubjectCode.strExampleSubjectCode = 'ATWM1_Subject_Code_#001.txt';
parametersSubjectCode.lengthStudyCodeFileName = length(parametersSubjectCode.strExampleSubjectCode);
%}

%%% Check, whether all relevant local and server folders can be accessed
hFunction = str2func(sprintf('checkFolderAccess%s', iStudy));
bAllFoldersCanBeAccessed = feval(hFunction, folderDefinition);
if bAllFoldersCanBeAccessed == false
    error('Folders for study %s cannot be accessed.', iStudy);
end

folderDefinition.strBackupFolderSubjectArray = strcat(folderDefinition.subjectInformationBackup, 'aSubject', '\');
folderDefinition.strBackupFolderAdditionalSubjectInformation = strcat(folderDefinition.subjectInformationBackup, 'aAdditionalSubjectInformation', '\');

folderDefinition.strBackupFolderBarcodes     = strrep(folderDefinition.barcodes, folderDefinition.study, folderDefinition.subjectInformationBackup);
folderDefinition.strBackupFolderSubjectCodes = strrep(folderDefinition.subjectCodes, folderDefinition.study, folderDefinition.subjectInformationBackup);

%%% Read subject information
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);
nrOfSubjects = aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL;
aStrAllSubjects = aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL;


[aStrBarcodeFile, aStrSubjectBarcode, nrOfBarcodeFiles] = readBarcodeFileNamesATWM1;
[aStrSubjectCodeFile, aStrSubjectCode, nrOfSubjectCodeFiles] = readSubjectCodeFileNamesATWM1;

checkFileAndSubjectIdConsistencyATWM1(aStrAllSubjects, aStrSubjectBarcode, aStrSubjectCode, nrOfSubjects, nrOfBarcodeFiles, nrOfSubjectCodeFiles);
[strSubjectArrayFile, strBackupSubjectArrayFile] = prepareSubjectArrayFileForBackupATWM1(folderDefinition, parametersStudy, nrOfSubjects);
[strAdditionalSubjectInformationFile, strBackupAdditionalSubjectInformationFile] = prepareAdditionalSubjectInformationFileForBackupATWM1(folderDefinition, parametersStudy, nrOfSubjects);

[aPathOriginalBarcodeFile, aPathBackupBarcodeFile, aPathOriginalSubjectCodeFile, aPathBackupSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile, bAbortBackup] = prepareFilesForBackupATWM1(folderDefinition, aStrBarcodeFile, aStrSubjectCodeFile, strSubjectArrayFile, strBackupSubjectArrayFile, strAdditionalSubjectInformationFile, strBackupAdditionalSubjectInformationFile, nrOfSubjects);
if bAbortBackup == true
    return
end

createLocalBackupOfSubjectInformationFilesATWM1(aPathOriginalBarcodeFile, aPathBackupBarcodeFile, aPathOriginalSubjectCodeFile, aPathBackupSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile, nrOfSubjects);
createServerBackupOfSubjectInformationFilesATWM1(aPathOriginalBarcodeFile, aPathBackupBarcodeFile, aPathOriginalSubjectCodeFile, aPathBackupSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile, nrOfSubjects, folderDefinition);


end


function [strSubjectArrayFile, strBackupSubjectArrayFile] = prepareSubjectArrayFileForBackupATWM1(folderDefinition, parametersStudy, nrOfSubjects);
global iStudy
% Check, whether subject array exists
strSubjectArrayFile = sprintf('aSubject%s_%s.m', iStudy, parametersStudy.strImaging);
pathSubjectArrayFile = strcat(folderDefinition.studyParameters, strSubjectArrayFile);

if ~exist(pathSubjectArrayFile, 'file')
    strMessage = sprintf('Could not find m-file %s containing subject informtion!\nAborting function.', pathSubjectArrayFile);
    error(strMessage);
end

strBackupSubjectArrayFile = sprintf('aSubject%s_%s__%03i_SUBJ.m', iStudy, parametersStudy.strImaging, nrOfSubjects);

end


function [strAdditionalSubjectInformationFile, strBackupAdditionalSubjectInformationFile] = prepareAdditionalSubjectInformationFileForBackupATWM1(folderDefinition, parametersStudy, nrOfSubjects);
global iStudy
% Check, whether subject array exists
strAdditionalSubjectInformationFile = sprintf('aAdditionalSubjectInformation%s_%s.m', iStudy, parametersStudy.strImaging);
pathAdditionalSubjectInformationFile = strcat(folderDefinition.studyParameters, strAdditionalSubjectInformationFile);

if ~exist(pathAdditionalSubjectInformationFile, 'file')
    strMessage = sprintf('Could not find m-file %s containing subject informtion!\nAborting function.', pathAdditionalSubjectInformationFile);
    error(strMessage);
end

strBackupAdditionalSubjectInformationFile = sprintf('aAdditionalSubjectInformation%s_%s__%03i_SUBJ.m', iStudy, parametersStudy.strImaging, nrOfSubjects);

end

%{
function [aStrBarcodeFile, aStrSubjectBarcode, nrOfBarcodeFiles] = readBarcodeFilesNamesATWM1(folderDefinition, parametersBarcode);

global iStudy

%%% Read files names of barcode files
strucBarcodeFiles = dir(folderDefinition.barcodes);
strucBarcodeFiles = strucBarcodeFiles(3:end);
nrOfBarcodeFiles = numel(strucBarcodeFiles);
%%% Ignore files, which do not fullfill the criteria for a barcode file
for cf = nrOfBarcodeFiles:-1:1
    if isempty(strfind(strucBarcodeFiles(cf).name, parametersBarcode.extPdf)) || isempty(strfind(strucBarcodeFiles(cf).name, strcat(iStudy, '_', parametersBarcode.strBarcode))) || ~isequal(parametersBarcode.lengthBarcodeFileName, length(strucBarcodeFiles(cf).name))
        strucBarcodeFiles(cf) = [];
    end
end
nrOfBarcodeFiles = numel(strucBarcodeFiles);
for cf = 1:nrOfBarcodeFiles
    aStrBarcodeFile{cf} = strucBarcodeFiles(cf).name;
    pathBarcodeFile = fullfile(folderDefinition.subjectCodes, aStrBarcodeFile{cf});
    iSeparator = strfind(aStrBarcodeFile{cf}, '_');
    iSeparator = iSeparator(1);
    strSubjectBarcode = aStrBarcodeFile{cf}(1 : iSeparator-1);
    aStrSubjectBarcode{cf} = strSubjectBarcode;
end
aStrSubjectBarcode = sort(aStrSubjectBarcode);


end
%}
%{
function [aStrSubjectCodeFile, aStrSubjectCode, nrOfSubjectCodeFiles] = readSubjectCodeFilesNamesATWM1(folderDefinition, parametersSubjectCode);

global iStudy

strucSubjectCodeFiles = dir(folderDefinition.subjectCodes);
strucSubjectCodeFiles = strucSubjectCodeFiles(3:end);
nrOfSubjectCodeFiles = numel(strucSubjectCodeFiles);
%%% Ignore files, which do not fullfill the criteria for a subject code
%%% file
for cf = nrOfSubjectCodeFiles:-1:1
    if isempty(strfind(strucSubjectCodeFiles(cf).name, parametersSubjectCode.extTxt)) || isempty(strfind(strucSubjectCodeFiles(cf).name, strcat(iStudy, '_', parametersSubjectCode.strSubjectCode))) || ~isequal(parametersSubjectCode.lengthStudyCodeFileName, length(strucSubjectCodeFiles(cf).name))
        strucSubjectCodeFiles(cf) = [];
    end
end
nrOfSubjectCodeFiles = numel(strucSubjectCodeFiles);
for cf = 1:nrOfSubjectCodeFiles
    aStrSubjectCodeFile{cf} = strucSubjectCodeFiles(cf).name;
    pathSubjectCodeFile = fullfile(folderDefinition.subjectCodes, aStrSubjectCodeFile{cf});
    fid = fopen(pathSubjectCodeFile, 'rt');
    while ~feof(fid)
        strLine = fgetl(fid);
        if strfind(strLine, parametersSubjectCode.strSubjectCodeText)
            strSubjectSubjectCode = strrep(strLine, parametersSubjectCode.strSubjectCodeText, '');
            strSubjectSubjectCode = strrep(strSubjectSubjectCode, ':', '');
            strSubjectSubjectCode = strtrim(strSubjectSubjectCode);
            aStrSubjectCode{cf} = strSubjectSubjectCode;
            break
        end
    end
    fclose(fid);
end
aStrSubjectCode = sort(aStrSubjectCode);

end
%}
%{
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
%}

function [aPathOriginalBarcodeFile, aPathBackupBarcodeFile, aPathOriginalSubjectCodeFile, aPathBackupSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile, bAbortBackup] = prepareFilesForBackupATWM1(folderDefinition, aStrBarcodeFile, aStrSubjectCodeFile, strSubjectArrayFile, strBackupSubjectArrayFile, strAdditionalSubjectInformationFile, strBackupAdditionalSubjectInformationFile, nrOfSubjects);
%%% Compare orginal files and backup files
bAbortBackup = false;
for cs = 1:nrOfSubjects
    % Compare barcode files
    strOriginalFile = aStrBarcodeFile{cs};
    pathOriginalFile = fullfile(folderDefinition.barcodes, strOriginalFile);
    pathBackupFile = fullfile(folderDefinition.strBackupFolderBarcodes, strOriginalFile);
    bAbortBackup = compareOriginalAndBackupFileATWM1(bAbortBackup, strOriginalFile, pathOriginalFile, pathBackupFile);
    aPathOriginalBarcodeFile{cs} = pathOriginalFile;
    aPathBackupBarcodeFile{cs} = pathBackupFile;
    
    % Compare subject code files
    strOriginalFile = aStrSubjectCodeFile{cs};
    pathOriginalFile = fullfile(folderDefinition.subjectCodes, strOriginalFile);
    pathBackupFile = fullfile(folderDefinition.strBackupFolderSubjectCodes, strOriginalFile);
    bAbortBackup = compareOriginalAndBackupFileATWM1(bAbortBackup, strOriginalFile, pathOriginalFile, pathBackupFile);
    aPathOriginalSubjectCodeFile{cs} = pathOriginalFile;
    aPathBackupSubjectCodeFile{cs} = pathBackupFile;
end
% Compare subject array file
strOriginalFile = strSubjectArrayFile;
pathOriginalFile = fullfile(folderDefinition.studyParameters, strOriginalFile);
pathBackupFile = fullfile(folderDefinition.strBackupFolderSubjectArray, strBackupSubjectArrayFile);
bAbortBackup = compareOriginalAndBackupFileATWM1(bAbortBackup, strOriginalFile, pathOriginalFile, pathBackupFile);
aPathOriginalSubjectArrayFile = pathOriginalFile;
aPathBackupSubjectArrayFile = pathBackupFile;

% Compare additional subject information file
strOriginalFile = strAdditionalSubjectInformationFile;
pathOriginalFile = fullfile(folderDefinition.studyParameters, strOriginalFile);
pathBackupFile = fullfile(folderDefinition.strBackupFolderAdditionalSubjectInformation, strBackupAdditionalSubjectInformationFile);
bAbortBackup = compareOriginalAndBackupFileATWM1(bAbortBackup, strOriginalFile, pathOriginalFile, pathBackupFile);
aPathOriginalAdditionalSubjectInformationFile = pathOriginalFile;
aPathBackupAdditionalSubjectInformationFile = pathBackupFile;

if bAbortBackup == true
    strMessage = 'Aborting backup!';
    waitfor(msgbox(strMessage));
    disp(strMessage);
end

end


function bAbortBackup = compareOriginalAndBackupFileATWM1(bAbortBackup, strOriginalFile, pathOriginalFile, pathBackupFile);

if exist(pathBackupFile, 'file')
    strucOriginalFile = dir(pathOriginalFile);
    strucBackupFile = dir(pathBackupFile);
    aStrFields = fieldnames(strucBackupFile);
    nrOfFields = numel(aStrFields);
    for cfield = 1:nrOfFields
        bFieldsMatch(cfield) = isequal(strucOriginalFile.(genvarname(aStrFields{cfield})), strucBackupFile.(genvarname(aStrFields{cfield})));
        % Special case of differing names for subject array file
        bFieldsMatch = compareSubjectArrayOriginalAndBackupFileATWM1(aStrFields, pathBackupFile, bFieldsMatch, cfield);
        % Special case of differing names for additional subject information file
        bFieldsMatch = compareAdditionalSubjectInformationOriginalAndBackupFileATWM1(aStrFields, pathBackupFile, bFieldsMatch, cfield);
    end
    if ~all(bFieldsMatch == true)
        bAbortBackup = true;
        strMessage = sprintf('Original version and backup version do not match for file:\n\n%s\n\n\n\n', strOriginalFile);
        for cfield = find(~bFieldsMatch)
            strFieldOrig = num2str(strucOriginalFile.(genvarname(aStrFields{cfield})));
            strFieldBack = num2str(strucBackupFile.(genvarname(aStrFields{cfield})));
            
            strOriginal = 'Original:';
            strBackup   = 'Backup:';
            
            strComparison = sprintf('%s\n%s   %s\n%s   %s\n\n', aStrFields{cfield}, strOriginal, strFieldOrig, strBackup, strFieldBack);
            strMessage = sprintf('%s%s', strMessage, strComparison);
        end
        strTitle = 'File mismatch detected during backup!';
        disp(strMessage);
        waitfor(msgbox(strMessage, strTitle));
    end
end

end


function bFieldsMatch = compareSubjectArrayOriginalAndBackupFileATWM1(aStrFields, pathBackupFile, bFieldsMatch, cfield);

% Prepare for special case of differing names for subject array file
indNameField = strfind(aStrFields, 'name');
indNameField(cellfun(@isempty, indNameField)) = {0};
indNameField = find(cell2mat(indNameField));
strSubjectArray = 'aSubject';

% Special case of differing names for subject array file
if cfield == indNameField && ~isempty(strfind(pathBackupFile, strSubjectArray))
    bFieldsMatch(cfield) = 1;
end


end


function bFieldsMatch = compareAdditionalSubjectInformationOriginalAndBackupFileATWM1(aStrFields, pathBackupFile, bFieldsMatch, cfield);

% Prepare for special case of differing names for subject array file
indNameField = strfind(aStrFields, 'name');
indNameField(cellfun(@isempty, indNameField)) = {0};
indNameField = find(cell2mat(indNameField));
strAdditionalSubjectInformationFile = 'aAdditionalSubjectInformation';

% Special case of differing names for subject array file
if cfield == indNameField && ~isempty(strfind(pathBackupFile, strAdditionalSubjectInformationFile))
    bFieldsMatch(cfield) = 1;
end


end


function createLocalBackupOfSubjectInformationFilesATWM1(aPathOriginalBarcodeFile, aPathBackupBarcodeFile, aPathOriginalSubjectCodeFile, aPathBackupSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile, nrOfSubjects);
bCreatedFileBackup = false;
%%% Backup barcode files
for cs = 1:nrOfSubjects
    if ~exist(aPathBackupBarcodeFile{cs}, 'file')
        copyfile(aPathOriginalBarcodeFile{cs}, aPathBackupBarcodeFile{cs});
        strMessage = sprintf('Creating local backup of file %s', aPathOriginalBarcodeFile{cs});
        disp(strMessage);
        bCreatedFileBackup = true;
    end
end
%%% Backup subject code files
for cs = 1:nrOfSubjects
    if ~exist(aPathBackupSubjectCodeFile{cs}, 'file')
        copyfile(aPathOriginalSubjectCodeFile{cs}, aPathBackupSubjectCodeFile{cs});
        strMessage = sprintf('Creating local backup of file %s', aPathOriginalSubjectCodeFile{cs});
        disp(strMessage);
        bCreatedFileBackup = true;
    end
end
%%% Backup subject array file
if ~exist(aPathBackupSubjectArrayFile, 'file')
    copyfile(aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile);
    strMessage = sprintf('Creating local backup of file %s', aPathOriginalSubjectArrayFile);
    disp(strMessage);
    bCreatedFileBackup = true;
end
%%% Backup additional subject information file
if ~exist(aPathBackupAdditionalSubjectInformationFile, 'file')
    copyfile(aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile);
    strMessage = sprintf('Creating local backup of file %s', aPathOriginalAdditionalSubjectInformationFile);
    disp(strMessage);
    bCreatedFileBackup = true;
end

if bCreatedFileBackup == true
    strMessage = sprintf('Local backup of subject data successful!\n');
    disp(strMessage);
else
    strMessage = sprintf('No local backup of subject data required!\n');
    disp(strMessage);
end


end



function createServerBackupOfSubjectInformationFilesATWM1(aPathOriginalBarcodeFile, aPathBackupBarcodeFile, aPathOriginalSubjectCodeFile, aPathBackupSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile, nrOfSubjects, folderDefinition);
bCreatedFileBackup = false;

%%% Define server backup paths
aPathBackupBarcodeFile                      = strrep(aPathBackupBarcodeFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
aPathBackupSubjectCodeFile                  = strrep(aPathBackupSubjectCodeFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
aPathBackupSubjectArrayFile                 = strrep(aPathBackupSubjectArrayFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
aPathBackupAdditionalSubjectInformationFile = strrep(aPathBackupAdditionalSubjectInformationFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);

%%% Backup barcode files
for cs = 1:nrOfSubjects
    if ~exist(aPathBackupBarcodeFile{cs}, 'file')
        copyfile(aPathOriginalBarcodeFile{cs}, aPathBackupBarcodeFile{cs});
        strMessage = sprintf('Creating server backup of file %s', aPathOriginalBarcodeFile{cs});
        disp(strMessage);
        bCreatedFileBackup = true;
    end
end
%%% Backup subject code files
for cs = 1:nrOfSubjects
    if ~exist(aPathBackupSubjectCodeFile{cs}, 'file')
        copyfile(aPathOriginalSubjectCodeFile{cs}, aPathBackupSubjectCodeFile{cs});
        strMessage = sprintf('Creating server backup of file %s', aPathOriginalSubjectCodeFile{cs});
        disp(strMessage);
        bCreatedFileBackup = true;
    end
end
%%% Backup subject array file
if ~exist(aPathBackupSubjectArrayFile, 'file')
    copyfile(aPathOriginalSubjectArrayFile, aPathBackupSubjectArrayFile);
    strMessage = sprintf('Creating server backup of file %s', aPathOriginalSubjectArrayFile);
    disp(strMessage);
    bCreatedFileBackup = true;
end
%%% Backup additional subject information file
if ~exist(aPathBackupAdditionalSubjectInformationFile, 'file')
    copyfile(aPathOriginalAdditionalSubjectInformationFile, aPathBackupAdditionalSubjectInformationFile);
    strMessage = sprintf('Creating server backup of file %s', aPathOriginalAdditionalSubjectInformationFile);
    disp(strMessage);
    bCreatedFileBackup = true;
end

if bCreatedFileBackup == true
    strMessage = sprintf('Server Backup of subject data successful!\n');
    disp(strMessage);
else
    strMessage = sprintf('No server backup of subject data required!\n');
    disp(strMessage);
end

end