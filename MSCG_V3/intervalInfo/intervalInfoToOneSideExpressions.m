function [ineqs] = intervalInfoToOneSideExpressions(intervalInfo)
    % ineqs is an array of symbolic expressions involving the current
    % Delta (the symbolic var associated to a class), 
    % and other classes' Deltas; these expressions represent the bounds
    % constraint on the current Delta given by intervalInfo. 
    % At this aim, each inequality is always expressed in the form
    % A*Delta-b<=0; (one side)
    % each entry of ineqs is in AND with the other entries;
    % e.g. Delta1 \in [max{0,Delta0},min{1,4-Delta0}], thus intervalInfo
    % is such that intervalInfo.min=[0,Delta0] and intervalInfo.max=[1,4-Delta0],
    % thus ineqs = [-Delta1-0, -Delta1+Delta0 Delta1-1, Delta1-4+Delta0];
    
    inf = intervalInfo.inf;
    sup = intervalInfo.sup;
    Delta = intervalInfo.var;
    ineqs= [-Delta+inf,Delta-sup];
end

