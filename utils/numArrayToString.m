function [ string ] = numArrayToString( array )
string='[';

for i=1:length(array)
    string = [string,myInt2str(array(i))];
    if(i<length(array))
        string = [string,', '];
    end
end
string = [string,']'];
end

