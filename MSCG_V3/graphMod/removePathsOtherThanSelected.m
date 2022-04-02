function [tree] = removePathsOtherThanSelected(tree,selectedNodesIDPath,selectedTransitionsPath)
    % removes from tree all nodes belonging to paths that are not equal to
    % the given path. returns the updated tree.
    % it also yields removedBunch, that is a a copy of the removed path,
    % starting from the first node in selectedNodesIDPath and ending in the
    % leaf nodes of the removed path. Operations needed to perform this
    % second task are marked by "***". These nodes are tagged as "stopped"
    
    function theTree = removeSuccessor(theTree,childID, fatherID,transitionsSet)
        for s=1:length(transitionsSet)
            [theTree(childID),theTree(fatherID)]=delinkChildAndFather(theTree(childID),theTree(fatherID),transitionsSet(s));
        end
        remove(theTree,childID);
    end
    
    
    for i=1:length(selectedNodesIDPath)-1
       currentNodeID =  selectedNodesIDPath{i};
       currentTransition = selectedTransitionsPath(i);
       
       
       [successorNodes,transitions] = getSuccessorNodes(tree,currentNodeID);
       for j=1:length(successorNodes)
           thisSuccessorID = getNodeID(successorNodes(j));
           transitionsSet = transitions{j};
           
           
           if not(isequal(thisSuccessorID,selectedNodesIDPath{i+1})) % if the currently selected successor is not along the given path, delete it
               
               tree = removeSuccessor(tree,thisSuccessorID, currentNodeID,transitionsSet);
                              
           end
           
       end
       
    end
end