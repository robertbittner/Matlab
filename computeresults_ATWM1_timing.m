% computes encoding time of ATWM1 behavioural study

% define directories

logfiledir = 'D:\Daten\ATWM1\Presentation_Logfiles\PSY\EXP8';

% define subjects

subs_list = {'ERIC89';'ILAS80';'LIED76';'TAHA90';'ELAS75';'ERRA71';...
    'EVEL82';'CHAN64';'ERHY85';'ERNA90';'TTKE87';'CHAN22';'ERRG90';...
    'NANG82';'LEIN75';'AXSA74';'ERNE64';'ELAN88';'ERUS72';'NKNZ77';...
    'FFWE66';'OBON81'};


numsubs = length(subs_list);

% define paramters

parametersParadigm.nTrialsPerRun                = 25;

parametersParadigm.FirstTrial                  = '1_4_Objects';
parametersParadigm.Encoding                    = '_4_Objects';
parametersParadigm.Delay                       = 'Delay';



conditions = {'Nonsalient_Uncued_Run3';'Nonsalient_Uncued_Run4';'Nonsalient_Uncued_Run6';'Nonsalient_Uncued_Run7'; ...
    'Salient_Uncued_Run3';'Salient_Uncued_Run4';'Salient_Uncued_Run6';'Salient_Uncued_Run7'; ...
    'Nonsalient_Cued_Run3';'Nonsalient_Cued_Run4';'Nonsalient_Cued_Run6';'Nonsalient_Cued_Run7';
    'Salient_Cued_Run3';'Salient_Cued_Run4';'Salient_Cued_Run6';'Salient_Cued_Run7'};

numconditions = length(conditions);

%create results files

resultsFilePath= strcat(logfiledir,'\','ATWM1_timing_results_behavior');
fid=fopen(resultsFilePath, 'wt');
fprintf(fid,'%s\t', 'Subject_ID');
fprintf(fid,'%s\t', 'Condition');
fprintf(fid,'\n');
fclose(fid);

resultsFilePath2=strcat(logfiledir,'\','ATWM1_stats_timing_behavior');
fid=fopen(resultsFilePath2, 'wt');
fprintf(fid,'%s\t', 'Subject_ID');
fprintf(fid,'%s\t', 'Condition');
fprintf(fid,'\n');
fclose(fid);

% read in sce files and calculate encoding time

trialcount = parametersParadigm.nTrialsPerRun;

tot_timing = zeros(numsubs,numconditions,trialcount);

for n=1:numsubs
    subjectID=subs_list{n};
    
    for c=1:numconditions
        condition = conditions{c};
        
        tenc_count=0;
        tdel_count = 0;
        wrong_timing(n)= 0;
        
        FileName = strcat(logfiledir,'/',subjectID,'-','ATWM1_EXP8_PSY_',condition,'.log');
        fid=fopen(FileName, 'r');
        
        while ~feof(fid)
            
            strLine = fgetl(fid);
            
            if  ~isempty(strfind(strLine, parametersParadigm.Encoding))
                tenc_count=tenc_count+1;
                fixation_marker=strfind(strLine, 'fixation_cross');
                timing_on_enc=fixation_marker+19;
                timing_off_enc=timing_on_enc+6;
                strtiming_enc=strLine(timing_on_enc:timing_off_enc);
                timing_enc(tenc_count)=str2double(strtiming_enc);
            end
            
            if  ~isempty(strfind(strLine, parametersParadigm.Delay))
                tdel_count=tdel_count+1;
                delay_marker=strfind(strLine, 'Delay');
                timing_on_del=delay_marker+6;
                timing_off_del=timing_on_del+6;
                strtiming_del=strLine(timing_on_del:timing_off_del);
                timing_del(tdel_count)=str2double(strtiming_del);
                
            end
        end
        
        tot_timing(n,c,:)=timing_del-timing_enc;
        
        for tcount=1:25
            if tot_timing(n,c,tcount) < 4200
                wrong_timing(n)=wrong_timing(n)+1;
                strmess=sprintf('Wrong timing detected for %s in %s', subjectID, condition)
                disp(strmess);
            end
            
            if tot_timing(n,c,tcount) > 4500
                wrong_timing(n)=wrong_timing(n)+1;
                strmess=sprintf('Wrong timing detected for %s in %s', subjectID, condition)
                disp(strmess);
            end
        end
        
        % calculate stats
        percentage_wrong(n)=wrong_timing(n)/25;
        
        fclose(fid);
        
        
        % complete 1st results file
        
        fid=fopen(resultsFilePath, 'A');
        fprintf(fid,'%s\t', subjectID);
        fprintf(fid,'%s\t', condition);
        fprintf(fid, '%d\t', tot_timing(n,c,:));
        fprintf(fid,'\n');
        fclose(fid);
        
        % complete 2nd results file
        fid=fopen(resultsFilePath2, 'A');
        fprintf(fid,'%s\t', subjectID);
        fprintf(fid,'%s\t', condition);
        fprintf(fid, '%f\t', percentage_wrong(n));
        fprintf(fid,'\n');
        fclose(fid);
        
        
    end
end

