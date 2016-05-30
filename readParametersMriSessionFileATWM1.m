function parametersMriSession = readParametersMriSessionFileATWM1();
global iStudy
global iSubject
global iSession

strParametersMriSessionFile = sprintf('%s_parametersMriSession_%i_%s', iSubject, iSession, iStudy);
parametersMriSession = eval(strParametersMriSessionFile);
parametersMriSession.strParametersMriSessionFile = strParametersMriSessionFile;

if parametersMriSession.bVerified == false
    strMessage = sprintf('Warning!\n%s has not been verified.', parametersMriSession.strParametersMriSessionFile);
    disp(strMessage);
end

end