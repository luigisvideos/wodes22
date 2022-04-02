function [ node ] = setNodeType( node,type)
    assert(ischar(type),'Node type must be a char');
    assert(isequal(type,'E') || isequal(type,'R') || isequal(type,'L'),'Type must either be R, L or E');
    % getting the ID and the label
    str = node.winID;
    node.winID = [str(1:strfind(str,'_')),type];
end
