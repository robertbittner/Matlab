function vmr = defineStandardVmrFileNamesATWM1()
%%% © 2017 Robert Bittner
%%% Written for BrainVoyager 20.4
%%% This function defines the standardised names of important vmr files for
%%% a subject

global iStudy
global strSubject

%iStudy = 'ATWM1'
%strSubject = 'TEST010'

parametersStudy                         = eval(['parametersStudy', iStudy]);
parametersProjectFiles                  = eval(['parametersProjectFiles', iStudy]);
parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersBrainNormalisation            = eval(['parametersBrainNormalisation', iStudy]);
parametersBrainSegmentation             = eval(['parametersBrainSegmentation', iStudy]);

%%% File name for intially created brain
vmr.strVmrFile                  = sprintf('%s_%s_%s_%s%s',           strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersProjectFiles.extStructuralProject);

%%% File names for brain extraction and Talairach transformation
vmr.strVmrBrainExtrFile         = sprintf('%s_%s_%s_%s_%s%s',           strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisation.strBrainExtraction, parametersProjectFiles.extStructuralProject);
vmr.strVmrInTalFile             = sprintf('%s_%s_%s_%s_%s_%s%s',        strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisation.strBrainExtraction, parametersBrainNormalisation.strTalairachTransformation, parametersProjectFiles.extStructuralProject);
vmr.strVmrInTalSegmFile         = sprintf('%s_%s_%s_%s_%s_%s_%s%s',     strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisation.strBrainExtraction, parametersBrainNormalisation.strTalairachTransformation, parametersBrainSegmentation.strSegmentation, parametersProjectFiles.extStructuralProject);

%%% File names for MEG coregistration
vmr.strVmrIhc                   = sprintf('%s_%s_%s_%s_%s%s',           strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisation.strManualInhomogeneityCorrection, parametersProjectFiles.extStructuralProject);
vmr.strVmrMegCoreg              = sprintf('%s_%s_%s_%s_%s%s',           strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersStudy.strMegCoregistration, parametersProjectFiles.extStructuralProject);
vmr.strVmrMegCoregIhc           = sprintf('%s_%s_%s_%s_%s_%s%s',        strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersStudy.strMegCoregistration, parametersBrainNormalisation.strManualInhomogeneityCorrection, parametersProjectFiles.extStructuralProject);



end