function [trDegree] = computeTransitionDegree(marking,PRE,POST,tr)
trDegree = 0;
nMq = marking;
 while(isTransitionStateEnabled(nMq,PRE,tr))
    nMq = updateNet(nMq,PRE,POST,tr);
    trDegree = trDegree+1;
 end
end

