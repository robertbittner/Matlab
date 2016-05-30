function parametersMriSession = readParametersMriSessionFileATWM1();
global iStudy
global strSubject
global iSession

hFunction = str2func(sprintf('defineParametersMriSessionFileName%s', iStudy));
strParametersMriSessionFile = feval(hFunction, strSubject, iSession);

parametersMriSession = eval(strParametersMriSessionFile);
parametersMriSession.strParametersMriSessionFile = strParametersMriSessionFile;

if parametersMriSession.bVerified == false
    strMessage = sprintf('Warning!\n%s has not been verified.', parametersMriSession.strParametersMriSessionFile);
    disp(strMessage);
end

end