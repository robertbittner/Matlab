function aAdditionalSubjectInformation = processAdditionalSubjectInformationATWM1_IMAGING(bAddDataOfNewSubject, aStrNewData);

global iStudy
iStudy = 'ATWM1';

folderDefinition        = folderDefinitionATWM1;
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersSubjectStatus = eval(['parametersSubjectStatus', iStudy]);

aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);

%%
%%% Remove
aStrNewData = {'010'   'DB78TNB'   'CON'   'LR'   'P8'   '03.05.2016' 'INCL' parametersSubjectStatus.strSubjectIncluded 'INCL' parametersSubjectStatus.strSubjectIncluded};
bAddDataOfNewSubject = true;
%%% Remove
%%

if ~exist('bAddDataOfNewSubject', 'var') || ~exist('aStrNewData', 'var')
    bAddDataOfNewSubject = false;
end


hFunction = str2func(sprintf('aAdditionalSubjectInformation%s_%s', iStudy, parametersStudy.strImaging));
[aAdditionalSubjectInformation] = feval(hFunction);

if ~isequal(aSubject.ATWM1_IMAGING.nSubjects, aAdditionalSubjectInformation.nSubjects)
    error('Number of subjects in aSubject and aAdditionalSubjectInformation does not match.');
end


%% Read row definitions as written above the data table
strFile = fullfile('D:\Daten\ATWM1\Study_Parameters\', 'aAdditionalSubjectInformationATWM1_IMAGING.m');
fid = fopen(strFile, 'rt');
discard = fgetl(fid);
discard = fgetl(fid);
strAllRowDefinitions = fgetl(fid);

for cr = 1:aAdditionalSubjectInformation.nrOfRows
    aAdditionalSubjectInformation.aStrRowLabel{cr} = sprintf('row%i: ', cr);
    indexStart = strfind(strAllRowDefinitions, aAdditionalSubjectInformation.aStrRowLabel{cr}) + length(aAdditionalSubjectInformation.aStrRowLabel{cr});
    if cr < aAdditionalSubjectInformation.nrOfRows
        indexEnd = strfind(strAllRowDefinitions, aAdditionalSubjectInformation.strTableDelimiter);
        indexEnd = indexEnd(indexEnd>indexStart);
        indexEnd = indexEnd(1) - 1;
        aAdditionalSubjectInformation.aStrRowDefinitionReadout{cr} = strAllRowDefinitions(indexStart:indexEnd);
    else
        aAdditionalSubjectInformation.aStrRowDefinitionReadout{cr} = strAllRowDefinitions(indexStart:end);
    end
end
fclose(fid);

if ~isempty(setdiff(aAdditionalSubjectInformation.aStrRowDefinition, aAdditionalSubjectInformation.aStrRowDefinitionReadout))
    strMessage = sprintf('Row definitions above the table do not match row definitions as defined in field ''aStrRowDefinition'' ');
    error(strMessage);
end

%% Read information from individual rows
for cr = 1:aAdditionalSubjectInformation.nrOfRows
    strRowDefinition = aAdditionalSubjectInformation.aStrRowDefinitionReadout{cr};
    for cs = 1:aAdditionalSubjectInformation.nSubjects
        aAdditionalSubjectInformation.(genvarname(strcat('aStr', strRowDefinition))){cs} = aAdditionalSubjectInformation.fullTable{cs}{cr};
    end
end

%% Add new data
if bAddDataOfNewSubject == true
    aAdditionalSubjectInformation = addDataOfNewSubjectToSubjectInformationFileATWM1(aAdditionalSubjectInformation, aStrNewData);
    updateAdditionalSubjectInformationFileATWM1(folderDefinition, aAdditionalSubjectInformation);
    strMessage = sprintf('sds');
    disp(strMessage);
end

end


function aAdditionalSubjectInformation = addDataOfNewSubjectToSubjectInformationFileATWM1(aAdditionalSubjectInformation, aStrNewData);
%%% Add data of an additional subject
aAdditionalSubjectInformation.nSubjects = aAdditionalSubjectInformation.nSubjects + 1;
for cr = 1:aAdditionalSubjectInformation.nrOfRows
    strRowDefinition = aAdditionalSubjectInformation.aStrRowDefinition{cr};
    strNewData = aStrNewData{cr};
    aAdditionalSubjectInformation.(genvarname(strcat('aStr', strRowDefinition))){aAdditionalSubjectInformation.nSubjects + 1;} = strNewData;
end

end

function updateAdditionalSubjectInformationFileATWM1(folderDefinition, aAdditionalSubjectInformation);
%%% Update AdditionalSubjectInformationFile

strThreePercentSigns = sprintf('%%%%%%');

strNewFile = sprintf('aAdditionalSubjectInformationATWM1_IMAGING_NEW.m');
pathNewFile = fullfile(folderDefinition.studyParameters, strNewFile);
fid = fopen(pathNewFile, 'wt');

strFunctionHeader = sprintf('function aAdditionalSubjectInformation = aAdditionalSubjectInformationATWM1_IMAGING();');
fprintf(fid, '%s', strFunctionHeader);
fprintf(fid, '\n');

%%
strRowDefintionPart1 = sprintf('%s Row definition', strThreePercentSigns);
fprintf(fid, '%s', strRowDefintionPart1);
fprintf(fid, '\n');

strRowDefintionPart2 = sprintf('%s ', strThreePercentSigns);
fprintf(fid, '%s', strRowDefintionPart2);
for cr = 1:aAdditionalSubjectInformation.nrOfRows
    strRowDefintionPart2 = sprintf('%s%s%s', aAdditionalSubjectInformation.aStrRowLabel{cr}, aAdditionalSubjectInformation.aStrRowDefinitionReadout{cr});
    fprintf(fid, '%s', strRowDefintionPart2);
    if cr < aAdditionalSubjectInformation.nrOfRows
        strTableDelimiter = sprintf('%s', aAdditionalSubjectInformation.strTableDelimiter);
        fprintf(fid, '%s', strTableDelimiter);
    end
end
fprintf(fid, '\n');

%%
strFieldStart = sprintf('aAdditionalSubjectInformation.fullTable	= {');
fprintf(fid, '%s', strFieldStart);
fprintf(fid, '\n');

for cs = 1:aAdditionalSubjectInformation.nSubjects
    strDataRow = '';
    for cr = 1:aAdditionalSubjectInformation.nrOfRows
        strRowDefinition = aAdditionalSubjectInformation.aStrRowDefinitionReadout{cr};
        strData = aAdditionalSubjectInformation.(genvarname(strcat('aStr', strRowDefinition))){cs};
        %%% Create new data row from added data
        strDataRow = sprintf('%s''%s''', strDataRow, strData);
        if cr < aAdditionalSubjectInformation.nrOfRows
            strDataRow = sprintf('%s%s', strDataRow, aAdditionalSubjectInformation.strTableDelimiter);
        end
    end
    fprintf(fid, '\t{%s}', strDataRow);
    fprintf(fid, '\n');
end

strFieldEnd = sprintf('\t};');
fprintf(fid, '%s', strFieldEnd);
fprintf(fid, '\n');

%%
for cl = 1:20
    fprintf(fid, '\n');
end

%%
strVariable = sprintf('aAdditionalSubjectInformation.nSubjects = numel(aAdditionalSubjectInformation.fullTable);');
fprintf(fid, '%s', strVariable);
fprintf(fid, '\n');

fprintf(fid, '\n');

strFieldStart = sprintf('aAdditionalSubjectInformation.aStrRowDefinition	= {');
fprintf(fid, '%s', strFieldStart);
fprintf(fid, '\n');

for cr = 1:aAdditionalSubjectInformation.nrOfRows
    strRowDefinition = sprintf('''%s''', aAdditionalSubjectInformation.aStrRowDefinition{cr});
        fprintf(fid, '\t%s', strRowDefinition);
    fprintf(fid, '\n');
end

strFieldEnd = sprintf('\t};');
fprintf(fid, '%s', strFieldEnd);
fprintf(fid, '\n');

fprintf(fid, '\n');

%%
strVariable = sprintf('aAdditionalSubjectInformation.aAdditionalSubjectInformation.nrOfRows = size(aAdditionalSubjectInformation.fullTable{end});');
fprintf(fid, '%s', strVariable);
fprintf(fid, '\n');

strVariable = sprintf('aAdditionalSubjectInformation.aAdditionalSubjectInformation.nrOfRows = aAdditionalSubjectInformation.aAdditionalSubjectInformation.nrOfRows(2);');
fprintf(fid, '%s', strVariable);
fprintf(fid, '\n');

fprintf(fid, '\n');

strVariable = sprintf('aAdditionalSubjectInformation.strTableDelimiter = ''%s'';', aAdditionalSubjectInformation.strTableDelimiter);
fprintf(fid, '%s', strVariable);
fprintf(fid, '\n');


fprintf(fid, '\n');
fprintf(fid, 'end');
fclose(fid);


end