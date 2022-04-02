function [ numArray ] = stringToNumArray( string )
    assert(isequal(string(1),'['));
    string(1)=[];
    assert(isequal(string(end),']'));
    string(end)=[];
    numArray=textscan(string,'%d','Delimiter',',');
    numArray=[numArray{:}];
end

