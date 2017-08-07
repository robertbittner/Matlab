function createFileNameForSmoothedIntensityHistogramATWM1()

global iStudy

iStudy = 'ATWM1';
strSubject = 'EX44QAH';

strVmr = strcat(strSubject, '_', iStudy, '_', 'MPRAGE_HIGH_RES_BRAIN_TAL_SEG.vmr');

strSih = 'SIH';

strSihFile = strcat(strVmr(1:end-4), '_', strSih);

fprintf('\n\nFile name for smoothed intensity histogram:');
fprintf('\n\n%s\n\n', strSihFile)


end