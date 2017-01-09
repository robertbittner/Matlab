function [strInstalledMatlabVersion, strInstalledMatlabRelease] = determinInstalledMatlabVersionATWM1()
%%% Determine current Matlab version and release
%%% e.g.: 9.1.0.441655 (R2016b)
strMatlabVersion = version;

indexEndVersion = strfind(strMatlabVersion, ' ') - 1;
indexStartRelease = strfind(strMatlabVersion, ' ') + 1;

strInstalledMatlabRelease = strMatlabVersion(indexStartRelease:end);
strInstalledMatlabRelease = strrep(strInstalledMatlabRelease, '(', '');
strInstalledMatlabRelease = strrep(strInstalledMatlabRelease, ')', '');

strInstalledMatlabVersion = strMatlabVersion(1:indexEndVersion);


end