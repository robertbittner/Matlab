function [aStrBarcodeFile, aStrSubjectBarcode, nrOfBarcodeFiles] = readBarcodeFileNamesATWM1();

global iStudy

folderDefinition        = eval(['folderDefinition', iStudy]);
%parametersStudy         = eval(['parametersStudy', iStudy]);
%parametersGroups        = eval(['parametersGroups', iStudy]);
%parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);
parametersBarcode       = eval(['parametersBarcode', iStudy]);


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