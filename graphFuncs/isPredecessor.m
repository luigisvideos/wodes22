function [bool] = isPredecessor(fatherID,childID, transition, graph)
    %ISPREDECESSOR Checks if fatherID is a real predecessor of childID
    [predecessorNodes,transitions] = getPredecessorNodes(graph,childID);
    bool=false;
    for i=1:length(predecessorNodes)
        predID = getNodeID(predecessorNodes(i));
        if isequal(predID,fatherID) && isSmallerArrayContainedInBigger(transitions{i},transition)
            bool=true;
            return;
        end
    end
end

