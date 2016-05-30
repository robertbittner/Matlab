function parametersMriSession = analyzeParametersMriScanFileATWM1();

global iStudy
global iSubject
global iGroup
global iGroupLong
global iSession

parametersStudy = eval(['parametersStudy', iStudy]);

parametersStructuralMriSequence         = eval(['parametersStructuralMriSequence', iStudy]);
parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
parametersFunctionalMriSequence_WM      = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
parametersFunctionalMriSequence_LOC     = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
parametersFunctionalMriSequence_COPE    = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);

hFunction = str2func(sprintf('readParametersMriSessionFile%s', iStudy));
parametersMriSession = feval(hFunction);

hFunction = str2func(sprintf('readFileIndicesForFunctionalRuns%s', iStudy));
[parametersMriSession, fileIndex] = feval(hFunction, parametersStudy, parametersMriSession);

hFunction = str2func(sprintf('determineNumberOfRuns%s', iStudy));
[parametersMriSession, fileIndex] = feval(hFunction, parametersMriSession, fileIndex);
if parametersMriSession.bNoCriticalErrorsDetected == false
    return
end

hFunction = str2func(sprintf('determineFeasibilityOfEpiDistortionCorrection%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession, fileIndex);

hFunction = str2func(sprintf('compareNumberOfMeasurementsInEachRun%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession, fileIndex, parametersStudy, parametersStructuralMriSequence, parametersStructuralMriSequenceLowRes, parametersFunctionalMriSequence_WM, parametersFunctionalMriSequence_LOC, parametersFunctionalMriSequence_COPE);

hFunction = str2func(sprintf('compareNumberOfAcquiredRuns%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession);

hFunction = str2func(sprintf('finalEvaluationOfFile%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession);

parametersMriSession = orderfields(parametersMriSession);

end


function [parametersMriSession, fileIndex] = readFileIndicesForFunctionalRunsATWM1(parametersStudy, parametersMriSession);

strFileIndexFunctionalRuns = 'fileIndexFmr';
fileIndex.WM    = (parametersMriSession.(matlab.lang.makeValidName(sprintf('%s_%s', strFileIndexFunctionalRuns, parametersStudy.strWorkingMemoryTask))))';
fileIndex.LOC   = (parametersMriSession.(matlab.lang.makeValidName(sprintf('%s_%s', strFileIndexFunctionalRuns, parametersStudy.strLocalizer))))';
fileIndex.COPE  = (parametersMriSession.(matlab.lang.makeValidName(sprintf('%s_%s', strFileIndexFunctionalRuns, parametersStudy.strMethodEpiDistortionCorrection))))';

end


function [parametersMriSession, fileIndex] = determineNumberOfRunsATWM1(parametersMriSession, fileIndex);

parametersMriSession.nFunctionalRuns_WM     = numel(fileIndex.WM);
parametersMriSession.nFunctionalRuns_LOC    = numel(fileIndex.LOC);
parametersMriSession.nFunctionalRuns_COPE   = numel(fileIndex.COPE);

fileIndex.functionalRuns = [fileIndex.WM, fileIndex.LOC, fileIndex.COPE];
fileIndex.structuralRuns = parametersMriSession.fileIndexVmr;
fileIndex.anatomicalLocalizers = parametersMriSession.fileIndexAnatomicalLocalizer;
fileIndex.invalidRuns = parametersMriSession.fileIndexInvalidRuns;

parametersMriSession.nFunctionalRuns = numel(fileIndex.functionalRuns);
parametersMriSession.nStructuralRuns = numel(fileIndex.structuralRuns);
parametersMriSession.nAnatomicalLocalizers = numel(fileIndex.anatomicalLocalizers);
parametersMriSession.nInvalidRuns = numel(fileIndex.invalidRuns);

parametersMriSession.nTotalRuns = parametersMriSession.nFunctionalRuns + parametersMriSession.nStructuralRuns + parametersMriSession.nAnatomicalLocalizers + parametersMriSession.nInvalidRuns;
parametersMriSession.nRunsWithSpecifiedNumberOfMeasurements = numel(parametersMriSession.nMeasurementsInRun);

if parametersMriSession.nTotalRuns ~= parametersMriSession.nRunsWithSpecifiedNumberOfMeasurements
    parametersMriSession.bNoCriticalErrorsDetected = false;
    strMessage = sprintf('Error!\nNumber of total runs (%i)\ndoes not match the number of runs with\na specified number of measurements (%i)', parametersMriSession.nTotalRuns, parametersMriSession.nRunsWithSpecifiedNumberOfMeasurements);
    disp(strMessage);
    strMessage = sprintf('\nAborting analysis of file %s', parametersMriSession.strParametersMriSessionFile);
    disp(strMessage);
else
    parametersMriSession.bNoCriticalErrorsDetected = true;
end

end


function parametersMriSession = determineFeasibilityOfEpiDistortionCorrectionATWM1(parametersMriSession, fileIndex);
%%% Check, whether each WM or LOC run is preceded by a COPE run
combFileIndex = [fileIndex.WM, fileIndex.LOC];
precFileIndex = combFileIndex - 1;
parametersMriSession.bMatchingEpiDistortionCorrectionScanExists = ismember(precFileIndex, fileIndex.COPE);

if parametersMriSession.bMatchingEpiDistortionCorrectionScanExists == true
    parametersMriSession.bEpiDistortionCorrectionPossible = true;
else
    parametersMriSession.bEpiDistortionCorrectionPossible = false;
    iMissingEpiDistortionCorrectionScan = find(~parametersMriSession.bMatchingEpiDistortionCorrectionScanExists);
    for cedcs = 1:numel(iMissingEpiDistortionCorrectionScan)
        strMessage = sprintf('CHANGE MESSAGE \nError!\nPreceding EPI distortion correction scan missing for run %i!', combFileIndex(iMissingEpiDistortionCorrectionScan));
        disp(strMessage);
    end
end

end


function parametersMriSession = compareNumberOfMeasurementsInEachRunATWM1(parametersMriSession, fileIndex, parametersStudy, parametersStructuralMriSequence, parametersStructuralMriSequenceLowRes, parametersFunctionalMriSequence_WM, parametersFunctionalMriSequence_LOC, parametersFunctionalMriSequence_COPE);
global iStudy

strNrOfMeasurementsInStructuralRun      = 'nMeasurementsInStructuralRun';
strNrOfMeasurementsInFunctionalRun_WM   = 'nMeasurementsInFunctionalRun_WM';
strNrOfMeasurementsInFunctionalRun_LOC  = 'nMeasurementsInFunctionalRun_LOC';
strNrOfMeasurementsInFunctionalRun_COPE = 'nMeasurementsInFunctionalRun_COPE';

aStrRunTypes = {
    fileIndex.structuralRuns    parametersStructuralMriSequence.strSequence         parametersMriSession.nStructuralRuns        strNrOfMeasurementsInStructuralRun          parametersStructuralMriSequence.nSlices         parametersStructuralMriSequenceLowRes.nSlices
    fileIndex.WM                parametersStudy.strWorkingMemoryTask                parametersMriSession.nFunctionalRuns_WM     strNrOfMeasurementsInFunctionalRun_WM       parametersFunctionalMriSequence_WM.nVolumes     []
    fileIndex.LOC               parametersStudy.strLocalizer                        parametersMriSession.nFunctionalRuns_LOC    strNrOfMeasurementsInFunctionalRun_LOC      parametersFunctionalMriSequence_LOC.nVolumes    []
    fileIndex.COPE	            parametersStudy.strMethodEpiDistortionCorrection    parametersMriSession.nFunctionalRuns_COPE   strNrOfMeasurementsInFunctionalRun_COPE     parametersFunctionalMriSequence_COPE.nVolumes   []
    };
nRunTypes = size(aStrRunTypes);
nRunTypes = nRunTypes(1);

for c = 1:nRunTypes
    for cr = 1:aStrRunTypes{c, 3}
        parametersMriSession.(matlab.lang.makeValidName(strNrOfMeasurementsInStructuralRun))(cr) = parametersMriSession.nMeasurementsInRun(aStrRunTypes{c, 1}(cr));
        parametersMriSession.bMatchingNumberOfMeasurements{c, cr} = isequal(parametersMriSession.(matlab.lang.makeValidName(strNrOfMeasurementsInStructuralRun))(cr), aStrRunTypes{c, 5});
        hFunction = str2func(sprintf('detectStructuralRun%s', iStudy));
        parametersMriSession = feval(hFunction, parametersMriSession, parametersStructuralMriSequence, aStrRunTypes, c, cr, strNrOfMeasurementsInStructuralRun);
    end
end
hFunction = str2func(sprintf('evaluateStructuralRuns%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession);

parametersMriSession.bMatchingNumberOfMeasurements(cellfun(@isempty, parametersMriSession.bMatchingNumberOfMeasurements)) = {true};
parametersMriSession.bMatchingNumberOfMeasurements = cell2mat(parametersMriSession.bMatchingNumberOfMeasurements);

if parametersMriSession.bMatchingNumberOfMeasurements == true
    parametersMriSession.bAllNumberOfMeasurementValuesCorrect = true;
else
    parametersMriSession.bAllNumberOfMeasurementValuesCorrect = false;
    [row, col] = find(~parametersMriSession.bMatchingNumberOfMeasurements);
    for c = 1:numel(row)
        strMessage = sprintf('Error!\nNumber of Measurements does not match the predefined values for:\n%s run %i\nOverall run #: %i\n\n', aStrRunTypes{row(c), 2}, col(c), aStrRunTypes{row(c), 1}(col(c)));
        disp(strMessage);
    end
end

end


function parametersMriSession = detectStructuralRunATWM1(parametersMriSession, parametersStructuralMriSequence, aStrRunTypes, c, cr, strNrOfMeasurementsInStructuralRun);
%%% Search for standard and / or low res anatomical scans
if strcmp(aStrRunTypes{c, 2}, parametersStructuralMriSequence.strSequence)
    if cr == 1
        if parametersMriSession.bMatchingNumberOfMeasurements{c, cr} == true
            parametersMriSession.bStructuralMriStandarResAcquired = true;
            parametersMriSession.bStructuralMriLowResAcquired = false;
        else
            parametersMriSession.bMatchingNumberOfMeasurements{c, cr} = isequal(parametersMriSession.(matlab.lang.makeValidName(strNrOfMeasurementsInStructuralRun))(cr), aStrRunTypes{c, 6});
            if parametersMriSession.bMatchingNumberOfMeasurements{c, cr} == true
                parametersMriSession.bStructuralMriStandarResAcquired = false;
                parametersMriSession.bStructuralMriLowResAcquired = true;
            else
                parametersMriSession.bStructuralMriStandarResAcquired = false;
                parametersMriSession.bStructuralMriLowResAcquired = false;
            end
        end
    else
        if parametersMriSession.bMatchingNumberOfMeasurements{c, cr} == true && parametersMriSession.bStructuralMriStandarResAcquired == false
            parametersMriSession.bStructuralMriStandarResAcquired = true;
        else
            parametersMriSession.bMatchingNumberOfMeasurements{c, cr} = isequal(parametersMriSession.(matlab.lang.makeValidName(strNrOfMeasurementsInStructuralRun))(cr), aStrRunTypes{c, 6});
            if parametersMriSession.bMatchingNumberOfMeasurements{c, cr} == true && parametersMriSession.bStructuralMriLowResAcquired == false
                parametersMriSession.bStructuralMriLowResAcquired = true;
            end
        end
    end
end

end


function parametersMriSession = evaluateStructuralRunsATWM1(parametersMriSession);
if parametersMriSession.bStructuralMriStandarResAcquired == false && parametersMriSession.bStructuralMriLowResAcquired == true
    strMessage = sprintf('Warning!\nNo standard resolution structural run acquired!');
    disp(strMessage);
end
if parametersMriSession.bStructuralMriStandarResAcquired || parametersMriSession.bStructuralMriLowResAcquired == true
    parametersMriSession.bValidStructuralMriAcquired = true;
else
    parametersMriSession.bValidStructuralMriAcquired = false;
    strMessage = sprintf('Error!\nNo valid structural run acquired!');
    disp(strMessage);
end
end

function parametersMriSession = compareNumberOfAcquiredRunsATWM1(parametersMriSession);
global iStudy
global iSession
%%% Determine whether all runs for the study have been acquired during this
%%% session
parametersParadigm_WM_MRI = eval(['parametersParadigm_WM_MRI_', iStudy]);
parametersParadigm_LOC_MRI = eval(['parametersParadigm_LOC_MRI_', iStudy]);

bAllRunsAcquired(1) = parametersMriSession.bMatchingNumberOfMeasurements(1, 1);
bAllRunsAcquired(2) = isequal(parametersMriSession.nFunctionalRuns_WM, parametersParadigm_WM_MRI.nTotalRuns);
bAllRunsAcquired(3) = isequal(parametersMriSession.nFunctionalRuns_LOC, parametersParadigm_LOC_MRI.nTotalRuns);
bAllRunsAcquired(4) = isequal(parametersMriSession.nFunctionalRuns_COPE, (parametersParadigm_WM_MRI.nTotalRuns + parametersParadigm_LOC_MRI.nTotalRuns));

if bAllRunsAcquired == true
    parametersMriSession.bAllRunsAcquired = true;
else
    parametersMriSession.bAllRunsAcquired = false;
    strMessage = sprintf('Not all runs acquired in %s %i', parametersStudy.strSession, iSession);
    disp(strMessage);
end

end


function parametersMriSession = finalEvaluationOfFileATWM1(parametersMriSession);
%%% Determine whether any error have been detected
parametersMriSession.bAnyError = [
                                        ~parametersMriSession.bVerified
                                        ~parametersMriSession.bNoCriticalErrorsDetected
                                        ~parametersMriSession.bEpiDistortionCorrectionPossible
                                        ~parametersMriSession.bValidStructuralMriAcquired
                                        ~parametersMriSession.bAllNumberOfMeasurementValuesCorrect
                                        ];

if parametersMriSession.bAnyError == false
    parametersMriSession.bNoCriticalErrorsDetected = true;
else
    parametersMriSession.bNoCriticalErrorsDetected = false;
    strMessage = sprintf('\nOne or more errors found in file %s!', parametersMriSession.strParametersMriSessionFile);
    disp(strMessage);
    strMessage = sprintf('Data processing cannot proceed!\nPlease re-check the file manually.');
    disp(strMessage);
end

end