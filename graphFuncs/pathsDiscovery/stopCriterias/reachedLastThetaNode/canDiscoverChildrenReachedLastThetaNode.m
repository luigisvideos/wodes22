function [bool,ASO] = canDiscoverChildrenReachedLastThetaNode(ASO)
    if ASO.error 
        bool = false;
        return;
    end
    bool = not(ASO.consumedInstances==ASO.initInstances && isequal(ASO.thisNodeTransition,ASO.transition));
    if not(bool)
        ASO.stop = true;
    end
end