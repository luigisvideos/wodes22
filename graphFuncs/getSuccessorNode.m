function [successorNode] = getSuccessorNode(graph,startingNode,transition)
    outTransitions = getOutTransitions(startingNode);
    successorNode=[];
    if(isempty(find(outTransitions==transition, 1)))
        return;
    end
    
    outNodesMap = getOutNodesMap( startingNode );
    destNodesId = keys(outNodesMap);
    successorId = destNodesId(getLogicalKeyIndecesFromValue( outNodesMap,transition ));
    successorNode = graph(successorId{1});
end

