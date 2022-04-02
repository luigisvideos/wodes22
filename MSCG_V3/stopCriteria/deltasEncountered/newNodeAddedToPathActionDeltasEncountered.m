function [ASO] = newNodeAddedToPathActionDeltasEncountered(ASO)
    % every time a node is add to the path, a new edge is encountered. 
    %
    % these tasks must be accomplished:
    % 1) if the delta associated to the current edge is one of the
    %    deltas in ASO.deltas (either directly or, if exists, through the isomorphism on the same
    %    edge), such delta must be removed from the set of remaining deltas (initially set to ASO.deltas); 
    % 2) in case of isomorphism on the edge, a symbolic substitution must be operated on
    %    the past encountered inequalities;
    % 3) the inequality associated to the edge must be added to the set of encountered inequalities; 
    % 4) if new deltas are contained in the bounds of this inequality, they must be added to
    %    the set of remaining deltas to be explored;
    
    infos = getInfosOfLinkingTransition(ASO.graph(ASO.thisNodeID),ASO.thisNodeTransition);
    intervalInfo = getInfoFromInfos(getIntervalInfoID(),infos);
    isomoInfos  = getInfoFromInfos(getIsomorphismInfoID(),infos);
    
    % task 1
    removeSymVars(ASO.remainingDeltas,intervalInfo.var);% subtract current encountered delta
    % subtract also deltas equivalent to this
    for i=1:size(isomoInfos,1)
       if not(isempty(find(isomoInfos(i,2)== intervalInfo.var, 1)))
            removeSymVars(ASO.remainingDeltas,isomoInfos(i,1));
       end
    end
    
    % task 2
    if not(isempty(isomoInfos))
        for i=1:size(isomoInfos,1)
           isomoInfo = isomoInfos(i,:);
           ASO.ineqs=subs(ASO.ineqs,isomoInfo(1),isomoInfo(2)); 
        end
    end

    % task 3
    ASO.ineqs = [ASO.ineqs, intervalInfoToOneSideExpressions(intervalInfo) ];
    
    % task 4
    supVars = symvar(intervalInfo.sup); infVars=symvar(intervalInfo.inf);
    if isempty(supVars) supVars=[]; end 
    if isempty(infVars) infVars=[]; end
    intervalVars = union(supVars,infVars);
    addSymVars(ASO.remainingDeltas,intervalVars);

    ASO.remainingDeltasBySteps=[ASO.remainingDeltasBySteps,{copy(ASO.remainingDeltas)}]; 
    ASO.ineqsBySteps=[ASO.ineqsBySteps,{ASO.ineqs}]; 
end