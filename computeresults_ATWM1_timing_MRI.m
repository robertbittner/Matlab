% computes encoding time of ATWM1 behavioural study

% define directories

logfiledir = 'D:\Daten\ATWM1\Presentation_Logfiles\ATWM1_Working_Memory_MEG\ATWM1_Working_Memory_MEG\Logfiles';

% define subjects

subs_list = {'VW42LKU'};


numsubs = length(subs_list);

% define paramters

parametersParadigm.nTrialsPerRun                = 15;

parametersParadigm.FirstTrial                  = '1_1_Enoding';
parametersParadigm.Encoding                    = 'target_position';
parametersParadigm.Delay                       = 'Delay';



conditions = {'Nonsalient_Uncued_Run1';'Salient_Uncued_Run1';'Nonsalient_Cued_Run1';'Salient_Cued_Run1'};

numconditions = length(conditions);

%create results files

resultsFilePath= strcat(logfiledir,'\','ATWM1_timing_results_behavior_MRI');
fid=fopen(resultsFilePath, 'wt');
fprintf(fid,'%s\t', 'Subject_ID');
fprintf(fid,'%s\t', 'Condition');
fprintf(fid,'\n');
fclose(fid);

resultsFilePath2=strcat(logfiledir,'\','ATWM1_stats_timing_behavior_MRI');
fid=fopen(resultsFilePath2, 'wt');
fprintf(fid,'%s\t', 'Subject_ID');
fprintf(fid,'%s\t', 'Condition');
fprintf(fid,'\n');
fclose(fid);

% read in sce files and find all 45-50° angles

for n=1:numsubs
    subjectID=subs_list{n};
    
    for c=1:numconditions
        condition = conditions{c};
        
        tenc_count=0;
        tdel_count = 0;
        wrong_timing(n)= 0;
        
        fileName = strcat(logfiledir,'\',subjectID,'-ATWM1_Working_Memory_MEG_',condition,'.log');
        fid=fopen(fileName, 'r');
        
        while ~feof(fid)
            
            strLine = fgetl(fid);
            
            if  ~isempty(strfind(strLine, parametersParadigm.Encoding))
                tenc_count=tenc_count+1;
                encoding_marker=strfind(strLine, 'target');
                timing_on_enc=encoding_marker+41;
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
            if tot_timing(n,c,tcount) < 4000     %adjust for diff timing
                wrong_timing(n)=wrong_timing(n)+1;
                strmess=sprintf('Wrong timing detected for %s in %s', subjectID, condition)
                disp(strmess);
            end
            
            if tot_timing(n,c,tcount) > 4350   %adjust for different timing
                wrong_timing(n)=wrong_timing(n)+1;
                strmess=sprintf('Wrong timing detected for %s in %s', subjectID, condition)
                disp(strmess);
            end
        end
        
        
        % calculate stats
        percentage_wrong{n}=wrong_timing(n)/15;
        
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
        fprintf(fid, '%f\t', percentage_wrong{n});
        fprintf(fid,'\n');
        fclose(fid);
        
    end
end


