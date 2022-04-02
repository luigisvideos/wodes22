function [ vec ] = filterOutFromVector( vec,values )    
    ind=[];
    for i=1:length(values)
       ind=union(ind,find(vec==values(i)));
    end
    vec(ind)=[];
end

