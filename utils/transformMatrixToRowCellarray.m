function [ C ] = transformMatrixToRowCellarray( M )

C=mat2cell(M,ones(1,size(M,1)),size(M,2));
    
end

