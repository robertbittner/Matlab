%%Readin

subject_names = {'CHAN22','ERRG90','ERHY85','ERIC89','ERNA90','LEIN75','LIED76','AXSA74', ...
'NANG82','CHAN64','ERNE64','NKNZ77','FFWE66','ILAS80','TAHA90','ELAS75','ERRA71','EVEL82',...
'TTKE87','OBON81','ELAN88','ERUS72' ,'NION84','CHNA87','LKIS93','EKAN79','CHTA58','HRAN63',...
'HNTZ86','PEAN76'};

numsubs = length(subject_names);

%Defining Conditions
c_names = {'Salient_Cued','Salient_Uncued','Nonsalient_Cued','Nonsalient_Uncued'};
run_names = {'Run3','Run4','Run6','Run7'};
%Defining Trial matrices
N_conditions = length(c_names); % SC, SU, NC, NU
N_runs       = length(run_names);
N_types      = 2; % Standard, Catch
N_cases      = 2; % Do, No
N_trials     = 25;


Count_trials   = zeros(N_conditions,N_types,N_cases,1);


Readout_trials = false(N_conditions,N_runs,N_trials);
Missed_trials  = false(N_conditions,N_runs,N_trials);
RT_trials      = zeros(N_conditions,N_runs,N_trials);

Case_indicator = zeros(N_conditions,N_runs,N_trials);
% StDo = 1; St_No =2 ; CaDo = 3; CaNo =4;




% Directory definition

dir= 'D:\Daten\ATWM1\Presentation_Logfiles\PSY\EXP8'; 

%Results File

Column_Labels= {'Subject_ID', 'Accuracy_global', 'Accuracy_SalientCued', 'Accuracy_SalientUncued', 'Accuracy_NonSCued', 'Accuracy_NonSUncued', ...
    'CowansK_SalientCued', 'CowansK_SalientUncued', 'CowansK_NonSalCued', 'CowansK_NonSalUncued', 'CowansK_SalientCuedSt', ...
    'CowansK_SalientCuedCa', 'CowansK_SalientUncuedSt', 'CowansK_SalientUncuedCa', 'CowansK_NonSalCuedSt', 'CowansK_NonSalCuedCa',...
    'CowansK_NonsalientUncuedSt', 'CowansK_NonsalientUncuedCa','Percentage_Missed_Response'};

resultsFilePath= strcat(dir,'\','ATWM1_alldata.txt');
fid=fopen(resultsFilePath, 'wt');
fprintf(fid,'%s\t', Column_Labels{:});



for s = 1:numsubs
    subject = subject_names{s};
    for c = 1:N_conditions
        c_name = c_names{c};
        for r = 1:N_runs
            run_name = run_names{r};
            filename = strcat(dir,'\',subject,'-ATWM1_EXP8_PSY_',c_name,'_',run_name,'.log');
            strmessage=sprintf('Loading %s', filename);
            disp(strmessage);
            fid=fopen(filename, 'rt');
            
            k=0;
            Trial_count = 0;
            
            
            while ~feof(fid)
                
                k = k+1;
                strLine = fgetl(fid);
                First_Response = false;
                Readout_Done = true;
                
                % Trial Counting and First Response = true
                search_TrialStart = '_4_Objects';
                if(~isempty(strfind(strLine, search_TrialStart)))
                    Trial_count= Trial_count+1;
                    First_Response = true;
                end
                
                                
                % Type and Case
                
                search_St = 'CuedRetrieval';
                search_Ca = 'UncuedRetriev';
                search_Do = 'DoChange';
                search_No = 'NoChange';
                
                
                
                if(~isempty(strfind(strLine, search_St)))
                    cond_St = true;
                end
                if(~isempty(strfind(strLine, search_Ca)))
                    cond_St = false;
                end
                if(~isempty(strfind(strLine, search_Do)))
                    cond_Do = true;
                end
                if(~isempty(strfind(strLine, search_No)))
                    cond_Do = false;
                end
                
                
               % Response Readout
                search_Resp = 'Response';
                
                str_Resp = strfind(strLine, search_Resp);
                if(~isempty(str_Resp)&& First_Response)
                    
                    Response = strLine(str_Resp+9:str_Resp+10);
                    Response = str2num(Response);
                    
                    
                    [~,Token] = strtok(strLine(str_Resp:end));
                    for i = 1:2
                        [~,Token] = strtok(Token);
                    end
                    RT_trials(c,r,Trial_count) = str2num(strtok(Token));
                    
                    First_Response = false;
                    Readout_Done = false;
                    
                    if(Response ~= 10 & Response ~=20)
                        disp(['Missed Response in Case: ', num2str(c),'! Run: ', num2str(r),'! Trial: ',num2str(Trial_count)])
                        disp(['Response is : ', num2str(Response)])
                    end
                end
                
                % Combining Conditions and Responses
                if(Trial_count>0 && ~First_Response && ~Readout_Done)
                    
                    if(cond_St && cond_Do)
                        Case_indicator(c,r,Trial_count)= 1;
                        if(Response == 10)
                            Readout_trials(c,r,Trial_count) = false;
                        elseif(Response == 20)
                            Readout_trials(c,r,Trial_count) = true;
                        else
                            Readout_trials(c,r,Trial_count) = false;
                            Missed_trials (c,r,Trial_count) = true;
                        end
                    elseif(cond_St && ~cond_Do)
                        Case_indicator(c,r,Trial_count)= 2;
                        if(Response == 10)
                            Readout_trials(c,r,Trial_count) = true;
                        elseif(Response == 20)
                            Readout_trials(c,r,Trial_count) = false;
                        else
                            Readout_trials(c,r,Trial_count) = false;
                            Missed_trials (c,r,Trial_count) = true;
                        end
                    elseif(~cond_St && cond_Do)
                        Case_indicator(c,r,Trial_count)= 3;
                        if(Response == 10)
                            Readout_trials(c,r,Trial_count) = false;
                        elseif(Response == 20)
                            Readout_trials(c,r,Trial_count) = true;
                        else
                            Readout_trials(c,r,Trial_count) = false;
                            Missed_trials (c,r,Trial_count) = true;
                        end
                    else
                        Case_indicator(c,r,Trial_count)= 4;
                        if(Response == 10)
                            Readout_trials(c,r,Trial_count) = true;
                        elseif(Response == 20)
                            Readout_trials(c,r,Trial_count) = false;
                        else
                            Readout_trials(c,r,Trial_count) = false;
                            Missed_trials (c,r,Trial_count) = true;
                        end
                    end
                    Readout_Done = true;
                end
            end
        end
    end


%% Output

Total_Misses = sum(sum(sum(Missed_trials)));
Percentage_Missed= Total_Misses/400;
str_message= sprintf('Patient %s missed %i trials', subject, Total_Misses);
disp(str_message);

Accuracy_global = mean(mean(mean(Readout_trials)));
RT_global       = mean(mean(mean(RT_trials)))/10000; %% in seconds


Accuracy_SalientCued   = mean(mean(Readout_trials(1,:,:)));
Accuracy_SalientUncued = mean(mean(Readout_trials(2,:,:)));
Accuracy_NonSCued      = mean(mean(Readout_trials(3,:,:)));
Accuracy_NonSUncued    = mean(mean(Readout_trials(4,:,:)));





%% CowansKs
N_objects = 2;

%Global
help_matrix = Readout_trials;
HitRate = mean(help_matrix(Case_indicator ==1 | Case_indicator ==3));
CorrectRejectRate = mean(help_matrix(Case_indicator==2 | Case_indicator==4));

CowansK_global = (HitRate+CorrectRejectRate-1)*N_objects;


%SalientCued
i = 1;
help_matrix = squeeze(Readout_trials(i,:,:));
HitRate = mean(help_matrix(Case_indicator(i,:,:)==1 | Case_indicator(i,:,:) ==3));
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2 | Case_indicator(i,:,:)==4));


CowansK_SalientCued = (HitRate+CorrectRejectRate-1)*N_objects;

% SalientCuedSt

HitRate = mean(help_matrix(Case_indicator(i,:,:)==1)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2));


CowansK_SalientCuedSt = (HitRate+CorrectRejectRate-1)*N_objects;

%SalientCuedCa

HitRate = mean(help_matrix(Case_indicator(i,:,:)==3)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==4));


CowansK_SalientCuedCa = (HitRate+CorrectRejectRate-1)*N_objects;

%SalientUncued
i = 2;
help_matrix = squeeze(Readout_trials(i,:,:));
HitRate = mean(help_matrix(Case_indicator(i,:,:)==1 | Case_indicator(i,:,:) ==3));
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2 | Case_indicator(i,:,:)==4));


CowansK_SalientUncued = (HitRate+CorrectRejectRate-1)*N_objects;


% SalientUncuedSt

HitRate = mean(help_matrix(Case_indicator(i,:,:)==1)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2));


CowansK_SalientUncuedSt = (HitRate+CorrectRejectRate-1)*N_objects;

%SalientUncuedCa

HitRate = mean(help_matrix(Case_indicator(i,:,:)==3)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==4));


CowansK_SalientUncuedCa = (HitRate+CorrectRejectRate-1)*N_objects;

%NonsalientCued
i = 3;
help_matrix = squeeze(Readout_trials(i,:,:));
HitRate = mean(help_matrix(Case_indicator(i,:,:)==1 | Case_indicator(i,:,:) ==3));
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2 | Case_indicator(i,:,:)==4));


CowansK_NonSalCued = (HitRate+CorrectRejectRate-1)*N_objects;

% NonsalientCuedSt

HitRate = mean(help_matrix(Case_indicator(i,:,:)==1)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2));


CowansK_NonSalCuedSt = (HitRate+CorrectRejectRate-1)*N_objects;

%NonsalientCuedCa

HitRate = mean(help_matrix(Case_indicator(i,:,:)==3)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==4));


CowansK_NonSalCuedCa = (HitRate+CorrectRejectRate-1)*N_objects;


%NonsalientUncued
i = 4;
help_matrix = squeeze(Readout_trials(i,:,:));
HitRate = mean(help_matrix(Case_indicator(i,:,:)==1 | Case_indicator(i,:,:) ==3));
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2 | Case_indicator(i,:,:)==4));


CowansK_NonSalUncued = (HitRate+CorrectRejectRate-1)*N_objects;


% NonsalientUncuedSt

HitRate = mean(help_matrix(Case_indicator(i,:,:)==1)); 
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==2));


CowansK_NonSalUncuedSt = (HitRate+CorrectRejectRate-1)*N_objects;

%NonsalientUncuedCa

HitRate = mean(help_matrix(Case_indicator(i,:,:)==3));
CorrectRejectRate = mean(help_matrix(Case_indicator(i,:,:)==4));


CowansK_NonSalUncuedCa = (HitRate+CorrectRejectRate-1)*N_objects;


% save single subject data
subject_data = {Accuracy_global, Accuracy_SalientCued, Accuracy_SalientUncued, Accuracy_NonSCued, Accuracy_NonSUncued, ...
    CowansK_SalientCued, CowansK_SalientUncued, CowansK_NonSalCued, CowansK_NonSalUncued, CowansK_SalientCuedSt, ...
    CowansK_SalientCuedCa, CowansK_SalientUncuedSt, CowansK_SalientUncuedCa, CowansK_NonSalCuedSt, CowansK_NonSalCuedCa,...
    CowansK_NonSalUncuedSt, CowansK_NonSalUncuedCa};


fid=fopen(resultsFilePath, 'A');
fprintf(fid,'\n');
fprintf(fid,'%s\t', subject);
fprintf(fid, '%.4f\t', subject_data{:});
strMessage=sprintf('Data of %s was saved to file', subject);
disp(strMessage);
fclose(fid);

end