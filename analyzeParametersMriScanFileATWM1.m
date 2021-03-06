function parametersMriSession = analyzeParametersMriScanFileATWM1()

global iStudy
global iSession
global strSubject

parametersStudy = eval(['parametersStudy', iStudy]);

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
parametersFunctionalMriSequence_WM      = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
parametersFunctionalMriSequence_LOC     = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
parametersFunctionalMriSequence_COPE    = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);

try
    hFunction = str2func(sprintf('readParametersMriSessionFile%s', iStudy));
    parametersMriSession = feval(hFunction);
catch
    parametersMriSession = [];
    fprintf('Could not read parametersMriSession file for %s -  run %i!\n\n', strSubject, iSession);
    return
end

hFunction = str2func(sprintf('readFileIndicesForFunctionalRuns%s', iStudy));
[fileIndex] = feval(hFunction, parametersStudy, parametersMriSession);

hFunction = str2func(sprintf('determineNumberOfRunsInMriSession%s', iStudy));
[parametersMriSession, fileIndex] = feval(hFunction, parametersMriSession, fileIndex);
if parametersMriSession.bNoCriticalErrorsDetected == false
    return
end

hFunction = str2func(sprintf('determineFeasibilityOfEpiDistortionCorrection%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession, fileIndex);

hFunction = str2func(sprintf('compareNumberOfMeasurementsInEachRun%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession, fileIndex, parametersStudy, parametersStructuralMriSequenceHighRes, parametersStructuralMriSequenceLowRes, parametersFunctionalMriSequence_WM, parametersFunctionalMriSequence_LOC, parametersFunctionalMriSequence_COPE);

hFunction = str2func(sprintf('compareNumberOfAcquiredRuns%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession);

if parametersMriSession.nInvalidRuns ~= 0
    parametersMriSession.bDeviatingDicomFileNamesPossible = true;
else
    parametersMriSession.bDeviatingDicomFileNamesPossible = false;
end

hFunction = str2func(sprintf('finalEvaluationOfFile%s', iStudy));
parametersMriSession = feval(hFunction, parametersMriSession);

parametersMriSession = orderfields(parametersMriSession);


end


function [fileIndex] = readFileIndicesForFunctionalRunsATWM1(parametersStudy, parametersMriSession)

strFileIndexFunctionalRuns = 'fileIndexFmr';
fileIndex.WM    = (parametersMriSession.(matlab.lang.makeValidName(sprintf('%s_%s', strFileIndexFunctionalRuns, parametersStudy.strWorkingMemoryTask))))';
fileIndex.LOC   = (parametersMriSession.(matlab.lang.makeValidName(sprintf('%s_%s', strFileIndexFunctionalRuns, parametersStudy.strLocalizer))))';
fileIndex.COPE  = (parametersMriSession.(matlab.lang.makeValidName(sprintf('%s_%s', strFileIndexFunctionalRuns, parametersStudy.strMethodEpiDistortionCorrection))))';


end


function [parametersMriSession, fileIndex] = determineNumberOfRunsInMriSessionATWM1(parametersMriSession, fileIndex)

parametersMriSession.nFunctionalRuns_WM     = numel(fileIndex.WM);
parametersMriSession.nFunctionalRuns_LOC    = numel(fileIndex.LOC);
parametersMriSession.nFunctionalRuns_COPE   = numel(fileIndex.COPE);

fileIndex.functionalRuns = [fileIndex.WM, fileIndex.LOC, fileIndex.COPE];
fileIndex.structuralRuns = [parametersMriSession.fileIndexVmrHighRes, parametersMriSession.fileIndexVmrLowRes];
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
    fprintf('Error!\nNumber of total runs (%i)\ndoes not match the number of runs with\na specified number of measurements (%i)\n', parametersMriSession.nTotalRuns, parametersMriSession.nRunsWithSpecifiedNumberOfMeasurements);
    fprintf('\nAborting analysis of file %s\n', parametersMriSession.strParametersMriSessionFile);
else
    parametersMriSession.bNoCriticalErrorsDetected = true;
end

parametersMriSession.nDicomFiles = sum(parametersMriSession.nMeasurementsInRun);


end


function parametersMriSession = determineFeasibilityOfEpiDistortionCorrectionATWM1(parametersMriSession, fileIndex)
%%% Check, whether each WM or LOC run is preceded by a COPE run
combFileIndex = [fileIndex.WM, fileIndex.LOC];
precFileIndex = combFileIndex - 1;

%%% Case, when run preceding WM or LOC run is invalid
if ~isempty(parametersMriSession.fileIndexInvalidRuns)
    indexInvalidRun = find(ismember(precFileIndex, parametersMriSession.fileIndexInvalidRuns));
    for cr = 1:numel(indexInvalidRun)
        indexRuns = 1:parametersMriSession.fileIndexFmr_COPE(indexInvalidRun(cr));
        indexPreviousValidRun = setdiff(indexRuns, parametersMriSession.fileIndexInvalidRuns);
        indexPreviousValidRun = indexPreviousValidRun(end);
        if ismember(indexPreviousValidRun, parametersMriSession.fileIndexFmr_COPE)
            precFileIndex(indexInvalidRun(cr)) = indexPreviousValidRun;
        end
    end
end

parametersMriSession.bMatchingEpiDistortionCorrectionScanExists = ismember(precFileIndex, fileIndex.COPE);

if parametersMriSession.bMatchingEpiDistortionCorrectionScanExists == true
    parametersMriSession.bEpiDistortionCorrectionPossible = true;
else
    parametersMriSession.bEpiDistortionCorrectionPossible = false;
    iMissingEpiDistortionCorrectionScan = find(~parametersMriSession.bMatchingEpiDistortionCorrectionScanExists);
    for cedcs = 1:numel(iMissingEpiDistortionCorrectionScan)
        fprintf('CHANGE MESSAGE \nError!\nPreceding EPI distortion correction scan missing for run %i!', combFileIndex(iMissingEpiDistortionCorrectionScan));
    end
end


end


function parametersMriSession = compareNumberOfMeasurementsInEachRunATWM1(parametersMriSession, fileIndex, parametersStudy, parametersStructuralMriSequenceHighRes, parametersStructuralMriSequenceLowRes, parametersFunctionalMriSequence_WM, parametersFunctionalMriSequence_LOC, parametersFunctionalMriSequence_COPE)
global iStudy

strNrOfMeasurementsInStructuralRun      = 'nMeasurementsInStructuralRun';
strNrOfMeasurementsInFunctionalRun_WM   = 'nMeasurementsInFunctionalRun_WM';
strNrOfMeasurementsInFunctionalRun_LOC  = 'nMeasurementsInFunctionalRun_LOC';
strNrOfMeasurementsInFunctionalRun_COPE = 'nMeasurementsInFunctionalRun_COPE';

aStrRunTypes = {
    fileIndex.structuralRuns    parametersStructuralMriSequenceHighRes.strSequence  parametersMriSession.nStructuralRuns        strNrOfMeasurementsInStructuralRun          parametersStructuralMriSequenceHighRes.nSlices  parametersStructuralMriSequenceLowRes.nSlices
    fileIndex.WM                parametersStudy.strWorkingMemoryTask                parametersMriSession.nFunctionalRuns_WM     strNrOfMeasurementsInFunctionalRun_WM       parametersFunctionalMriSequence_WM.nVolumes     []
    fileIndex.LOC               parametersStudy.strLocalizer                        parametersMriSession.nFunctionalRuns_LOC    strNrOfMeasurementsInFunctionalRun_LOC      parametersFunctionalMriSequence_LOC.nVolumes    []
    fileIndex.COPE	            parametersStudy.strMethodEpiDistortionCorrection    parametersMriSession.nFunctionalRuns_COPE   strNrOfMeasurementsInFunctionalRun_COPE     parametersFunctionalMriSequence_COPE.nVolumes   []
    };
nRunTypes = size(aStrRunTypes);
nRunTypes = nRunTypes(1);

for c = 1:nRunTypes
    for cr = 1:aStrRunTypes{c, 3}
        parametersMriSession.(matlab.lang.makeValidName(aStrRunTypes{c, 4}))(cr) = parametersMriSession.nMeasurementsInRun(aStrRunTypes{c, 1}(cr));
        parametersMriSession.bMatchingNumberOfMeasurements{c, cr} = isequal(parametersMriSession.(genvarname(aStrRunTypes{c, 4}))(cr), aStrRunTypes{c, 5});
        hFunction = str2func(sprintf('detectStructuralRun%s', iStudy));
        parametersMriSession = feval(hFunction, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrRunTypes, c, cr, strNrOfMeasurementsInStructuralRun);
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
        fprintf('Error!\nNumber of Measurements does not match the predefined values for:\n%s run %i\nOverall run #: %i\n\n', aStrRunTypes{row(c), 2}, col(c), aStrRunTypes{row(c), 1}(col(c)));
    end
end


end


function parametersMriSession = detectStructuralRunATWM1(parametersMriSession, parametersStructuralMriSequenceHighRes, aStrRunTypes, c, cr, strNrOfMeasurementsInStructuralRun)
%%% Search for standard and / or low res anatomical scans
if strcmp(aStrRunTypes{c, 2}, parametersStructuralMriSequenceHighRes.strSequence)
    if cr == 1
        if parametersMriSession.bMatchingNumberOfMeasurements{c, cr} == true
            parametersMriSession.bStructuralMriStandarResAcquired = true;
            parametersMriSession.bStructuralMriLowResAcquired = false;
        else
            parametersMriSession.bMatchingNumberOfMeasurements{c, cr} = isequal(parametersMriSession.(genvarname(strNrOfMeasurementsInStructuralRun))(cr), aStrRunTypes{c, 6});
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
            parametersMriSession.bMatchingNumberOfMeasurements{c, cr} = isequal(parametersMriSession.(genvarname(strNrOfMeasurementsInStructuralRun))(cr), aStrRunTypes{c, 6});
            if parametersMriSession.bMatchingNumberOfMeasurements{c, cr} == true && parametersMriSession.bStructuralMriLowResAcquired == false
                parametersMriSession.bStructuralMriLowResAcquired = true;
            end
        end
    end
end


end


function parametersMriSession = evaluateStructuralRunsATWM1(parametersMriSession)
if parametersMriSession.bStructuralMriStandarResAcquired == false && parametersMriSession.bStructuralMriLowResAcquired == true
    fprintf('Warning!\nNo standard resolution structural run acquired!\n');
end
if parametersMriSession.bStructuralMriStandarResAcquired || parametersMriSession.bStructuralMriLowResAcquired == true
    parametersMriSession.bValidStructuralMriAcquired = true;
else
    parametersMriSession.bValidStructuralMriAcquired = false;
    fprintf('Error!\nNo valid structural run acquired!\n');
end


end


function parametersMriSession = compareNumberOfAcquiredRunsATWM1(parametersMriSession)
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
    fprintf('Not all runs acquired in %s %i\n', parametersStudy.strSession, iSession);
end


end


function parametersMriSession = finalEvaluationOfFileATWM1(parametersMriSession)
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
    fprintf('\nOne or more errors found in file %s!\n', parametersMriSession.strParametersMriSessionFile);
    fprintf('Data processing cannot proceed!\nPlease re-check the file manually.\n');
end


end