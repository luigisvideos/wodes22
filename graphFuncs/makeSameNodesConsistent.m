function [child, father] = makeSameNodesConsistent(child,father)
    assert(isequal(child.winID,father.winID));
    
    child.inTransitions = union(child.inTransitions,father.inTransitions);
    father.inTransitions = child.inTransitions;
    child.outTransitions = union(child.outTransitions, father.outTransitions);
    father.outTransitions = child.outTransitions;

    chInNodes = child.in;
    vals = values(chInNodes);
    ks = keys(chInNodes);
    for i=1:length(chInNodes)
        if(isKey(father.in,ks{i}))
            father.in(ks{i}) = union(child.in(ks{i}),father.in(ks{i}));
        else
            father.in(ks{i}) = child.in(ks{i});
        end
    end
    child.in = father.in;
    
    chOutNodes = child.out;
    vals = values(chOutNodes);
    ks = keys(chOutNodes);
    for i=1:length(chOutNodes)
        if(isKey(father.out,ks{i}))
            father.out(ks{i}) = union(child.out(ks{i}),father.out(ks{i}));
        else
            father.out(ks{i}) = child.out(ks{i});
        end
    end
    child.out = father.out;
end

