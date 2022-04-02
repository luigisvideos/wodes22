function [ logicalIndices ] = getLogicalKeyIndecesFromValue( map,value )

logicalIndices = cellfun(@(x)any(ismember(x,value)),values(map));
end

