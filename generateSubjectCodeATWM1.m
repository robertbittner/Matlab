function [aSubject, subjectInformation] = generateSubjectCodeATWM1(subjectInformation);

global iStudy

parametersStudy         = eval(['parametersStudy', iStudy]);
parametersSubjectCode   = eval(['parametersSubjectCode', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

%%% Load group information
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);
nSubjects = aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL;
aStrAllSubjects = aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL;


usedIntegers = [];
for cs = 1:nSubjects
    %%% Read character codes, which have already been used
    aStrUsedSubjectCodes{cs} = strcat(aStrAllSubjects{cs}(1:2), aStrAllSubjects{cs}(5:7));
    aStrInitalCharacter{cs} = aStrAllSubjects{cs}(1);
    %%% Read number codes
    usedIntegers = [usedIntegers,  str2double(aStrAllSubjects{cs}(3:4))];
end


%%% Count the frequencey of occurence of each inital character
if nSubjects > 0
    aStrUniqueInitalCharacterIndex = sort(unique(aStrInitalCharacter));
    for cc = 1:length(parametersSubjectCode.validCharacters)
        initalLetterCountArray{cc} = strcmp({parametersSubjectCode.validCharacters(cc)}, aStrInitalCharacter);
        initalLetterCountVector(cc) = sum(initalLetterCountArray{cc});
    end
    
    %%% Create Array containing the least frequently occuring initial characters
    leastUsedCharacterIndex = find(initalLetterCountVector == min(initalLetterCountVector));
    for cc = 1:length(leastUsedCharacterIndex)
        aStrLeastUsedCharacters{cc} = parametersSubjectCode.validCharacters(leastUsedCharacterIndex(cc));
    end
else
    for cc = 1:length(parametersSubjectCode.validCharacters)
        aStrLeastUsedCharacters{cc} = parametersSubjectCode.validCharacters(cc);
    end
end


%%% Generate the subject code
%%% Generate random five character sequences
for ccode = 1:parametersSubjectCode.nGeneratedCodes
    for ci = 1:parametersSubjectCode.nRandomCharacters
        if ci == 1
            iRandomInteger = randi(numel(aStrLeastUsedCharacters));
            randomCharacters(ci) = aStrLeastUsedCharacters{iRandomInteger};
        else
            bValidCharacter = false;
            while bValidCharacter == false
                iRandomInteger = randi(numel(parametersSubjectCode.validCharacters));
                randomCharacters(ci) = parametersSubjectCode.validCharacters(iRandomInteger);
                if isempty(strfind(randomCharacters(1:ci - 1), randomCharacters(ci)))
                    bValidCharacter = true;
                end
            end
        end
    end
    strCode{ccode} = randomCharacters;
end

%%% Compare generated codes with preexisting codes and select only new
%%% codes
strCode = unique(strCode);

if nSubjects > 0
    aStrNewCodes = {};
    counterNewCodes = 0;
    for ccode = 1:numel(strCode)
        if sum(strcmp(aStrUsedSubjectCodes, strCode{ccode})) == 0
            counterNewCodes = counterNewCodes + 1;
            aStrNewCodes{counterNewCodes} = strCode{ccode};
        end
    end
else
    aStrNewCodes = strCode;
end
%%% Randomly select a valid character code
strCodeSelected = strCode{randi(numel(aStrNewCodes))};



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
for cs = 1:nSubjects
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

%%% Generate random integers 
iRandomInteger = randi(numel(vValidCodeIntegers));
integerCode = vValidCodeIntegers(iRandomInteger);
integerCodeSelected = integerCode;

%%% Combine random characters and integers to create the final code:
%%% Two characters, two integers, three characters
strSubjectCode = sprintf('%s%i%s', strCodeSelected(1:2), integerCodeSelected, strCodeSelected(3:5));
subjectInformation.strSubjectCode = strSubjectCode;


end