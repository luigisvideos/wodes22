function [ graph ] = addNodesToGraph( nodes, graph )
    for i=1:length(nodes)
       assert(not(isKey(graph,getNodeID(nodes(i)))));
       graph(getNodeID(nodes(i)))=nodes(i); 
    end
    
end

