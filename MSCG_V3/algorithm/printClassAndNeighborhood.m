function printClassAndNeighborhood(class,graph)

printClass(class);

inNodes=getInNodesMap(class);
inNodesIDs=keys(inNodes);
inNodesTransitions=values(inNodes);
if not(isempty(inNodes))
   disp(['PREDECESSORS:']); disp('');
else
    disp('NO PREDECESSOR');
end
for i=1:length(inNodes)
    disp('PREDECESSOR''S ARC: ');
    printArc(graph(inNodesIDs{i}),inNodesTransitions{i})
    disp('PREDECESSOR: ');
    printClass(graph(inNodesIDs{i}));
    disp(' ');
end



end