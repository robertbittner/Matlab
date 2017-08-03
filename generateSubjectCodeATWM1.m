function [aSubject, subjectInformation] = generateSubjectCodeATWM1(subjectInformation)

global iStudy

parametersStudy         = eval(['parametersStudy', iStudy]);
parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

%%% Load group information
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);

nrOfAllSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL;
aStrAllSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL;

nrOfSubjectsGroup = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.(matlab.lang.makeValidName(subjectInformation.strSelectedShortGroup));
aStrSubjectsGroup = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).Groups.(matlab.lang.makeValidName(subjectInformation.strSelectedShortGroup));

%%
%%% Read character and number codes, which have already been used
usedIntegers = [];
for cs = 1:nrOfAllSubjects
    %%% Read character codes
    aStrUsedSubjectCodes{cs} = strcat(aStrAllSubjects{cs}(1:2), aStrAllSubjects{cs}(5:7));
    aStrInitalCharacter{cs} = aStrAllSubjects{cs}(1);
    %%% Read number codes
    usedIntegers = [usedIntegers,  str2double(aStrAllSubjects{cs}(3:4))];
end


%%% Count the frequencey of occurence of each inital character
if nrOfAllSubjects > 0
    aStrUniqueInitalCharacterIndex = sort(unique(aStrInitalCharacter));
    for cic = 1:length(parametersSubjectCode.validCharacters)
        initalLetterCountArray{cic} = strcmp({parametersSubjectCode.validCharacters(cic)}, aStrInitalCharacter);
        initalLetterCountVector(cic) = sum(initalLetterCountArray{cic});
    end
    %%% Create array containing the least frequently occuring initial characters
    leastUsedCharacterIndex = find(initalLetterCountVector == min(initalLetterCountVector));
    for cic = 1:length(leastUsedCharacterIndex)
        aStrLeastUsedInitialCharacters{cic} = parametersSubjectCode.validCharacters(leastUsedCharacterIndex(cic));
    end
    %%% Create array containng the subject codes starting with a least
    %%% frequently occuring initial character
    for cic = 1:numel(aStrLeastUsedInitialCharacters)
        strInitialCharacter = aStrLeastUsedInitialCharacters{cic};
        aStrLeastUsedCharacterCodeStarts{cic} = aStrUsedSubjectCodes(contains(aStrInitalCharacter, strInitialCharacter));
    end
else
    for cic = 1:numel(parametersSubjectCode.validCharacters)
        aStrLeastUsedInitialCharacters{cic} = parametersSubjectCode.validCharacters(cic);
    end
end

%%
%%% Read character and number codes, which have already been used in the
%%% selected group
usedIntegersGroup = [];
for cs = 1:nrOfSubjectsGroup
    %%% Read character codes
    aStrUsedSubjectCodesGroup{cs} = strcat(aStrSubjectsGroup{cs}(1:2), aStrSubjectsGroup{cs}(5:7));
    aStrInitalCharacterGroup{cs} = aStrSubjectsGroup{cs}(1);
    %%% Read number codes
    usedIntegersGroup = [usedIntegersGroup,  str2double(aStrSubjectsGroup{cs}(3:4))];
end

%%% Count the frequencey of occurence of each inital character in the
%%% selected group
if nrOfSubjectsGroup > 0
    aStrUniqueInitalCharacterIndexGroup = sort(unique(aStrInitalCharacterGroup));
    for cic = 1:length(parametersSubjectCode.validCharacters)
        initalLetterCountArrayGroup{cic} = strcmp({parametersSubjectCode.validCharacters(cic)}, aStrInitalCharacterGroup);
        initalLetterCountVectorGroup(cic) = sum(initalLetterCountArrayGroup{cic});
    end
    %%% Create array containing the least frequently occuring initial characters
    leastUsedCharacterIndexGroup = find(initalLetterCountVectorGroup == min(initalLetterCountVectorGroup));
    for cic = 1:length(leastUsedCharacterIndexGroup)
        aStrLeastUsedInitialCharactersGroup{cic} = parametersSubjectCode.validCharacters(leastUsedCharacterIndexGroup(cic));
    end
    %%% Create array containng the subject codes starting with a least
    %%% frequently occuring initial character
    for cic = 1:numel(aStrLeastUsedInitialCharactersGroup)
        strInitialCharacterGroup = aStrLeastUsedInitialCharactersGroup{cic};
        aStrLeastUsedCharacterCodeStartsGroup{cic} = aStrUsedSubjectCodes(contains(aStrInitalCharacterGroup, strInitialCharacterGroup));
    end
else
    for cic = 1:numel(parametersSubjectCode.validCharacters)
        aStrLeastUsedInitialCharactersGroup{cic} = parametersSubjectCode.validCharacters(cic);
    end
end

%%
%%% Create arrays containing the least frequently occuring second
%%% characters for each initial character
for cic = 1:numel(aStrLeastUsedInitialCharacters)
    strInitialCharacter = aStrLeastUsedInitialCharacters{cic};
    for ccode = 1:numel(aStrLeastUsedCharacterCodeStarts{cic})
        aStrMostUsedSecondCharacters{cic}{ccode} = aStrLeastUsedCharacterCodeStarts{cic}{ccode}(2);
    end
    aStrLeastUsedSecondCharacters{cic} = regexprep(parametersSubjectCode.validCharacters, aStrMostUsedSecondCharacters{cic}, '');
    %%% Remove initial character from array to avoid codes such as 'ZZ...'
    aStrLeastUsedSecondCharacters{cic} = regexprep(aStrLeastUsedSecondCharacters{cic}, strInitialCharacter, '');
end

%%
%%% Create arrays containing the least frequently occuring second
%%% characters for each initial character in the selected group
if nrOfSubjectsGroup > 0
    for cic = 1:numel(aStrLeastUsedInitialCharactersGroup)
        strInitialCharacter = aStrLeastUsedInitialCharactersGroup{cic};
        if numel(aStrLeastUsedCharacterCodeStartsGroup{cic}) > 1
            for ccode = 1:numel(aStrLeastUsedCharacterCodeStartsGroup{cic})
                aStrMostUsedSecondCharactersGroup{cic}{ccode} = aStrLeastUsedCharacterCodeStartsGroup{cic}{ccode}(2);
            end
            aStrLeastUsedSecondCharactersGroup{cic} = regexprep(parametersSubjectCode.validCharacters, aStrMostUsedSecondCharactersGroup{cic}, '');
            %%% Remove initial character from array to avoid codes such as 'ZZ...'
            aStrLeastUsedSecondCharactersGroup{cic} = regexprep(aStrLeastUsedSecondCharactersGroup{cic}, strInitialCharacter, '');
        else
            aStrLeastUsedSecondCharactersGroup{cic} = '';
        end
    end
else
    for cic = 1:numel(parametersSubjectCode.validCharacters)
        aStrLeastUsedSecondCharactersGroup{cic} = parametersSubjectCode.validCharacters(cic);
    end
end

%%
%%% Create arrays with the intersection of the least used initial
%%% characters in all subjects and in the selected group.
aStrLeastUsedInitialCharactersIntersect = intersect(aStrLeastUsedInitialCharacters, aStrLeastUsedInitialCharactersGroup);
if numel(aStrLeastUsedInitialCharactersIntersect) > 0
    aStrLeastUsedInitialCharacters = aStrLeastUsedInitialCharactersIntersect;
end
indexIntersectInitialCharacterGroup = contains(aStrLeastUsedInitialCharactersGroup, aStrLeastUsedInitialCharacters);

%%% Create arrays with the intersection of the least used second characters
%%% in all subjects and in the selected group.
aStrLeastUsedSecondCharactersGroup = aStrLeastUsedSecondCharactersGroup(indexIntersectInitialCharacterGroup);
if numel(aStrLeastUsedSecondCharactersGroup) > 0
    for c = 1:numel(aStrLeastUsedSecondCharactersGroup)
        indexIntersectLeastUsedSecondCharacters = ismember(aStrLeastUsedSecondCharacters{c}, aStrLeastUsedSecondCharactersGroup{c});
        if sum(indexIntersectLeastUsedSecondCharacters) > 0
            aStrLeastUsedSecondCharacters{c} = aStrLeastUsedSecondCharacters{c}(indexIntersectLeastUsedSecondCharacters);
        end
    end
end

%%
nrOfLeastUsedInitialCharacters = numel(aStrLeastUsedInitialCharacters);

if nrOfLeastUsedInitialCharacters > 0
    ccomb = 0;
    for cic = 1:numel(aStrLeastUsedInitialCharacters)
        %%% Find all codes starting with selected initial character
        strInitialCharacter = aStrLeastUsedInitialCharacters{cic};
        for csc = 1:numel(aStrLeastUsedSecondCharacters{cic})
            ccomb = ccomb + 1;
            aStrLeastUsedCharacterCombinations{ccomb} = sprintf('%s%s', strInitialCharacter, aStrLeastUsedSecondCharacters{cic}(csc));
        end
    end
else
    for cic = 1:numel(parametersSubjectCode.validCharacters)
        for csc = 1:numel(parametersSubjectCode.validCharacters)
            aStrLeastUsedSecondCharacters{cic, csc} = parametersSubjectCode.validCharacters(csc);
        end
    end
end

%%% Generate the subject code
%%% Generate random five character sequences
for ccode = 1:parametersSubjectCode.nGeneratedCodes
    for ci = 1:parametersSubjectCode.nRandomCharacters
        if ci == 1
            iRandomInteger = randi(numel(aStrLeastUsedInitialCharacters));
            randomCharacters(ci) = aStrLeastUsedInitialCharacters{iRandomInteger};
        else
            bValidCharacter = false;
            while bValidCharacter == false
                iRandomInteger = randi(numel(parametersSubjectCode.validCharacters));
                randomCharacters(ci) = parametersSubjectCode.validCharacters(iRandomInteger);
                if ~contains(randomCharacters(1:ci - 1), randomCharacters(ci))
                    bValidCharacter = true;
                end
            end
        end
    end
    aStrCode{ccode} = randomCharacters;
end

%%% Compare generated codes with preexisting codes and select only new
%%% codes
aStrCode = unique(aStrCode);

if nrOfAllSubjects > 0
    aStrNewCodes = {};
    counterNewCodes = 0;
    for ccode = 1:numel(aStrCode)
        if sum(strcmp(aStrUsedSubjectCodes, aStrCode{ccode})) == 0
            counterNewCodes = counterNewCodes + 1;
            aStrNewCodes{counterNewCodes} = aStrCode{ccode};
        end
    end
else
    aStrNewCodes = aStrCode;
end

%%% While loop to ensure a valid combination of characters and integers
bValidCodeIntegersExist = false;
while ~bValidCodeIntegersExist
    
    %%% Test whether the combination of the first two characters has not
    %%% already been used
    bGeneratedCodeValid = false;
    while ~bGeneratedCodeValid
        %%% Randomly select a character code
        strCodeSelected = aStrCode{randi(numel(aStrNewCodes))};
        strCodeStart = strCodeSelected(1:2);
        indexValidCode = strfind(aStrLeastUsedCharacterCombinations, strCodeStart);
        if find(not(cellfun('isempty', indexValidCode)))
            bGeneratedCodeValid = true;
        end
    end
    
    
    %%% Exlude integers, which have already been used, except in case all
    %%% integers have already been used.
    usedIntegers = unique(usedIntegers);
    
    if numel(usedIntegers) ~= numel(parametersSubjectCode.vValidCodeIntegers)
        parametersSubjectCode.vValidCodeIntegers = parametersSubjectCode.vValidCodeIntegers(~ismember(parametersSubjectCode.vValidCodeIntegers, usedIntegers));
    end
    
    %%% Determine which integers have already been used in combination with the
    %%% first character of the selected character code
    strFirstCharacter = strCodeSelected(1);
    counterInvalidIntegers = 0;
    vInvalidCodeIntegers = [];
    for cs = 1:nrOfAllSubjects
        if strcmp(strFirstCharacter, aStrInitalCharacter{cs})
            counterInvalidIntegers = counterInvalidIntegers + 1;
            invalidInteger = str2double(aStrAllSubjects{cs}(3:4));
            vInvalidCodeIntegers = [vInvalidCodeIntegers, invalidInteger];
        end
    end
    
    %%% Determine invalid blocks of integers (e.g. 50-59) for first character
    %%% of the selected character code
    vExcludedIntegers = [];
    for ci = 1:numel(vInvalidCodeIntegers)
        integer = num2str(vInvalidCodeIntegers(ci));
        integer = integer(1);
        indexStart  = str2double(strcat(integer, '0'));
        indexEnd    = str2double(strcat(integer, '9'));
        vExcludedIntegers = [vExcludedIntegers, indexStart:indexEnd];
    end
    vExcludedIntegers = unique(vExcludedIntegers);
    
    %%% Remove invalid block of integers
    vValidCodeIntegers = parametersSubjectCode.vValidCodeIntegers;
    vValidCodeIntegers = vValidCodeIntegers(~ismember(vValidCodeIntegers, vExcludedIntegers));
    
    %%% Check, whether there are valid code integers for the selected intial
    %%% characters
    if ~isempty(vValidCodeIntegers)
        bValidCodeIntegersExist = true;
    end
end

%%% Generate random integers
iRandomInteger = randi(numel(vValidCodeIntegers));
integerCode = vValidCodeIntegers(iRandomInteger);
integerCodeSelected = integerCode;

%%% Combine random characters and integers to create the final code:
%%% Two characters, two integers, three characters
strSubjectCode = sprintf('%s%i%s', strCodeSelected(1:2), integerCodeSelected, strCodeSelected(3:5));
subjectInformation.strSubjectCode = strSubjectCode;


end