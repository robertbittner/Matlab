function pushSubjectPresentationScenarioFilesToGithubATWM1()

clear all
clc

strStudy = 'ATWM1';

%% Define folder and add temporary paths
strRootFolderBeoserv = sprintf('/data/projects/%s/', strStudy);
strRootFolderServer = strRootFolderBeoserv;
strRootFolder = sprintf('%sPresentation/', strRootFolderServer); 

%%
cd(strRootFolder);

! git status

% get changes from GitHub
! git pull

% add new files and directories
! git add *

% commit changes
! git commit -m "Add new presentation scenario files"

% push to GitHub
! git push

! git status

    
end