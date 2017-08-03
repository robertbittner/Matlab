function [aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes] = defineHighResAnatomyDicomFilesATWM1(parametersMriSession, aStrLocalPathOriginalDicomFiles)
%%% Define name and path of high-res anatomy DICOM files
fileIndexVmrHighRes = parametersMriSession.fileIndexVmrHighRes;
nFilesVmrHighRes    = parametersMriSession.nMeasurementsInRun(fileIndexVmrHighRes);

indexStart  = parametersMriSession.vStartIndexDicomFileRun(fileIndexVmrHighRes);
indexEnd    = indexStart + nFilesVmrHighRes;


aStrPathOriginalDicomFilesVmrHighRes    = aStrLocalPathOriginalDicomFiles(indexStart : indexEnd - 1);


for cf = 1:numel(aStrPathOriginalDicomFilesVmrHighRes)
    [strFolder, strName, strExt] = fileparts(aStrPathOriginalDicomFilesVmrHighRes{cf});
    aStrOriginalDicomFilesVmrHighRes{cf} = strcat(strName, strExt);
end


end