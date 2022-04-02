function [successorNodes,transitions] = getSuccessorNodes(graph,startingNodeID)
    startingNode = graph(startingNodeID);
    outTransitions = getOutTransitions(startingNode);
    successorNodes=[];
    transitions=[];
    for i=1:length(outTransitions)
        successorNodes=[successorNodes,getSuccessorNode(graph,startingNode,outTransitions(i))];
        transitions=[transitions,{outTransitions(i)}];
    end
end

