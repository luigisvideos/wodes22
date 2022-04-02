function [ASO] = newBranchActionDeltasEncountered(ASO,lastVisitedID,lastVisitedTransition,lastBranchIndex)

    ASO.remainingDeltas=copy(ASO.remainingDeltasBySteps{lastBranchIndex});
    ASO.ineqs=ASO.ineqsBySteps{lastBranchIndex};
    ASO.remainingDeltasBySteps=ASO.remainingDeltasBySteps(1:lastBranchIndex);
    ASO.ineqsBySteps=ASO.ineqsBySteps(1:lastBranchIndex);
    
end

