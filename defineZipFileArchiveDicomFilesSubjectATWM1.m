function strZipFileArchiveDicomFilesSubject = defineZipFileArchiveDicomFilesSubjectATWM1(parametersStudy)

global iStudy
global strSubject
global iSession

strZipFileArchiveDicomFilesSubject = sprintf('%s_%s_%s_s%i.zip', strSubject, iStudy, parametersStudy.strMRI, iSession);

end