function TEST_COPY_SERVER()

pathLocal = 'D:\Daten\ATWM1\Archive_DICOM_Files\___Anonymised_Archive_HIGH_RES_MPRAGE\CONT\DA45QZX_DO_NOT_COPY_THIS_FOLDER_ONLY_THE_ZIP_FILE_CONTAINED_WITHIN_IT!\';

pathServer = 'X:\ATWM1\Archive_DICOM_Files\___Anonymised_Archive_HIGH_RES_MPRAGE\CONT\DA45QZX_DO_NOT_COPY_THIS_FOLDER_ONLY_THE_ZIP_FILE_CONTAINED_WITHIN_IT!\';

strZipFile = 'MPRAGE.zip';

strPathZipFileLocal = fullfile(pathLocal, strZipFile)

%tet = exist(strPathZipFileLocal, 'file')

strPathZipFileServer = fullfile(pathServer, strZipFile);

%[status,message,messageId] = copyfile(strPathZipFileLocal, strPathZipFileServer, 'f')
[status,message,messageId] = copyfile(pathLocal, pathServer, 'f');


if status
    fprintf('Copying successful.\n');
else
    fprintf('Error during copying.\n');
end

end