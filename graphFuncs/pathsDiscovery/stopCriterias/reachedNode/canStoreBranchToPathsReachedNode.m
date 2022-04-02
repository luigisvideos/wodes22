function [bool,ASO] = canStoreBranchToPathsReachedNode(ASO)
    bool = isequal(ASO.currentIDPath{end},ASO.nodeToReachID);
end