function [ crossed ] = getUnDirectlyDistinguishableNodes( graph,crossed )

nodes = values(graph);
nNodes = length(nodes);
%searching for further distinguishable states:step 6
map = containers.Map( 'KeyType','char', 'ValueType','int32'); %initializing map
for i=1:nNodes
   map(getNodeID(nodes{i})) = i;
end
stop= false;
while(not(stop))
    stop=true;
    for i=1:nNodes
        for j=i+1:nNodes
            if(not(crossed(i,j)))
                outTrI = getOutTransitions(nodes{i});
                outTrJ = getOutTransitions(nodes{j});
                for t=1:length(outTrI)
                   if(not(isempty(intersect(outTrI(t),outTrJ))))
                       %a common transition is considered
                       reachedINode = getReachedNodeByTransition( graph, getNodeID(nodes{i}), outTrI(t) );
                       reachedJNode = getReachedNodeByTransition( graph, getNodeID(nodes{j}), outTrI(t) );
                       intIndI = map(getNodeID(reachedINode));
                       intIndJ = map(getNodeID(reachedJNode));
                       intIndILT = min(intIndI,intIndJ);
                       intIndJGT = max(intIndI,intIndJ);
                       if(crossed(intIndILT,intIndJGT))
                          crossed(i,j)=true; 
                          stop = false;
                       end
                   end
                end
            end
        end
    end
end
end

