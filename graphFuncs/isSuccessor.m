function [bool] = isSuccessor(childID, fatherID, transition, graph)
    %ISPREDECESSOR Checks if fatherID is a real predecessor of childID
    [successorNode] = getSuccessorNode(graph,graph(fatherID),transition);
    if isempty(successorNode)
        bool=false;
        return;
    end
    bool = isequal(childID,getNodeID(successorNode));
end