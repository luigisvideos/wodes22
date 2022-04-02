function [node] = getGraphNode(nodeID,graph)
node=[];
if isKey(graph,nodeID)
    node=graph(nodeID);
end
end

