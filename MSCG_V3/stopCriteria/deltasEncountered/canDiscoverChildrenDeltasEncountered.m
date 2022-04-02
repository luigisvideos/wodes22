function [bool,ASO] = canDiscoverChildrenDeltasEncountered(ASO)
    bool = not(isempty(ASO.remainingDeltas));
end

