function ASO = initExtraVarsPathDeltasEncountered(deltas,trIneqs,exploredIDPaths,exploredTransitionPaths)
    
    if not(exist('exploredIDPaths','var'))
        exploredIDPaths=[];
    end
    if not(exist('exploredTransitionPaths','var'))
        exploredTransitionPaths = [];
    end
       
    
    ASO.remainingDeltas=initializeSymVars(deltas);
    ASO.remainingDeltasBySteps=[{ASO.remainingDeltas}];
    ASO.exploredIDPaths=exploredIDPaths;
    ASO.badIDPaths = [];
    ASO.badTransitionPaths = [];
    ASO.exploredTransitionPaths=exploredTransitionPaths;
    ASO.ineqs=trIneqs;
    ASO.ineqsBySteps=[{ASO.ineqs}];
    ASO.exit = false;
end