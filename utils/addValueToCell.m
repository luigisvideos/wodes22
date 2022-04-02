function [ A ] = addValueToCell( A,i,j,value )

if (sum(lt(size(A),[i j]))>0) %if i and (or) j are new indices
    A{i,j} = value;
else
    A{i,j} = union(A{i,j},value);
end

end

