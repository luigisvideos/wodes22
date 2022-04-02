function [graph] = updateGraphNodes(nodes,graph)
    for i=1:length(nodes)
        assert(isKey(graph,getNodeID(nodes{i})));
        graph(getNodeID(nodes{i})) = nodes{i};
    end
end