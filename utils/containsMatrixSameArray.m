function [bool] = containsMatrixSameArray(M,V,dir)
    %CONTAINSMATRIXSAMEARRAY checks if V is contained in M, where dir
    %specificies the direction: 0 by rows, 1 by columns
    %   
    if(isempty(M) && isempty(V))
        bool=true;
        return;
    end
    
    if((isempty(M) && not(isempty(V))) || (isempty(V) && not(isempty(M))))
        bool=false;
        return;
    end
    
    assert(length(V) == size(M,1) || length(V) == size(M,2));
    
    if dir==1 
        M=M.';
    end
    
    bool=false;
    for i=1:size(M,1)
        if(isequal(M(i,:),V))
            bool= true;
            return;
        end
    end
end

