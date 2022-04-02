function [info] = createIsomorphismInfo(deltasEq)
    % takes an array of N equalities and trasforms it in a matrix N x 2 
    % containing for each row the couple of deltas that are isomorphic
    info=[];
    for i=1:length(deltasEq)
       [cs,vars]=coeffs(deltasEq(i));
       assert(length(vars)==2);
       
       % insert data in matrix in order: the first element of a row is
       % the symbol that will be substituted (i.e. Delta^(e)); 
       % the second is the symbol which will be used as substitute (i.e.
       % Delta^(q))
       
       secondElemIdx = find(cs==-1);
       firstElemIdx = find(cs==1);
       
       info=[info;vars(firstElemIdx) , vars(secondElemIdx) ];
    end
    
    info = unique(info,'rows');
end

