function [ crossed ] = getDirectlyDistinguishableNodes( graph,display )
%crossed(i,j) means that nodes{i} and nodes{j} are distinguishable
nodes = values(graph);
nNodes = length(nodes);
crossed = zeros(nNodes,nNodes);
%searching for directly distinguishable states: step 4
n = 0; tot = nNodes*(nNodes-1)/2;
lastPerc = 0;
for i=1:nNodes
    for j=i+1:nNodes
        crossed(i,j)=true;
        tIComplete = getOutTransitions(nodes{i});
        tJComplete = getOutTransitions(nodes{j});
        if(length(tIComplete) == length(tJComplete) &&...
                length(tIComplete) == length(union(tIComplete,tJComplete)) &&...
                isequal(getLabel(nodes{i}),getLabel(nodes{j}))) %same output transitions && same label
            crossed(i,j)=false; % they are indistinguishable
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

