function encryptedSubjectName = encryptSubjectNameATWM1();

global iStudy

iStudy = 'ATWM1';


parametersStudy     = eval(['parametersStudy', iStudy]);
parametersGroups    = eval(['parametersGroups', iStudy]);

%%% Load group information
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.iImaging]);
aAllSubjects = aSubject.ATWM1_IMAGING.AllSubjects;

%[SELECTION,OK] = listdlg('ListString', parametersGroups.aStrGroups);

%{
    'ListString'    cell array of strings for the list box.
    'SelectionMode' string; can be 'single' or 'multiple'; defaults to
                    'multiple'.
    'ListSize'      [width height] of listbox in pixels; defaults
                    to [160 300].
    'InitialValue'  vector of indices of which items of the list box
                    are initially selected; defaults to the first item.
    'Name'          String for the figure's title; defaults to ''.
    'PromptString'  string matrix or cell array of strings which appears 
                    as text above the list box; defaults to {}.
    'OKString'      string for the OK button; defaults to 'OK'.
    'CancelString'  string for the Cancel button; defaults to 'Cancel'.

%}


%aSubject = aSubject.WMC2_MRI_EXP_1;

%%% Numbers based on subject letters
%%{
for s = 1:numel(aAllSubjects)
    aStrUsedRandomLetterCode{s} = aAllSubjects{s}(1:4);
    aStrInitalLetter{s} = aAllSubjects{s}(1);
end

initalLetterIndex = unique(aStrInitalLetter); 
for l = 1:length(initalLetterIndex)
%    test = initalLetterIndex{l}
    initalLetterCountArray{l} = strcmp(initalLetterIndex{l}, aStrInitalLetter);
    initalLetterCountVector(l) = sum(initalLetterCountArray{l});
end

leastUsedLetterIndex = find(initalLetterCountVector == min(initalLetterCountVector));
for l = 1:length(leastUsedLetterIndex)
    leastUsedLetterArray{l} = initalLetterIndex{leastUsedLetterIndex(l)};
end

encryptedSubjectName = '';
numericalOutput = '';
%asciiCodeSpaceCapitalLetters = (1:10)

while length(numericalOutput) ~= 4
%%% Ask for the 
    %subjectID = newid('Please enter the last two letters of the subjects family name and first name as captial letters, e.g. "ERRT"', 'Generate ID-No.');
    subjectID = {'TEST'}
    numericalOutput = double(subjectID{1});
end


numCode = '';
for i = 1:length(numericalOutput)
	numCode = [numCode, num2str(numericalOutput(i))];
end

permutationVectorArray = {
    [6 1 4 7 8 3 5 2]
    [7 3 8 6 2 4 5 1]
    [4 8 6 5 2 1 3 7]
    [3 8 1 5 4 7 6 2]
    };
indexVector = ceil(rand*length(permutationVectorArray));
permutationVector = permutationVectorArray{indexVector};
permNumCode = '';
for n = 1:length(numCode)
    permNumCode = [permNumCode, numCode(permutationVector(n))];
end
numericalCode = [permNumCode, num2str(indexVector)];
%}


% ZU34KAS

%%% Generate random integers
vPossibleIntegers = 11:99;
iRandomInteger = randi(numel(vPossibleIntegers));
integerCode = vPossibleIntegers(iRandomInteger)
integerCodeSelected = integerCode



%%% Generate random five character sequences
nRandomCharacters = 5;
nGeneratedCodes = 1000;
excludedCharacters = 'BIOS'; 
excludedIntegers = double(excludedCharacters);

for ccode = 1:nGeneratedCodes
    for ci = 1:nRandomCharacters
        bValidLetter = false;
        while bValidLetter == false
            randomInteger(ci) = ceil(rand*26) + 64;
            if ismember(randomInteger(ci), excludedIntegers)
                bValidLetter = false;
            else
                bValidLetter = true;
            end
        end
        %if ismember
    end
    strCode{ccode} = char(randomInteger);
end

strCodeSelected = strCode{ccode}

%%% Combine random characters and integers

encryptedSubjectName = sprintf('%s%i%s', strCodeSelected(1:2), integerCodeSelected, strCodeSelected(3:5))

nGeneratedCodes = 1000;
for n = 1:nGeneratedCodes
    randomIntegerVector = 0;
    bValidLetterCode = false;
    while bValidLetterCode == false
        for i = 1:length(numericalOutput)
            alert2 = 0;
            while alert2 == 0; 
                %test = rand
                randomInteger = ceil(rand*26) + 64;
                if ismember(randomInteger, excludedIntegers) == 0
                    alert2 = 1;
                end
            end
            randomIntegerVector(i) = randomInteger;
        end
        if length(unique(randomIntegerVector)) == length(numericalOutput)
            bValidLetterCode = true;
        end
    end
    
    randomLetterArray{n} = char(randomIntegerVector);
    if ismember(randomLetterArray{n}, aStrUsedRandomLetterCode) == 1
        bValidLetterCode = false;
    end
end

randomLetterArray = unique(randomLetterArray);


for l = 1:length(randomLetterArray)
    initialRandomLetterArray{l} = randomLetterArray{l}(1);
end


matchIndex = [];
for l = 1:length(leastUsedLetterArray)
    index = find(strcmp(initialRandomLetterArray, leastUsedLetterArray{l}));
    matchIndex = [matchIndex, index];
end
matchIndex = sort(matchIndex);

reducedRandomLetterArray = randomLetterArray(matchIndex);
randomInteger = ceil(rand*length(reducedRandomLetterArray));
randomLetterCode = reducedRandomLetterArray{randomInteger};

%numericalCode = '  THIS IS NOT A CODE';

encryptedSubjectName = [randomLetterCode, numericalCode];


%%% Create timestamped backup of aSubject
format shortg
c = clock;

end