function [predecessorNodes,transitions] = getPredecessorNodes(graph,startingNodeID)
    startingNode = graph(startingNodeID);
    inNodesMap = getInNodesMap( startingNode );
    predecessorNodesIDs = keys(inNodesMap);
    transitionLinks = values(inNodesMap);
    predecessorNodes=[];
    transitions=[];
    for i=1:length(predecessorNodesIDs)
        predecessorNodes = [predecessorNodes,graph(predecessorNodesIDs{i})];
        transitions=[transitions,transitionLinks(i)];
    end
end

