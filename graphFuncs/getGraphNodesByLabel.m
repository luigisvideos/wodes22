function nodes = getGraphNodesByLabel(label,graph)
    graphNodes=getGraphNodes(graph);
    nodes=[];
    for i=1:length(graphNodes)
        if isequal(getLabel(graphNodes{i}),label)
            nodes=[nodes,graphNodes(i)];
        end
    end
end