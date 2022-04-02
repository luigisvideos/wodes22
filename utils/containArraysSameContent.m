function [ res ] = containArraysSameContent( a1,a2 )
if(not(isequal(length(a1),length(a2))))
   res = false;
   return;
end

res =  isSmallerArrayContainedInBigger( a1,a2 );

end

