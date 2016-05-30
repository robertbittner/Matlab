function behavioralData = readBehavioralDataFromPresentationLogFilesWM_CAP(indexStudy, pathDefinition, parametersStudy, parametersParadigm, indexSubject);
%%% Study: WMC2 WM_CAP
%%% Reads the responses from Presentation logfiles
%%% To add: reading of reaction times



behavioralData.response = '';
behavioralData.reactionTime = '';

i = 0;
for indexSession = 1:parametersParadigm.nSessions
    
    logFile = [indexSubject, '_', parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '_', parametersParadigm.indexSession, num2str(indexSession), parametersParadigm.logFileExtension];

    fid = fopen([pathDefinition.logFiles, logFile], 'rt');  % rt: t steht für Zeilenumbruchkompatibiiltät zwischen WINDOWS und Linux
    if fid == -1
        fprintf('Datei ''%s'' nicht gefunden\n', logFile);     
        continue
    end

    for l = 1:5
        discard = fgetl (fid);
    end


%%% Reads the responses from Presentation logfiles        
    lineIndexRetrieval = [];
    indexRetrievalOnset = [];

    while ~feof(fid)      
        line = fgetl(fid);
        if isempty(line)
            continue
        end
        text = textscan(line, '%*s %f %s %s %*[^\n]');

        
        %%% text{1} should contain the 'Trial' value of Presentation in the
        %%% relevant lines. 
        %%% text{2} should contain the 'Event' type in the relevant lines. 
        %%% text{3} should contain the actual response by the subjects in
        %%% the relevant lines. 
        %%% The following variables are for test purposes only.
        %%%
        %%% test1 = text{1}
        %%% test2 = text{2}
        %%% test3 = text{3}
        
        if strcmp(text{3}, parametersParadigm.indexStartOfTrials) == 1
            i = i + 1;
            lineIndexStartOfTrial{i}= text{1};
            lineIndexRetrieval = lineIndexStartOfTrial{i} + parametersParadigm.intervallAlertRetrieval;
        end
        
        %%% Lines containing the trial specification are detected and the
        %%% the trial specification and other relevant parameters are
        %%% stored.  
        if isempty(strfind(line, parametersParadigm.indexTrialSpecification))

        else
            trialSpecification = textscan(line, '%*s %*f %*s %s %*[^\n]');
            trialSpecification = trialSpecification{1}{1};
            separatorIndex = strfind(trialSpecification, '_');

            startIndex = strfind(trialSpecification, parametersParadigm.indexTrialSpecification);
            endIndex = length(trialSpecification);
            behavioralData.trialSpecification{i} = trialSpecification(startIndex:endIndex);
            behavioralData.wmLoad{i} = trialSpecification(startIndex + length(parametersParadigm.indexTrialSpecification) + 1);
            
            %{
            startIndex = separatorIndex(5) + 1;
            endIndex = separatorIndex(6) - 1;
            behavioralData.changeIndex{i} = trialSpecification(startIndex:endIndex);
            %}
            %{
            startIndex = separatorIndex(9) + 1;
            endIndex = separatorIndex(10) - 1;
            behavioralData.intervallInterStimulus{i} = trialSpecification(startIndex:endIndex);
            %}
            %{
            startIndex = separatorIndex(3) + 1;
            endIndex = separatorIndex(4) - 1;
            behavioralData.mask{i} = trialSpecification(startIndex:endIndex);
            %}
            %{
            startIndex = separatorIndex(7) + 1;
            endIndex = separatorIndex(8) - 1;
            behavioralData.intervallPreparation{i} = trialSpecification(startIndex:endIndex);
            %}
            %{
            startIndex = separatorIndex(8) + 1;
            endIndex = separatorIndex(9) - 1;
            behavioralData.intervallEncoding{i} = trialSpecification(startIndex:endIndex);
            %}
            %{
            startIndex = separatorIndex(10) + 1;
            endIndex = length(trialSpecification);
            behavioralData.intervallMaintenance{i} = trialSpecification(startIndex:endIndex);
            %}
            %{
            startIndex = separatorIndex(6) + 1;
            endIndex = separatorIndex(7) - 1;
            behavioralData.intervallInterTrial{i} = trialSpecification(startIndex:endIndex);
            %}
        end
        
               
        if text{1} == lineIndexRetrieval;

            indexRetrievalOnset = 1;
            trialSpec = text{3};
            changeIndex = textscan(line, '%s %*[^\n]');
            
            %%% This definition of the change index can be removed, once
            %%% the change index is included in the trial definiton. 
            changeIndex = textscan(line, '%*s %*f %*s %s %*s %*[^\n]');
            changeIndex = changeIndex{1}{1};
            separatorIndex = strfind(changeIndex, '_');
            %test1 = length(changeIndex)
            %test = changeIndex(separatorIndex:test1)
            changeIndex = changeIndex(separatorIndex + 1:length(changeIndex));
            behavioralData.changeIndex{i} = changeIndex;
            %tset = test{1:3}
            k = strfind(trialSpec, parametersParadigm.indexNoChange);
            if isempty(k{1})
                trialType{i} = parametersParadigm.indexChange;
                correctResponse{i} = parametersParadigm.changeResponse;
            else
                trialType{i} = parametersParadigm.indexNoChange;
                correctResponse{i} = parametersParadigm.noChangeResponse;
            end
            %test = correctResponse{i}
            lineIndexRetrieval = 0;
        end
        %txtContent = text{2}
        %txtComp = parametersParadigm.indexResponse
        if strcmp(text{2}, parametersParadigm.indexResponse) == 1
            %displayText = indexRetrievalOnset
            if indexRetrievalOnset == 1;            %%% Testing, whether a response button was pressed during retrieval or during another task phase
                indexRetrievalOnset = 0;
                lineIndexResponse{i} = text{1};
                response{i} = text{3};
                %actualResponse = response{i}%text{3}

                if strcmp(response{i}, correctResponse{i}) == 1
                    behavioralData.response{i} = 1;
                else
                    behavioralData.response{i} = 0;
                    %actualResponse = response{i}
                    %corrResponse = correctResponse{i}
                end
                
                %%% This creates dummy values for reaction times, which
                %%% need to be changed to the calculation of the actual
                %%% reaction times. 
                behavioralData.reactionTime{i} = 1234;
            end
        end
    end
    fclose (fid);
end


%%% Process missing answers
for i = 1:length(behavioralData.response)
    if isempty(behavioralData.response{i})
        behavioralData.response{i} = -1;
    end
end

