function [ BaudEnum ] = GetBaudEnum( BaudRate )
%GETBAUDENUM Get the Enum corresponding to the correct baud rate
%
%   GetBaudEnum() % Returns the entire vector of possible Baud Rates
%
%   GetBaudEnum(BaudRate) % Returns the index of the vector corresponding
%                           to the input BaudRate (enum #)
%                         % BaudRate must be a number

BaudEnumVec = [ 2400
                4800
                9600
                14400
                19200
                28800
                38400
                57600
                115200 ];

switch nargin
    case 0
        BaudEnum = BaudEnumVec;

    case 1
        if isnumeric(BaudRate)
            idx = find(BaudEnumVec==BaudRate);
            
            if length(idx)~=0
                BaudEnum=idx;
            else
                error('BaudRate did not match any of the baud rates in the list')
            end
            
        else
            error('BaudRate must be a number')
        end
end

end

