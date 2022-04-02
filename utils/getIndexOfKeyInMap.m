function [idx] = getIndexOfKeyInMap(key,map)
idx= findStringInCellArray(key,keys(map));
assert(not(isempty(idx)));
end

