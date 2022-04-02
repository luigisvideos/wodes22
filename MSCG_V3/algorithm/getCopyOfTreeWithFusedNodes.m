function [graph] = getCopyOfTreeWithFusedNodes(originalGraph,equivalenceMap,dupIDs)
    graph = copy(originalGraph);
    % then merge equivalent nodes in the dup set
    remainingNodes = keys(equivalenceMap);
    toDeleteNodes = values(equivalenceMap);
    for i=1:length(remainingNodes)
        associatedNodes = toDeleteNodes{i};
        for j=1:length(associatedNodes)
            if not(isempty(findStringInCellArray(associatedNodes{j},dupIDs)))
                remainingNode = getGraphNode(remainingNodes{i},graph);
                associatedNode = getGraphNode(associatedNodes{j},graph);
                graph=fuseNodes(graph,remainingNode,associatedNode,true);
            end
        end
    end
end

