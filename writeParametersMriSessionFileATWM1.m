function writeParametersMriSessionFileATWM1()
clear all
clc

global iStudy
iStudy = 'ATWM1';

folderDefinition                = eval(['folderDefinition', iStudy]);
parametersMriSessionStandard 	= eval(['parametersMriSessionStandard', iStudy]);


iSession = 1;
strSubject = 'TEST'

strParametersMriSessionFile = defineParametersMriSessionFileNameATWM1(strSubject, iSession);
strPathParametersMriSessionFile = fullfile(folderDefinition.parametersMriScan, strParametersMriSessionFile);


fid = fopen(strPathParametersMriSessionFile, 'wt');

%% Write header
fprintf(fid, 'function parametersMriSession = %s_parametersMriSession_%i_%s();', strSubject, iSession, iStudy);
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write fileIndexFmr_WM
fprintf(fid, 'parametersMriSession.fileIndexFmr_WM = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriSessionStandard.fileIndexFmr_WM)
    fprintf(fid, '\t%i', parametersMriSessionStandard.fileIndexFmr_WM(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write fileIndexFmr_LOC
fprintf(fid, 'parametersMriSession.fileIndexFmr_LOC = [');
fprintf(fid, '\n');
fprintf(fid, '\t%i', parametersMriSessionStandard.fileIndexFmr_LOC);
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write fileIndexFmr_COPE
fprintf(fid, 'parametersMriSession.fileIndexFmr_COPE = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriSessionStandard.fileIndexFmr_COPE)
    fprintf(fid, '\t%i', parametersMriSessionStandard.fileIndexFmr_COPE(cr));
    fprintf(fid, '\n');
end
fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write VMR and localizer parameters
fprintf(fid, 'parametersMriSession.fileIndexVmr = %i;', parametersMriSessionStandard.fileIndexVmr);
fprintf(fid, '\n');
fprintf(fid, 'parametersMriSession.fileIndexAnatomicalLocalizer = %i;', parametersMriSessionStandard.fileIndexAnatomicalLocalizer);
fprintf(fid, '\n');
fprintf(fid, '\n');

%% Write number of measurements in run
%{
parametersMriSession.nMeasurementsInRun = [
    3
    5
    270
    5
    270
    5
    270
    5
    270
    88
    5
    165
    3
    96
    ];
%}
fprintf(fid, 'parametersMriSession.nMeasurementsInRun = [');
fprintf(fid, '\n');
for cr = 1:numel(parametersMriSessionStandard.nMeasurementsInRun)
    fprintf(fid, '\t%i', parametersMriSessionStandard.nMeasurementsInRun(cr));
    fprintf(fid, '\n');
end

fprintf(fid, '\t];');
fprintf(fid, '\n');
fprintf(fid, '\n');



%% Write end and close file
fprintf(fid, '\n');
fprintf(fid, 'end');

fclose(fid);

end


function parametersMriSessionStandard = parametersMriSessionStandardATWM1()

parametersMriSessionStandard.fileIndexFmr_WM = [
    3
    5
    7
    9
    ];

parametersMriSessionStandard.fileIndexFmr_LOC = [
    12
    ];

parametersMriSessionStandard.fileIndexFmr_COPE = [
    2
    4
    6
    8
    11
    ];

parametersMriSessionStandard.fileIndexVmr = 10;
parametersMriSessionStandard.fileIndexAnatomicalLocalizer = [
    1
    12
    ];

parametersMriSessionStandard.nMeasurementsInRun = [
    3
    5
    270
    5
    270
    5
    270
    5
    270
    88
    5
    165
    3
    96
    ];

end

%{
function parametersMriSession = DJ32GUZ_parametersMriSession_1_ATWM1();

parametersMriSession.fileIndexFmr_WM = [
    3
    5
    7
    9
    ];

parametersMriSession.fileIndexFmr_LOC = [
    12
    ];

parametersMriSession.fileIndexFmr_COPE = [
    2
    4
    6
    8
    12
    ];

parametersMriSession.fileIndexVmr = 10;
parametersMriSession.fileIndexAnatomicalLocalizer = 1;        %%% Project type?

parametersMriSession.nMeasurementsInRun = [
    3
    5
    270
    5
    270
    5
    270
    5
    270
    88
    5
    165
    ];

parametersMriSession.fileIndexInvalidRuns = [
    ];

parametersMriSession.bVerified = true;

end
%}