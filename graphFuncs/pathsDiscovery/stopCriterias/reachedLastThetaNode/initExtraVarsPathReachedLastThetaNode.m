function ASO = initExtraVarsPathReachedLastThetaNode(transition,startNode)
    ASO.transition=transition;
    %the initial degree is important: if initially 2 instances of
    %transitions are allocated, then the last instance is removed when two
    %instances are consumed
    
    ASO.initInstances = getTransitionInstancesInClass(startNode,transition);
    ASO.consumedInstances=0;
    ASO.error=false;
    ASO.exit=false;
    ASO.stop = false;
end