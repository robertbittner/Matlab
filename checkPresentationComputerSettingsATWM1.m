function checkPresentationComputerSettingsATWM1();

iStudy = 'ATWM1';

parametersPresentation = eval(['parametersPresentation', iStudy]);

vScreenResolution = get(0, 'MonitorPositions');
vScreenResolution = vScreenResolution(3:4);
if parametersPresentation.screenResolution(1) ~= vScreenResolution(1) || parametersPresentation.screenResolution(2) ~= vScreenResolution(2)
    strMessage = sprintf('Screen resolution needs to be reset!\n');
    disp(strMessage); 
    strMessage = sprintf('Current screen resolution: %i x %i', vScreenResolution(1), vScreenResolution(2));
    disp(strMessage);
    strMessage = sprintf('Required screen resolution: %i x %i', parametersPresentation.screenResolution(1), parametersPresentation.screenResolution(2));
    disp(strMessage);
end

end