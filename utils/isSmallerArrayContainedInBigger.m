function [ res,map ] = isSmallerArrayContainedInBigger( a1,a2 )
% map maps each index i of the smaller array with the
% first occurrence of the same element in the bigger array
assert((iscell(a1) && iscell(a2)) || (not(iscell(a1)) && not(iscell(a2))),'Given arrays must be arrays or cell arrays');
if((isempty(a1) && ~isempty(a2)) || (isempty(a2) && ~isempty(a1)) )
    res=false;
    return;
end
if(length(a1)<length(a2))
    smaller=a1;
    bigger=a2;
else
   smaller=a2;
   bigger=a1;
end
map=containers.Map( 'KeyType','int32', 'ValueType','int32'); %initializing map;
for i=1:length(smaller)
    if(iscell(a1))
        cf = cellfun(@(x)isequal(x,smaller{i}),bigger);
        if(not(any(cf)))
            res=false;
            map = [];
            return;
        else
           map(i) =  find(cf==1,1);
        end
    else
        af=arrayfun(@(x)isequal(x,smaller(i)),bigger);
        if(not(any(af)))
            res=false;
            map = [];
            return;
        else
           map(i) =  find(af==1,1);
        end     
    end
end
res=true;

end

