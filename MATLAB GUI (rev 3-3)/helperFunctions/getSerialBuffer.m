function [ buff ] = getSerialBuffer(s)

i=1;
buff={};
while(s.BytesAvailable)
    buff{i} = fscanf(s,'%c');
    i=i+1;
end

end

