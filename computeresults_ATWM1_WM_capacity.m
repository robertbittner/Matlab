% computes results of WM capacity task

% define directory

dir = 'D:\Daten\ATWM1\Presentation_Logfiles\WM_Capacity_Task';

% define subjects

subs_list = {'HNTZ86','PEAN76','HRAN63','CHTA58','ILAS80','LIED76','TAHA90','ELAS75','ERRA71','EVEL82',...
    'ERIC89','CHAN64','ERHY85','ERNA90','TTKE87','CHAN22','ERRG90','NANG82','LEIN75','AXSA74','ERNE64',...
    'ELAN88','ERUS72','NKNZ77','FFWE66','OBON81','NION84','CHNA87','LKIS93','EKAN79','EKIK86','EFWE82',...
    'ERNE60','NNEN72','ERTH81','USNE78','KARD60','ENKE59','UBLA56','RTAS65','USPP84','ESEL82',...
    'CKAS90','SPKA96','NSNA76','DELS88','DTLA68','DTSA93','ELER94',...
    'EREL83','RZED56','ERKA86','NGRT86','CHKA87','LEAN77','MPKE94','ERNA75','EKEA83','ERAN91','CKNT90'};

numsubs = length(subs_list);

% define paramters

parametersParadigm.nTrialsPerRun                = 60;

parametersParadigm.noChangeResponse             = 10;
parametersParadigm.ChangeResponse               = 20;
parametersParadigm.missingResponse              = 30; 


%parametersParadigm.iCorrectResponse             = 1;
%parametersParadigm.iIncorrectResponse           = 0;
%parametersParadigm.iMissingResponse             = -1;

parametersParadigm.iFirstTrial                  = '1_Load_4';
parametersParadigm.iTrial                       = 'Load_4';

parametersParadigm.iResponse                    = 'Response';
parametersParadigm.noChange                    = 'NoChange';
parametersParadigm.Change                       = '_Change';


% define results file
resultsFilePath= strcat(dir,'\','WMCapResults.txt');
fid=fopen(resultsFilePath, 'wt');
fprintf(fid,'%s\t', 'Subject_ID');
fprintf(fid, '%s\t', 'CowansK');
fprintf(fid, '%s\t', 'Accuracy');
fprintf(fid,'\n');
fclose(fid);


for s=1:numsubs
    
    N_Trials= 0;
    N_Hits= 0;
    N_Misses= 0;
    N_CorrectReject = 0;
    N_FalseReject = 0;
    N_Missing_Resp = 0;
    Response_Matrix = zeros(60,3);
    
    subject = subs_list{s};
    fileDefinition = strcat(dir,'\',subject,'-ATWM1_WM_CAP_PSY_s1.log');
    
    fid=fopen(fileDefinition, 'rt');
    
    while ~feof(fid)
        strLine = fgetl(fid);
        if  ~isempty(strfind(strLine, parametersParadigm.iTrial))
            N_Trials = N_Trials + 1;
            Response_Matrix(N_Trials,1)=N_Trials;
            if     ~isempty(strfind(strLine, parametersParadigm.Change))
                Response_Matrix(N_Trials,2)=20;
            else
                Response_Matrix(N_Trials,2)=10;
            end
        end
        if ~isempty(strfind(strLine, parametersParadigm.iResponse))
            text = textscan(strLine, '%s %f %s %f %f %*[^\n]');
            str_response = text{4};
            if Response_Matrix(N_Trials,3)== 0;
                Response_Matrix(N_Trials,3)= str_response;
            else
                strMessage = sprintf('Double response for %s in Trial %i', subject, N_Trials);
                disp(strMessage);
            end
            %        trialData.responseOnset(N_Trials) = text{5};
        end
        
    end
    fclose(fid);
    
    % Check, whether the correct number of trials have been extracted
    if N_Trials ~= parametersParadigm.nTrialsPerRun
        strMessage = sprintf('\nError during trial extraction in file %s!\nnumber of exptected trials: %i\nnumber of extracted trials: %i', fileDefinition, parametersParadigm.nTrialsPerRun, N_Trials);
        disp(strMessage);
    end
    
    % calculate hits, misses etc.
    
    
    
    for N_Trials=1:60
        if Response_Matrix(N_Trials,2)==20;
            if Response_Matrix(N_Trials,3) == 20
                N_Hits= N_Hits +1;
            end
            if Response_Matrix(N_Trials,3) == 10
                N_Misses= N_Misses + 1;
            else
                N_Missing_Resp = N_Missing_Resp +1;
            end
        end
        if Response_Matrix(N_Trials,2)==10;
            if Response_Matrix(N_Trials,3) == 10
                N_CorrectReject= N_CorrectReject +1;
            end
            if Response_Matrix(N_Trials,3) == 20
                N_FalseReject = N_FalseReject +1;
            else N_Missing_Resp = N_Missing_Resp +1;
            end
        end
    end
        
        
        % calculate cowan's k and overall accuracy
        
   % define number of objects to be remembered
   N_Objects=4; 
   
   HitRate = N_Hits/(N_Hits+N_Misses);
   CorrectRejectRate = N_CorrectReject/(N_CorrectReject+N_FalseReject);
   
   CowansK = (HitRate+CorrectRejectRate-1)*N_Objects;
   Accuracy = (N_Hits+N_CorrectReject)/N_Trials;
   
   % save single subject data
   
   resultsFilePath= strcat(dir,'\','WMCapResults.txt');
   fid=fopen(resultsFilePath, 'A');
   fprintf(fid,'\n');
   fprintf(fid,'%s\t', subject);
   fprintf(fid, '%.4f\t', CowansK);
   fprintf(fid, '%.4f\t', Accuracy);
   strMessage=sprintf('Data of %s was saved to file', subject);
   disp(strMessage);
   fclose(fid);

end
