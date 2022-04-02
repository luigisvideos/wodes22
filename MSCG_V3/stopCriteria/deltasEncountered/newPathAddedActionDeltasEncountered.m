function [ASO,IDpaths,transitionPaths] = newPathAddedActionDeltasEncountered(ASO,IDpaths,transitionPaths)
    solutionFound = false;
    ineqs=[];
    
    % solve the linear problem
    if isempty(ASO.remainingDeltas)
        currentIDPath=ASO.currentIDPath;
        currentTransitionPath=ASO.currentTransitionPath; 
        
        assert(length(currentTransitionPath) == length(currentIDPath)-1);
        
        solve=true;
        
        for j=1:length(ASO.exploredTransitionPaths)
            exploredTransitionPath = ASO.exploredTransitionPaths{j};
            exploredIDPath = ASO.exploredIDPaths{j};
            if isequal(currentTransitionPath,exploredTransitionPath) && isequal(currentIDPath,exploredIDPath)
                solve=false;
                bool = false;
                break;
            end
        end
                   
        if solve
            [bool,x,xvars] = hasAlgSysSolution(ASO.ineqs,[]);
             if bool
                 solutionFound=true;
             else
                 ASO.badIDPaths{end+1} = currentIDPath;
                 ASO.badTransitionPaths{end+1} = currentTransitionPath;
             end
        end
    end
        
    if solutionFound 
        ASO.exit = true;
    end
end

