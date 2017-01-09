function changeDirectoryToCurrentSubjectATWM1(folderDefinition)
%%% Changes current folder to subject folder

global indexStudy;
global indexMethod;
global indexExperiment;
global indexSubject;



projectDataPath = [pathDefinition.singleSubjectData, indexExperiment, '\', indexSubject, '\'];

cd(projectDataPath);

end