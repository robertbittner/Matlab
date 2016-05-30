function aSubjectNames = readOutSubjectNames();

path = 'D:\Daten\ATWM1\Presentation_Logfiles\PSYPHY\EXP4\';
cd(path)
files = dir('*.log');
nfiles = length(files);

for cf = 1:nfiles 
    aFileNames{cf} = files(cf).name(1:6);
end
aSubjectNames = unique(aFileNames);


fid = fopen([path, 'aSubjectNames.m'], 'wt');
for i = 1:length(aSubjectNames)
    
    fprintf(fid, '\t''%s''\n', aSubjectNames{i});
end
fclose(fid);
end