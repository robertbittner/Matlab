function parametersMriSession = readParametersMriSessionFileATWM1()

global iStudy
global iSession
global strSubject

hFunction = str2func(sprintf('defineParametersMriSessionFileName%s', iStudy));
strParametersMriSessionFile = feval(hFunction, strSubject, iSession);

strParametersMriSession = strrep(strParametersMriSessionFile, '.m', '');
if ~exist(strParametersMriSession, 'file')
    fprintf('\nError!\nParameter file %s could not be found!\n\n', strParametersMriSessionFile);
end
parametersMriSession = eval(strParametersMriSession);
parametersMriSession.strParametersMriSessionFile = strParametersMriSession;

if parametersMriSession.bVerified == false
    fprintf('Warning!\n%s has not been verified.\n', parametersMriSession.strParametersMriSessionFile);
end

end