function [bool,ASO] = canDiscoverChildrenReachedNode(ASO)
    bool = not(isequal(ASO.thisNodeID,ASO.nodeToReachID));
end

