function strParametersMriSessionFile = defineParametersMriSessionFileNameATWM1(strSubject, iSession)

global iStudy

strParametersMriSessionFile = sprintf('%s_parametersMriSession_%i_%s.m', strSubject, iSession, iStudy);


end