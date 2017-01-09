function [strAvgPrtFile, strPathAvgPrtFile] = createEmptyPrtFileATWM1(parametersStudy, folderDefinition, parametersProjectFiles)
%%% Creates an empty protocol file which can for example be used during FMR
%%% creation for immediated linking.

global iStudy
global strSubject

if parametersProjectFiles.nrOfTotalRuns == 1
    strAvgPrtFile = sprintf('%s_%s_%s_avg.prt', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm);
else
    strAvgPrtFile = sprintf('%s_%s_%s_%s%i_avg.prt', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, parametersProjectFiles.iRunCurrentProject);
end
strPathAvgPrtFile = strcat(folderDefinition.strCurrentProjectDataSubFolder, strAvgPrtFile);

if ~exist(strPathAvgPrtFile, 'file')
    fprintf('Creating PRT for study: %s\t\tsubject: %s\t\trun: %i\n', iStudy, strSubject, parametersProjectFiles.iRunCurrentProject);
    try
        fid = fopen(strPathAvgPrtFile, 'wt');
        fprintf(fid, 'This PRT-file is currently an empty placeholder\n');
        fprintf(fid, 'Timing information needs to be entered separately\n');
        fclose(fid);
        fprintf('File %s was created.\n\n', strAvgPrtFile);
    catch
        fprintf('Error!\nFile %s could not be created!\n\n', strAvgPrtFile);
    end
else
    fprintf('File %s already exists!\n', strAvgPrtFile);
end

end