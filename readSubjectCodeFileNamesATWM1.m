function [aStrSubjectCodeFile, aStrSubjectCode, nrOfSubjectCodeFiles] = readSubjectCodeFileNamesATWM1();

global iStudy

folderDefinition        = eval(['folderDefinition', iStudy]);
%parametersStudy         = eval(['parametersStudy', iStudy]);
%parametersGroups        = eval(['parametersGroups', iStudy]);
parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);
%parametersBarcode       = eval(['parametersBarcode', iStudy]);

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