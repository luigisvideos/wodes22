function [ tr ] = getLastTransitionFromWinID( id )
tr = id(find(id=='t',1,'last')+1);

end

