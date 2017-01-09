function strParametersMriSessionFile = defineParametersMriSessionFileNameATWM1(strSubject, iSession)

global iStudy

strParametersMriSessionFile = sprintf('%s_s%i_parametersMriSession%s.m', strSubject, iSession, iStudy);


end