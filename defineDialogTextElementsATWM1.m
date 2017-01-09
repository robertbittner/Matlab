function [textElements, parametersDialog] = defineDialogTextElementsATWM1()

global iStudy

[parametersDialog] = eval(['parametersDialog', iStudy]);

textElements = parametersDialog.textElements;


end