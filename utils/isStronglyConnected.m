function [ res ] = isStronglyConnected( PRE,POST )
    Ct = getDigraphMatrix(PRE,POST);
    G = digraph(Ct);
    bins = conncomp(G);
    res=length(bins)==sum(size(PRE)) && sum(bins-ones(size(bins)))==0;
end

