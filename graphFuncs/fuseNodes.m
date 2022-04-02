function [ graph ] = fuseNodes( graph, remainingNode, toDeleteNode, dontCheckConsistency )
%fuses two nodes but does not delete the toDeleteOne

if(not(exist('dontCheckConsistency','var')))
    dontCheckConsistency=false;
end

% first check if same nodes are reached with each output transition (only
% done if dontCheckConsistency=false)
if(not(dontCheckConsistency))
    assert(isequal(getOutTransitions(remainingNode),getOutTransitions(toDeleteNode)),'Nodes must have same output transitions');
    transitionsToConsider = getOutTransitions(remainingNode);
    for i=1:length(transitionsToConsider)
       tr= transitionsToConsider(i);
       assert(isequal(getReachedNodeByTransition( graph, getNodeID(remainingNode), tr),...
           getReachedNodeByTransition( graph, getNodeID(toDeleteNode), tr)),'Nodes must reach with each transition the same node');
    end
end


% now, delete output arcs from the node that must be deleted, and link them
% as outputs of the remaining node
outNodesMap = getOutNodesMap(toDeleteNode);
outNodes = keys(outNodesMap);
outTransitions = values(outNodesMap);
for k=1:length(outNodes)
    for t=1:length(outTransitions{k})
        [graph(outNodes{k}),toDeleteNode,infos{t}] = delinkChildAndFather( graph(outNodes{k}),toDeleteNode,outTransitions{k}(t) );
    end
    for t=1:length(outTransitions{k})
        if isempty(find(remainingNode.outTransitions==outTransitions{k}(t), 1))
            [graph(outNodes{k}),remainingNode] = linkChildAndFather( graph(outNodes{k}),remainingNode,outTransitions{k}(t),infos{t} );
        end
    end
end

%then, for each input node, link it to the remaining one
inToDeleteMap = getInNodesMap(toDeleteNode);
sourceNodes = keys(inToDeleteMap);
transitions = values(inToDeleteMap);
for i=1:length(sourceNodes)
    sourceNode = graph(sourceNodes{i});
    
    for t=1:length(transitions{i})
        [toDeleteNode,sourceNode,trInfos{t}] = delinkChildAndFather( toDeleteNode,sourceNode,transitions{i}(t) );
    end
    for t=1:length(transitions{i})
        [remainingNode,sourceNode] = linkChildAndFather( remainingNode,sourceNode, transitions{i}(t),trInfos{t} );
    end
end

end

