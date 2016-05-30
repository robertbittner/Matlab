function writeBehavioralDataToMFileWM_CAP();
%%% Writes the behavioral data from psychophysical experiments of each
%%% subject into .m-files.
%%% To be added: writing the reaction times.

%%% Define the study index and set it to global
global indexStudy
global indexDataSource
indexStudy = 'WMC2';

%%% Determines, whether the parameters of the paradigm are extracted and
%%% written into a separate file.
writeParametersParadigm = 1;        %%% 0 = no      1 = yes


experimentNumber = 2;


dataSourceArray = {
    'Local Harddrive'
    'Beoserv1-t'
    };

[indexDataSource, OK]  = listdlg('ListString', dataSourceArray);
if OK == 0
    sprintf('No data source selected. Script cannot be executed properly')
else
    sprintf('Selected Data Source: %s', dataSourceArray{indexDataSource})
end



%%% This part loads the path definitions, parameters and subject names of
%%% the paradigm by calling different files as a function
pathDefinition      = eval(['pathDefinition', indexStudy]);
parametersStudy     = eval(['parametersStudy', indexStudy]);
subjectArray        = eval(['subjectArray', indexStudy]);

parametersStudy.experimentNumber = experimentNumber;

parametersParadigm  = eval(['parametersParadigm', parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber)]);


%%% The path definitions for logfiles and m-files containing the behavioral
%%% data are updated based on the specific experiment
pathDefinition.logFiles = [pathDefinition.logFiles, parametersStudy.indexWorkingMemoryCapacity, '\', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '\'];
pathDefinition.behavioralData = [pathDefinition.behavioralData, parametersStudy.indexWorkingMemoryCapacity, '\', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '\'];
%%{
for s = 1:length(subjectArray.(genvarname([parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics])))
    indexSubject = subjectArray.(genvarname([parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics])){s};
    
    %%% Now the behavioral data is read from the Presentation logfiles.
    behavioralData = eval(['readBehavioralDataFromPresentationLogFiles', parametersStudy.indexWorkingMemoryCapacity, '(indexStudy, pathDefinition, parametersStudy, parametersParadigm, indexSubject)']);
    
    behavioralDataFile = [indexSubject, '_', parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '_BehavioralData.m'];
    %%{
    %et = pathDefinition.behavioralData
    fid = fopen([pathDefinition.behavioralData, behavioralDataFile], 'wt');
    fprintf(fid, 'function behavioralData = %s()\n', behavioralDataFile(1:(length(behavioralDataFile)-2)));
    
    %%% The responses are written
    fprintf(fid, 'behavioralData.response = [\n');
    for i = 1:length(behavioralData.response)
        fprintf(fid, '\t%s\n', num2str(behavioralData.response{i}));
    end
    fprintf(fid, '];\n');
    
    fprintf(fid, '\n');
    
    %%% The reaction time is written
    fprintf(fid, 'behavioralData.reactionTime = [\n');
    for i = 1:length(behavioralData.reactionTime)
        fprintf(fid, '\t%s\n', num2str(behavioralData.reactionTime{i}));
    end
    
    
    fprintf(fid, '];\n');
    
    fclose (fid);
    %%}
end

%%% An m-file containing additional parameters of the paradigm is created
%%% if necessary
if writeParametersParadigm == 1
    parametersParadigmFile = sprintf('%sAdditionalParametersParadigm_%s_%s_%s%s.m', indexStudy, parametersStudy.indexWorkingMemoryCapacity, parametersStudy.indexPsychophysics, parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber));
    sprintf('File containing additional paradigm parameters is created: %s', parametersParadigmFile)
    fid = fopen([pathDefinition.studyParameters, parametersParadigmFile], 'wt');
    fprintf(fid, 'parametersParadigm.trialSpecification = {\n');
    for i = 1:length(behavioralData.trialSpecification)
        fprintf(fid, '\t''%s''\n', behavioralData.trialSpecification{i});
    end
    fprintf(fid, '};\n');
    
    fprintf(fid, '\n');
    
    fprintf(fid, 'parametersParadigm.wmLoad = [\n');
    for i = 1:length(behavioralData.wmLoad)
        fprintf(fid, '\t%s\n', behavioralData.wmLoad{i});
    end
    fprintf(fid, '];\n');
    
    fprintf(fid, '\n');
    
    fprintf(fid, 'parametersParadigm.changeIndex = {\n');
    for i = 1:length(behavioralData.changeIndex)
        fprintf(fid, '\t''%s''\n', behavioralData.changeIndex{i});
    end
    fprintf(fid, '};\n');
    
    fprintf(fid, '\n');
    %{
        fprintf(fid, 'parametersParadigm.intervallInterStimulus = [\n');
        for i = 1:length(behavioralData.intervallInterStimulus)
            fprintf(fid, '\t%s\n', behavioralData.intervallInterStimulus{i});
        end
        fprintf(fid, '];\n');
        
        fprintf(fid, '\n');

        fprintf(fid, 'parametersParadigm.mask = {\n');
        for i = 1:length(behavioralData.mask)
            fprintf(fid, '\t''%s''\n', behavioralData.mask{i});
        end
        fprintf(fid, '};\n');
        
        fprintf(fid, '\n');

        fprintf(fid, 'parametersParadigm.intervallPreparation = [\n');
        for i = 1:length(behavioralData.intervallPreparation)
            fprintf(fid, '\t%s\n', behavioralData.intervallPreparation{i});
        end
        fprintf(fid, '];\n');
        
        fprintf(fid, '\n');
        
        fprintf(fid, 'parametersParadigm.intervallEncoding = [\n');
        for i = 1:length(behavioralData.intervallEncoding)
            fprintf(fid, '\t%s\n', behavioralData.intervallEncoding{i});
        end
        fprintf(fid, '];\n');
        
        fprintf(fid, '\n');

        fprintf(fid, 'parametersParadigm.intervallMaintenance = [\n');
        for i = 1:length(behavioralData.intervallMaintenance)
            fprintf(fid, '\t%s\n', behavioralData.intervallMaintenance{i});
        end
        fprintf(fid, '];\n');
        
        fprintf(fid, '\n');

        fprintf(fid, 'parametersParadigm.intervallInterTrial = [\n');
        for i = 1:length(behavioralData.intervallInterTrial)
            fprintf(fid, '\t%s\n', behavioralData.intervallInterTrial{i});
        end
        fprintf(fid, '];\n');
    %}
    
    fprintf(fid, '\n');
    
    fclose(fid);
else
    
end
%}