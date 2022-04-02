function [ child,father,outTransitionInfos ] = delinkChildAndFather( child,father,linkingTransition )
outFromFatherMap = getOutNodesMap(father);
inToChildMap = getInNodesMap(child);

%removing child from father
%N.B. never can happen that from a state with a transition multiple states
%are reached
if length(outFromFatherMap(getNodeID(child)))==1
    remove(outFromFatherMap,getNodeID(child)); 
else
    outFromFatherMap(getNodeID(child)) = setdiff(outFromFatherMap(getNodeID(child)),linkingTransition);
end
father.outTransitions = setdiff(father.outTransitions,linkingTransition);
outTransitionInfos = father.outTransitionsInfos(linkingTransition);
remove(father.outTransitionsInfos,linkingTransition);
father.out = outFromFatherMap;

%removing father from child
%N.B. a marking could be reached with the same transition from different states
inKeyLogIndexes = getLogicalKeyIndecesFromValue( inToChildMap,linkingTransition );
if(sum(inKeyLogIndexes) == 1)
    child.inTransitions = setdiff(child.inTransitions,linkingTransition);
end
if length(inToChildMap(getNodeID(father)))==1
    remove(inToChildMap,getNodeID(father));
else
    inToChildMap(getNodeID(father)) = setdiff(inToChildMap(getNodeID(father)),linkingTransition);
end
 
child.in=inToChildMap;
if(isequal(getNodeID(child),getNodeID(father)))
    child.outTransitions = father.outTransitions;
    father.inTransitions = child.inTransitions;
end

end
