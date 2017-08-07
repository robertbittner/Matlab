function strucSubjCode = readSubjectsCodeFilesATWM1(folderDefinition, parametersGroups, varargin)

global iStudy

parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);

%%% Specify the source (Local PC or Server)
if isempty(varargin)
    strSource = folderDefinition.strLocal;
else
    strSource = varargin{1};
end

%%% Prepare search for subject code files
strSubjectCodeSearch = sprintf('%s_%s*%s', iStudy, parametersSubjectCode.strSubjectCode, parametersSubjectCode.extTxt);
%%% Determine source folder
if strcmp(strSource, folderDefinition.strLocal)
    strSubjectCodeSearch = strcat(folderDefinition.subjectCodes, strSubjectCodeSearch);
elseif strcmp(strSource, folderDefinition.strServer)
    strSubjectCodeSearch = strcat(folderDefinition.subjectCodesServer, strSubjectCodeSearch);
else
    error('No valid source for subject code files specified!');
end

%%% Search for subject code files
structSubjectCodeFiles = dir(strSubjectCodeSearch);
strucSubjCode.nrOfSubjectCodesFiles = numel(structSubjectCodeFiles);

%%% Open and read subject code files
for cs = 1:strucSubjCode.nrOfSubjectCodesFiles
    strucSubjCode.strPathSubjectCodeFile{cs} = fullfile(structSubjectCodeFiles(cs).folder, structSubjectCodeFiles(cs).name);
    fid = fopen(strucSubjCode.strPathSubjectCodeFile{cs}, 'rt');
    strLine = fgetl(fid);
    text = textscan(strLine, '%*s %*s %s');
    strucSubjCode.vSubjectNumber(cs) = str2double(cell2mat(text{1, 1}));
    strLine = fgetl(fid);
    text = textscan(strLine, '%*s %*s %s');
    strucSubjCode.aStrSubject{cs} = cell2mat(text{1, 1});
    strLine = fgetl(fid);
    text = textscan(strLine, '%*s %s');
    strucSubjCode.aStrLongGroup{cs} = cell2mat(text{1, 1});
    indGroup = strcmp(strucSubjCode.aStrLongGroup{cs}, parametersGroups.aStrLongGroups);
    strucSubjCode.aStrShortGroups{cs} = parametersGroups.aStrShortGroups{indGroup};
    fclose(fid);
end

end