function [ node ] = createNode( win,sequences,ObsMarks,type)
assert(ischar(type),'Node type must be a char');
% getting the ID and the label
[ markings, transitions ] = getMarkingsAndTransitionsFromWindow( win, sequences, ObsMarks );
assert(all(all(markings <= ones(size(markings)))),'At least one observable place reached a non-safe marking.');
label = getMobID( markings(:,size(markings,2)));
ID = [getWinID( win,sequences, ObsMarks ),'_'];
% creating the node
node = createNodeByID( ID, label);
node=setNodeType( node,type);
node.win=win;
end

