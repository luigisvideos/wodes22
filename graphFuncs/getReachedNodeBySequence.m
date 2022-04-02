function [ reachedNode ] = getReachedNodeBySequence( graph, startNodeID, seq )
    
reachedNode = graph(startNodeID);
for i=1:length(seq)
    reachedNode=getReachedNodeByTransition(graph,getNodeID(reachedNode),seq(i));
end

end

