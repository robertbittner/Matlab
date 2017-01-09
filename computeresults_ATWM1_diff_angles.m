function [ vAngleDiffsRes ] = computeresults_ATWM1_diff_angles() % computes results of WM capacity task

    % define directories

    global viTrial
    global vAngleDiffs
    global vbSuccess
    

    logfiledir = 'D:\Daten\ATWM1\Presentation_Logfiles\PSYX\EXP8';

    scefiledir = 'D:\Daten\ATWM1\ATWM1_Scenarios';

    % define subjects

    subs_list = {'HLNG80'};
    numsubs = length(subs_list);

    % define paramters

    parametersParadigm.nTrialsPerRun                = 25;

    parametersParadigm.noChangeResponse             = 10;
    parametersParadigm.ChangeResponse               = 20;
    parametersParadigm.missingResponse              = 30;

    parametersParadigm.FirstTrial                  = '1_Load_4';
    parametersParadigm.Trial                       = 'Load_4';

    parametersParadigm.Response                    = 'Response';
    parametersParadigm.noChange                    = 'NoChange';
    parametersParadigm.Change                       = '_Change';
    parametersParadigm.ChangeSce                       = 'DoChange';


    conditions = {'Nonsalient_Uncued_Run3';'Nonsalient_Uncued_Run4';'Nonsalient_Uncued_Run6';'Nonsalient_Uncued_Run7'; ...
        'Salient_Uncued_Run3';'Salient_Uncued_Run4';'Salient_Uncued_Run6';'Salient_Uncued_Run7'; ...
        'Nonsalient_Cued_Run3';'Nonsalient_Cued_Run4';'Nonsalient_Cued_Run6';'Nonsalient_Cued_Run7';
        'Salient_Cued_Run3';'Salient_Cued_Run4';'Salient_Cued_Run6';'Salient_Cued_Run7'};

    numconditions = length(conditions);

     viTrial = [];
     vAngleDiffs = [];
     vbSuccess = [];
    
    % define results file

    %resultsFilePath= strcat(logfiledir,'\','diff_angles_results');
    %fid=fopen(resultsFilePath, 'wt');
    %fprintf(fid,'%s\t', 'Subject_ID');
    %fprintf(fid, '%s\t', 'CowansK');
    %fprintf(fid, '%s\t', 'Accuracy');
    %fprintf(fid,'\n');
    %fclose(fid);

    % read in sce files and find all 45-50° angles

    for c=1:numconditions
        condition = conditions{c};
        fileDefinition = strcat(scefiledir,'\','ATWM1_EXP8_PSY_',condition,'.sce');
        fid=fopen(fileDefinition, 'rt');
        smallangletrials=[ ];
        bigangletrials=[ ];

        while ~feof(fid)
            strLine = fgetl(fid);

            if  ~isempty(strfind(strLine, parametersParadigm.ChangeSce))
                gabor_marker=strfind(strLine, 'gabor');

                if strfind(strLine,'framed')<gabor_marker(10)
                    getAngleDiff(strLine, 78, 80);     
                end

                if strfind(strLine,'framed')>gabor_marker(10) && strfind(strLine,'framed')<gabor_marker(11)
                     getAngleDiff(strLine, 88, 90);     
                end

                if strfind(strLine,'framed')>gabor_marker(11) && strfind(strLine,'framed')<gabor_marker(12)
                     getAngleDiff(strLine, 98, 100);     
                end

                if strfind(strLine,'framed')>gabor_marker(12)
                    getAngleDiff(strLine, 108, 110);     
                end

            end
        end
    end
    
    vAngleDiffsRes = vAngleDiffs;
   
end

function getAngleDiff(strLine, angleIndexStart, angleIndexEnd)

    global viTrial
    global vAngleDiffs
    global vbSuccess
    
    trialsce=strLine(4:5);
    trialscenum=str2num(trialsce);
                
    firstang=strLine(angleIndexStart:angleIndexEnd);
    firstangnum=str2num(firstang);
    framstr=strfind(strLine,'framed');
    secang=strLine((framstr-4):(framstr-2));
    secangnum=str2num(secang);
    diffang=abs(secangnum-firstangnum);
    if diffang > 90
        diffang = diffang-90;
    end
    %if diffang<51
    %    smallangletrials=[smallangletrials trialscenum];
    %else
    %    bigangletrials=[bigangletrials trialscenum];
    %end
    
    viTrial = [ viTrial trialscenum ];
    vAngleDiffs = [ vAngleDiffs diffang ];
    %vbSuccess = [ vbSuccess bSuc ];

end


