% ATWM1
% Analyze psycho-physics presentation logfiles

function SelectLogFiles()

    clear all; clc;

    [vsFileNames, strFolderName] = uigetfile('*.log', 'Select log file(s)', 'Multiselect','on');
    
    % convert vsFileNames in cell array in case only one file was selected
    if ~iscell(vsFileNames)
       strTemp = vsFileNames;
       vsFileNames = {};
       vsFileNames{1} = strTemp; 
    end
        
    for iFile = 1:length(vsFileNames)       
      
        if vsFileNames{iFile} ~= 0  % catch 'Cancel' choice        
            strFileName = char(vsFileNames(iFile));
            strFilePath = strcat(strFolderName,strFileName);
            AnalyzeLogFile(strFilePath);
        end
    end
       
end




