function [bool,ASO] = canStoreBranchToPathsReachedLastThetaNode(ASO)
    
    bool = not(ASO.error);
    ASO.exit = true;
    ASO.error = false;

end