function [ buff ] = getSerialBufferNum(s,numLines)

i=1;
buff={};
for i=1:numLines
    buff{i} = fscanf(s,'%c');
end

end

