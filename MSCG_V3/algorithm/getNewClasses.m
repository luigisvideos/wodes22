function [ids] = getNewClasses(graph)
    nodes=getGraphNodes(graph);
    ids=[];
    for i=1:length(nodes)
        if isClassNew(nodes{i})
            ids=[ids,{getNodeID(nodes{i})}];
        end
    end
end

