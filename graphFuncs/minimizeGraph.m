function [ newGraph ] = minimizeGraph( graph )
    display=false;
    if(length(graph)>700)
       display=true; 
    end
    if(display)
        disp('Getting directly distinguishable nodes');
    end
    [ crossed ] = getDirectlyDistinguishableNodes( graph,display );
    if(display)
        disp('Getting undirectly distinguishable nodes');
    end
    [ crossed ] = getUnDirectlyDistinguishableNodes( graph,crossed );

    %deleting undistinguishable nodes
    disp('Deleting distinguishable nodes by fusion');
    newGraph = copy(graph);
    nodes = values(newGraph);
    nNodes = length(nodes);
    n = 0; tot = nNodes*(nNodes-1)/2;
    lastPerc = 0;
    toDelete = [];
    for i=1:nNodes
        if(isempty(find(toDelete==i,1)))
            for j=i+1:nNodes
                if(isempty(find(toDelete==j,1)))
                    if(not(crossed(i,j))) % they are indistinguishable
                        newGraph=fuseNodes(newGraph,nodes{i},nodes{j});
                        toDelete=union(toDelete,j);
                    end
                end
                n=n+1;
                currentPerc = (n*100)/tot;
                if(display && getTrueEach10( currentPerc,lastPerc ))
                   disp(['Done: ',num2str(currentPerc),'%']);
                end
                lastPerc = currentPerc;
            end
        end
    end
    
    for i=1:length(toDelete)
        remove(newGraph,getNodeID(nodes{toDelete(i)}));
    end
    
end

