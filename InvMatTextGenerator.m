%#ok<*SAGROW> 
clear
textLength = 100;
readLength = 6;
writeLength = 1;

file = fopen('text.txt');

text = textscan(file,'%s','delimiter',{' ','\n','\t'});
text = lower(text{1,1});

j = 1;
for i=1:length(text)
    word = text{i,1};
    if (isempty(word))
        continue
    end
    if (word(end)=='.' || word(end)==',' || word(end)==':' || word(end)==';' ...
            || word(end)=='?' || word(end)=='!' || word(end)=='"' || word(end)==')')
        tokens{j} = word(1:end-1); 
        tokens{j+1} = word(end);
        j = j+2;
    elseif (word(1)=='"' || word(end)=='(')
        tokens{j} = word(1); 
        tokens{j+1} = word(2:end);
        j = j+2;
    else
        tokens{j} = word;
        j = j+1;
    end
end

j = 1;
readTokens = "-";
for i=1:length(tokens)-readLength+1-writeLength
    readToken = tokens{i};
    for k=2:readLength
        readToken = strcat(readToken, " ", tokens{i+k-1});
    end
    containsToken = false;
    for k=1:length(readTokens)
        if (readTokens(k) == readToken)
            containsToken = true;
            break
        end
    end
    if (not(containsToken))
        readTokens(j) = readToken;
        j = j+1;
    end
end

j = 1;
writeTokens = "-";
for i=readLength+1:length(tokens)-writeLength+1
    writeToken = tokens{i};
    for k=2:writeLength
        writeToken = strcat(writeToken, " ", tokens{i+k-1});
    end
    containsToken = false;
    for k=1:length(writeTokens)
        if (writeTokens(k) == writeToken)
            containsToken = true;
            break
        end
    end
    if (not(containsToken))
        writeTokens(j) = writeToken;
        j = j+1;
    end
end

readTokensAll = "-";
writeTokensAll = "-";
for i=1:length(tokens)-readLength+1-writeLength
    tempReadToken = tokens{i};
    for k=2:readLength
        tempReadToken = strcat(tempReadToken, " ", tokens{i+k-1});
    end
    tempWriteToken = tokens{i+readLength};
    for k=2:writeLength
        tempWriteToken = strcat(tempWriteToken, " ", tokens{i+readLength+k-1});
    end
    readTokensAll(i) = tempReadToken;
    writeTokensAll(i) = tempWriteToken;
end

instancesMatrix = zeros(length(readTokens),length(writeTokens));
for i=1:length(readTokens)
    tempReadToken = readTokens(i);
    indexesAll = find(readTokensAll == tempReadToken);
    tempWriteTokens = writeTokensAll(indexesAll);
    for k=1:length(tempWriteTokens)
        tempWriteToken = tempWriteTokens(k);
        m = find(writeTokens == tempWriteToken);
        instancesMatrix(i,m) = instancesMatrix(i,m) + 1;
    end
end
sparseMatrix = sparse(instancesMatrix);

totalInstances = zeros(1,length(readTokens));
for i=1:length(readTokens)
    totalInstances(i) = sum(sparseMatrix(i,:));
end

startIndex = randi([1, length(readTokensAll)]);
outputText = readTokensAll(startIndex);
loopLength = ceil(textLength/writeLength) - readLength;
for i=1:loopLength
    words = strsplit(outputText,' ');
    tempReadToken = words(end-readLength+1);
    for k=2:readLength
        tempReadToken = strcat(tempReadToken, " ", words(end-readLength+k));
        readIndex = find(readTokens == tempReadToken);
        if (not(isempty(totalInstances(readIndex))))
            randomInt = randi([1, totalInstances(readIndex)]);
        else
            tempWriteToken = writeTokens(randi([1, length(writeTokens)]));
            outputText = strcat(outputText, " ", tempWriteToken);
            continue
        end

        partialSum = 0;
        for writeIndex=1:length(writeTokens)
            partialSum = partialSum + sparseMatrix(readIndex, writeIndex);
            if (partialSum >= randomInt)
                break
            end
        end
        tempWriteToken = writeTokens(writeIndex);
        outputText = strcat(outputText, " ", tempWriteToken);
    end
end

outputText

