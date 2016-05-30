function AnalyzeLogFile(strLogFilePath)        

    % Analyzes the log file trial per trial
    % Most important output variables:
    % 
    % *** Actual stimuli (paradigm parameters) *** 
    %
    % parametersParadigm.changeIndex
    % e.g. {'Change',
    %       'NoChange', % incorr. (response 20 instead of 10)
    %       'NoChange',
    %       'Change',
    %       'NoChange',
    %       'NoChange',
    %       'NoChange', % incorr. (response 20 instead of 10)
    %  }
    %
    %
    % *** Response evaluation *** 
    %
    % behavioralData.response
    % e.g. [1,0,1,1,1,1,0]
    % 1 = correct response, 0 = incorrect response, -1 = missing response
    % 
    %
    % *** Reaction times *** 
    %
    % behavioralData.reactionTime
    % [1.1814,0.8797,1.1139,1.12411,1.2344,0.7284,0.9825]
    % time between cue onset and response
        
    % test mode:
    % strLogFilePath = '/Users/mmb/MEG/ATWM1/PSYPHY/LogFiles/Test/TZNA88-ATWM1_PSYPHY_EXP1_condA_run1.log';
    % strLogFilePath = '/data/projects/ATWM1/PSYPHY/LogFiles/TZNA88-ATWM1_PSYPHY_EXP1_condC_run1.log';
    % strLogFilePath = '/data/projects/ATWM1/PSYPHY/LogFiles/TZNA88-ATWM1_PSYPHY_EXP1_condC_run2.log';
    % strLogFilePath = 'Z:\PSYPHY\LogFiles\Test\TZNA88-ATWM1_PSYPHY_EXP1_condA_run1.log';

    % global file handler for the log file
    % current position in the file is incremented line by line by several functions of this script
    global m_fileID;
 
    strOutputPath = strrep(strLogFilePath, '.log', '.mat');
    %m_fileID = fopen(strLogFilePath); 
    m_fileID = fopen(strLogFilePath, 'rt');
        
    strMessage = sprintf('Start analysis of %s', strLogFilePath);
    disp(strMessage);
    
    % ignore first header rows until second trial starts
    % (second means a '2_' in 2_6_Objects_EXP1_NonflickerBias_NoChange_Uncued_1500_1000_100_300_2000_2000)    
    % => ignore first two introduction examples in run 1 (0_6_Objects_ and 1_6_Objects_) and
    %    ignore first introduction example in run 2 (1_6_Objects_), 0_6_Objects_ is not used in run# > 1
    bFound = false;
    iCountRows = 0; % avoid infinite loop
    while ~bFound && iCountRows < 40
        strRow = fgetl(m_fileID);
        iCountRows = iCountRows + 1;
        if ~isempty(strfind(strRow,'1_6_Objects'))
            bFound = true;
        end
    end
     
    ProcessTrialsOfCurrentRun(strOutputPath);        
        
    fclose(m_fileID);  
end

function bEndOfFile = ProcessTrialsOfCurrentRun(strOutputPath)
  
    % sample from log file:
    %
    % Subject	Trial	Event Type	Code	Time	TTime	Uncertainty	Duration	Uncertainty	ReqTime	ReqDur	Stim Type	Pair Index
    % ...
    % TZNA88	16	Picture	ITI	455331	0	1	20159	2	0	20000	other	0
    % TZNA88	17	Picture	alert_cue	475657	0	1	10163	2	0	10000	other	0
    % TZNA88	18	Picture	preparation_time	485986	0	1	1167	2	0	1000	other	0
    % TZNA88	19	Picture	2_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	487319	0	1	3166	2	0	3000	other	0
    % TZNA88	19	Picture	2_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	490485	3166	1	2999	2	3000	3000	other	0
    % TZNA88	19	Picture	2_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	493484	6165	1	3165	2	6000	3000	other	0
    % TZNA88	20	Picture	delay	496816	0	1	20159	2	0	20000	other	0
    % TZNA88	21	Picture	EXP1_NoBias_NoChange_Cued	517142	0	1	20159	2	0	20000	other	0
    % TZNA88	21	Response	10	532874	15732	1
    % TZNA88	22	Picture	ITI	537468	0	1	20159	2	0	20000	other	0
    % TZNA88	23	Picture	alert_cue	557794	0	1	10163	2	0	10000	other	0
    % TZNA88	24	Picture	preparation_time	568123	0	1	1167	2	0	1000	other	0
    % TZNA88	25	Picture	3_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	569456	0	1	3166	2	0	3000	other	0
    % TZNA88	25	Picture	3_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	572622	3166	1	2999	2	3000	3000	other	0
    % ...
    % last two rows:
    % TZNA88	609	Response	20	8517333	10758	1
    % TZNA88	610	Picture	BaselinePost	8526901	0	1	20159	2	0	20000	other	0

    global m_fileID;
    bEndOfFile = false;
 
    % store all trials and their relevant log values in structure loggedTrialData
    allProcessedTrials = {};
    strLine = fgetl(m_fileID);
    [ bNewTrial, bIgnoreLine, bEndOfFile ] = GetTrialNum(strLine);
    currentTrialInfo = [];
    currentTrialInfo.iTrialNum = [];
    
    while 1 % instead of 'do while' statement   
   
        strLine = fgetl(m_fileID);
           
        [ bNewTrial, bIgnoreLine, bEndOfFile ] = GetTrialNum(strLine);
 
        if bNewTrial || bEndOfFile
            allProcessedTrials{end+1} = currentTrialInfo;
            currentTrialInfo = [];
            currentTrialInfo.iTrialNum = [];
        end

        [ currentTrialInfo ] = GetTrialInfo(strLine, currentTrialInfo);

        if bEndOfFile   
            break;
        end
    end    
                               
    % analyze responses and calculate reaction time etc.
    analyzedTrials = AnalyzeResponses(allProcessedTrials);
    % celldisp(analyzedTrialData);
    
    % output struct that is useful for further analysis with SPM
    SortConditionsAndOutput(analyzedTrials, strOutputPath);
    strMessage = sprintf('Results saved to %s', strOutputPath);
    disp(strMessage);
    
end

function [ bNewTrial, bIgnoreLine, bEndOfFile ] = GetTrialNum(strLine)

    global m_fileID;

    bIgnoreLine = false;
    bEndOfFile = feof(m_fileID);
    % new trial here is defined by alert_cue onset (after ITI, inter trial interval)
    bNewTrial = false; 
      
    if ~isempty(strfind(strLine,'BaselinePost'))
        bEndOfFile = true;
    end

    %if ~isempty(strfind(strLine,'alert_cue'))
    if ~isempty(strfind(strLine,'ITI'))
        bNewTrial = true;
    end
    
    % all lines of intereset contain the following strings:
    if isempty(strfind(strLine,'Change_')) && isempty(strfind(strLine,'Response')) 
        bIgnoreLine = true;
        return;
    end    
    
end


function [ trialInfo ] = GetTrialInfo(strLine, trialInfo)

    global m_fileID;

    bEndOfFile = feof(m_fileID);
     
    if ~isempty(strfind(strLine,'BaselinePost'))
        return;
    end
    
    % all lines of intereset contain the following strings:
    if isempty(strfind(strLine,'Change_')) && isempty(strfind(strLine,'Response')) 
        return;
    end    
    
    strText = textscan(strLine, '%s', 'Delimiter', '\t');
    
    if ~isempty(strfind(strLine,'Change_'))  

        strTrialCode = strText{1,1}{4};    
        strTrialCodeTokens = textscan(strTrialCode, '%s', 'Delimiter', '_');

        if ~isempty(strfind(strLine,'_Objects_'))  
            % line with full condition coding incl. trial number
            % e.g. TZNA88	13	Picture	1_6_Objects_EXP1_NoBias_NoChange_Uncued_1500_1000_100_300_2000_2000	411347	6165	1	3165	2	6000	3000	other	0
            strTrialNum = strTrialCodeTokens{1,1}{1};
            trialInfo.iTrialNum = str2num(strTrialNum);
        else
            % line with short condition coding
            % e.g. TZNA88	15	Picture	EXP1_NoBias_NoChange_Uncued	435005	0	1	20159	2	0	20000	other	0
            trialInfo.strBiasType = strTrialCodeTokens{1,1}{2};
            trialInfo.strChange = strTrialCodeTokens{1,1}{4};
            trialInfo.strCue = strTrialCodeTokens{1,1}{3}
            
            strPresentationTime = strText{1,1}{5};
            trialInfo.dbPresentationTime = str2num(strPresentationTime)/10000;        
            
            % init response time, in case there is no response found later
            trialInfo.dbResponseTime = [];
        end
    end
    
    if ~isempty(strfind(strLine,'Response')) && ~isempty(trialInfo.iTrialNum)
        % latter check is important, when response is delayed from previous trial / stimulus presentation,
        % but trial info was not set yet; theses delayed responses must be ignored
        % especially in case of a missing response in the current trial
        % (if the delayed response (that was too late) is used, there will be a negative reaction time)
        
        % line with actual response (values 10 or 20)
        % e.g. TZNA88	15	Response	10	445916	10911	1
        strResponseCode = strText{1,1}{4};
        trialInfo.iResponseCode = str2num(strResponseCode);          
        
        strResponseTime = strText{1,1}{5};
        trialInfo.dbResponseTime = str2num(strResponseTime)/10000;        
    end
    
end

function analyzedTrialData = AnalyzeResponses(loggedTrialData)

    analyzedTrialData = {};
    
    for iTrial = 1:size(loggedTrialData,2)

        analyzedTrialData{end+1} = AnalyzeTrial(loggedTrialData{iTrial});
        
    end
    
end

function [ trialInfo ] = AnalyzeTrial(trialInfo)

    % TZNA88	17	Picture	alert_cue	475657	0	1	10163	2	0	10000	other	0
    % TZNA88	18	Picture	preparation_time	485986	0	1	1167	2	0	1000	other	0
    % TZNA88	19	Picture	2_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	487319	0	1	3166	2	0	3000	other	0
    % TZNA88	19	Picture	2_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	490485	3166	1	2999	2	3000	3000	other	0
    % TZNA88	19	Picture	2_6_Objects_EXP1_NoBias_NoChange_Cued_2000_1000_100_300_2000_2000	493484	6165	1	3165	2	6000	3000	other	0
    % TZNA88	20	Picture	delay	496816	0	1	20159	2	0	20000	other	0
    % TZNA88	21	Picture	EXP1_NoBias_NoChange_Cued	517142	0	1	20159	2	0	20000	other	0
    % TZNA88	21	Response	10	532874	15732	1
    % TZNA88	22	Picture	ITI	537468	0	1	20159	2	0	20000	other	0
    % TZNA88	23	Picture	alert_cue	557794	0	1	10163	2	0	10000	other	0
  
    % 1_6_Objects_EXP1_FlickerBias_Change_Cued_2000_1000_100_300_2000_2000
    %  Tokens:
    %  1: trial num
    %  2: num of objects ('working memory load')
    %  3: 'Objects' (fixed string)
    %  4: EXP1 (experiment number)
    %  5: FlickerBias
    %  6: Change
    %  7: Cued
    %  8: intertrial interval
    %  9: alertTime
    % 10: preparationTime
    % 11: encodingTime
    % 12: delayTime
    % 13: retrievalTime
    
     % add reaction time
    trialInfo.dbReactionTime = NaN;
    trialInfo.correct = -1;
    
    if ~isempty(trialInfo.dbResponseTime)
        
        trialInfo.dbReactionTime = trialInfo.dbResponseTime - trialInfo.dbPresentationTime;
        
        if strcmp('Change', trialInfo.strChange)
           if  trialInfo.iResponseCode == 20
               trialInfo.correct = 1;
           else
               trialInfo.correct = 0;
           end
        end
        
        if strcmp('NoChange', trialInfo.strChange)
           if  trialInfo.iResponseCode == 10
               trialInfo.correct = 1;
           else
               trialInfo.correct = 0;
           end
        end        
    end
    
end

function SortConditionsAndOutput(analyzedTrials, strOutputPath)

    % correct responses
    response = [];  % 1 = correct, 0 = incorrect, -1 = no response
    reactionTime = []; 
    
    % collect already extracted paradigm parameters
    % e.g. TZNA88	15	Picture	EXP1_NoBias_NoChange_Uncued	435005	0	1	20159	2	0	20000	other	0   
    changeConditions = {}; % 'Change', 'NoChange'
    changeIndex = [];      % 1 (='Change'), 0 (='NoChange')
    cues = {};
    biastype = {};
    presentationTimes = [];
    trialnums = [];
    
    response_Change = [];
    response_NoChange = [];
    reactionTime_Change = [];
    reactionTime_NoChange = [];
        
    for iTrial = 1:size(analyzedTrials,2)

        
        if analyzedTrials{iTrial}.dbReactionTime > 2.0000
            analyzedTrials{iTrial}.correct = -1; % missed response
            analyzedTrials{iTrial}.dbReactionTime = NaN;
        end

        iCorrectResponse = analyzedTrials{iTrial}.correct;
        dbReactionTime = analyzedTrials{iTrial}.dbReactionTime;

        response = [ response iCorrectResponse ];
        reactionTime = [ reactionTime dbReactionTime ];
        
        trialnums = [ trialnums analyzedTrials{iTrial}.iTrialNum ];
        strChange = analyzedTrials{iTrial}.strChange;
        changeConditions{end+1} = strChange;
        cues{end+1} = analyzedTrials{iTrial}.strCue;
        biastype{end+1} = analyzedTrials{iTrial}.strBiasType;
        presentationTimes = [ presentationTimes analyzedTrials{iTrial}.dbPresentationTime ];
        
        if strcmp(strChange,'Change') 
            changeIndex = [ changeIndex 1 ];
        else     
            changeIndex = [ changeIndex 0 ];
        end
    end
      
    behavioralData.response = response;
    behavioralData.reactionTime = reactionTime;
       
    parametersParadigm.trialNumbers = trialnums;
    parametersParadigm.cues = cues;
    parametersParadigm.biastype = biastype;
    parametersParadigm.presentationTimes = presentationTimes;
    parametersParadigm.changeConditions = changeConditions;           
    parametersParadigm.changeIndex = changeIndex;           
    
    [ parametersParadigm, behavioralData ] = BalanceConditions( parametersParadigm, behavioralData );
    
    % add simple statistics and cowansK
    
    % hitrate (correctly identifying an identical array = accuracy NoChange condition)
    % -> correct / total number of NoChange trials (missing trials = incorrect)
    numNoChangeTrials = length(behavioralData.response_NoChange);
    numCorrectNoChangeTrials = length(find(behavioralData.response_NoChange==1));
    hitRate = numCorrectNoChangeTrials / numNoChangeTrials;
    
    % correct rejections (correctly identifying a change in an array = accuracy change condition)
    % -> correct / total number of Change trials (missing trials = incorrect)
    numChangeTrials = length(behavioralData.response_Change);
    numCorrectChangeTrials = length(find(behavioralData.response_Change==1));
    correctRejections = numCorrectChangeTrials / numChangeTrials;

    % number of items presented in array (working memory load)
    wmLoad = 3;  
    cowansK = wmLoad * ( hitRate + correctRejections - 1);

    statisticalData.hitRate = hitRate;
    statisticalData.correctRejections = correctRejections;
    statisticalData.wmLoad = wmLoad;
    statisticalData.cowansK = cowansK;
    statisticalData.numCorrectNoChangeTrials = numCorrectNoChangeTrials;
    statisticalData.numCorrectChangeTrials = numCorrectChangeTrials;
    statisticalData.numNoChangeTrials = numNoChangeTrials;
    statisticalData.numChangeTrials = numChangeTrials;

	save(strOutputPath, 'behavioralData', 'parametersParadigm', 'statisticalData'); 
    
end

function [ parametersParadigm, behavioralData ] = BalanceConditions( parametersParadigm, behavioralData )

    indicesChange = find(parametersParadigm.changeIndex == 1);
    indicesNoChange = find(parametersParadigm.changeIndex == 0);
    
    if length(indicesChange) > length(indicesNoChange)
        iElementToRemove = indicesChange(1);
        indicesChange = indicesChange(2:end);
    end    
    
    if length(indicesChange) < length(indicesNoChange)
        iElementToRemove = indicesNoChange(1);
        indicesNoChange = indicesNoChange(2:end);
    end
    
    behavioralData.response_Change = behavioralData.response(indicesChange);
    behavioralData.reactionTime_Change = behavioralData.reactionTime(indicesChange);
    
    behavioralData.response_NoChange = behavioralData.response(indicesNoChange);
    behavioralData.reactionTime_NoChange = behavioralData.reactionTime(indicesNoChange);
    
    if length(indicesChange) ~= length(indicesNoChange)
        parametersParadigm.trialNumbers(iElementToRemove) = [];
        parametersParadigm.cues(iElementToRemove) = [];
        parametersParadigm.biastype(iElementToRemove) = [];
        parametersParadigm.presentationTimes(iElementToRemove) = [];
        parametersParadigm.changeConditions(iElementToRemove) = [];           
        parametersParadigm.changeIndex(iElementToRemove) = [];           

        behavioralData.response(iElementToRemove) = [];
        behavioralData.reactionTime(iElementToRemove) = [];
    end

end

