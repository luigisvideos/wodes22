function [ t ] = getLinkingTransitions( father,childID )

t=[];
if(isKey(father.out,childID))
    t = father.out(childID);
end


end

