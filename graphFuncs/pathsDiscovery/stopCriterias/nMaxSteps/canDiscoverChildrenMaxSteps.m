function [bool,ASO] = canDiscoverChildrenMaxSteps(ASO)
    bool = ASO.stepsCounter<ASO.nMaxSteps-1;
end

