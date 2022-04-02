function [ reachedNode ] = getReachedNodeByTransition( graph, startNodeID, tr )
%returns a node
startNode= graph(startNodeID);
map = getOutNodesMap(startNode);
logicalIndex = getLogicalKeyIndecesFromValue( map,tr );
if sum(logicalIndex)== 0
    reachedNode = [];
    return;
end
if not(sum(logicalIndex)==1)
    warning('Reached more than one states with a single transition. Taking first node');
    idx=find(logicalIndex==1,1);
    vec = zeros(size(logicalIndex));
    vec(idx)=1;
    logicalIndex=logical(vec);
end
outNodes= keys(map);
reachedNode = graph(outNodes{logicalIndex});


