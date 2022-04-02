function [deltaVar,classDeltaState] = getClassDelta(classID,classDeltaState,nMaxDelta,extraStringArg,nMaxExtra,extraIdx)
    %extraIdx can only be a number >=1
    assert(ischar(classID));
    
    function compMat = getMatrixForCompose(nMaxDelta,nMaxExtra)
        if exist('nMaxExtra','var') %multidimensional
            M = nMaxExtra;
            N = nMaxDelta;
            A = zeros(N,2*M);
            for i=0:N-1
                vec=1:M;
                A(i+1,1:2:end) = repmat(i,[1,M]);
                A(i+1,2:2:end) = vec;
            end
        else %monodimensional
             A = [0:nMaxDelta-1];
        end
        compMat = A;
    end
    
    if exist('extraStringArg','var') %multidimensional case
        assert(exist('nMaxExtra','var')==1);
        assert(exist('extraIdx','var')==1);
        assert(isnumeric(extraIdx));
        assert(not(isequal(extraIdx,0)));
        
        if isempty(classDeltaState)
            classDeltaState = sym(compose(['delta_%d',extraStringArg,'%d'],getMatrixForCompose(nMaxDelta,nMaxExtra)),'positive');
        end
        if size(classDeltaState,1)<str2double(classID)+1
            %expanding array on dim 1
            newRowsCount = max(str2double(classID)+1,2*size(classDeltaState,1));
            classDeltaState = sym(compose(['delta_%d',extraStringArg,'%d'],getMatrixForCompose(newRowsCount,size(classDeltaState,2))),'positive');
        end
        if size(classDeltaState,2)<extraIdx
            %expanding array on dim 2
            newColumnsCount = max(extraIdx,2*size(classDeltaState,2));
            classDeltaState = sym(compose(['delta_%d',extraStringArg,'%d'],getMatrixForCompose(size(classDeltaState,1),newColumnsCount)),'positive');
        end
        deltaVar = classDeltaState(str2double(classID)+1,extraIdx);
        
    else %one dimensional case
        if isempty(classDeltaState)
            classDeltaState = sym(compose('delta_%d',getMatrixForCompose(nMaxDelta)),'positive');
        end
        if length(classDeltaState)<str2double(classID)+1
            %expanding array
            newLen = max(str2double(classID)+1,2*length(classDeltaState));
            classDeltaState = sym(compose('delta_%d',getMatrixForCompose(newLen)),'positive');
        end
        deltaVar = classDeltaState(str2double(classID)+1);
    end
end
