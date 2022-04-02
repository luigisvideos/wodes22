function [bool, pastPathsHistory] = isMSCGTransitionFirable(originalGraph,t_i, Tk,Ck,pastPathsHistory)
    function str = getHistoryID()
       str=[getNodeID(Ck),'_',num2str(t_i)]; 
    end
    
    if isempty(pastPathsHistory)
       pastPathsHistory.exploredTransitionPaths = containers.Map( 'KeyType','char', 'ValueType','any'); %map associating to each Ck ID the visited transition paths
       pastPathsHistory.exploredIDPaths = containers.Map( 'KeyType','char', 'ValueType','any'); %map associating to each Ck ID the visited ID paths
    end
    graph= originalGraph;
%     [graph] = getCopyOfTreeWithFusedNodes(originalGraph,equivalenceMap,dupIDs);


    % now find deltas to consider
    deltas=sym([]);
    infos = getNodeInfos(Ck); intervals=getInfoFromInfos(getConstraintsInfoID(),infos);
    % we only consider deltas appearing in the lower bound of theta_i and
    % in the upper bound of each theta associated to a transition in Tk
    thetaTransitionsIndices = keys(intervals);
    thetaIntervals = values(intervals);
    for i=1:length(thetaTransitionsIndices)
        deltasFromSup = symvar(thetaIntervals{i}.sup);
        if not(isempty(deltasFromSup))
            deltas = union(deltas,deltasFromSup);
        end
        if isequal(thetaTransitionsIndices{i},t_i)
           deltasFromInf = symvar(thetaIntervals{i}.inf);
           if not(isempty(deltasFromInf))
                deltas = union(deltas,deltasFromInf);
           end
        end
    end
    
    % getting inequalities for t_i
    infos = getNodeInfos(Ck);
    intervals = getInfoFromInfos(getConstraintsInfoID(),infos);

    t_iIntervals = intervals(t_i);
    
    %inserting inequalities for transition tk
    ineqs=[];
    for i=1:2
        if i == 1
            maxElem = 0;
        else
            maxElem = t_iIntervals.inf;
        end
        for k=1:length(Tk)
            t_kIntervals = intervals(Tk(k));
            ineqs=[ineqs,maxElem-t_kIntervals.sup];
        end
    end
    
    %newly added for e-mscg synchronization
    if isempty(deltas)
       [bool,x,xvars] = hasAlgSysSolution(ineqs,[]);
       return;
    end
    
    if isKey(pastPathsHistory.exploredTransitionPaths,getHistoryID())
        exploredTransitionPathsCk = pastPathsHistory.exploredTransitionPaths(getHistoryID());
        exploredIDPathsCk = pastPathsHistory.exploredIDPaths(getHistoryID());
    else
        exploredTransitionPathsCk = [];
        exploredIDPathsCk = [];
    end
    
    [IDpaths,transitionPaths,ASO] = getAllPathsFromNode(getNodeID(Ck),graph,true,true,...
        initExtraVarsPathDeltasEncountered(deltas,ineqs,exploredIDPathsCk,exploredTransitionPathsCk),...
        @canInsertNodeToPathDeltasEncountered,...
        @newNodeAddedToPathActionDeltasEncountered,...
        @canDiscoverChildrenDeltasEncountered,...
        @newPathAddedActionDeltasEncountered,...
        @canStoreBranchToPathsDeltasEncountered,...
        @newBranchActionDeltasEncountered,...
        @canExitDeltasEncountered);
    
    % update already explored paths
    if not(isempty(ASO.badTransitionPaths))
       assert(length(ASO.badTransitionPaths) == length(ASO.badIDPaths));
       if isKey(pastPathsHistory.exploredTransitionPaths,getHistoryID())
           pastPathsHistory.exploredTransitionPaths(getHistoryID()) = ...
               [pastPathsHistory.exploredTransitionPaths(getHistoryID()),...
               ASO.badTransitionPaths];
           
           pastPathsHistory.exploredIDPaths(getHistoryID()) = ...
               [pastPathsHistory.exploredIDPaths(getHistoryID()),...
               ASO.badIDPaths];
       else
           pastPathsHistory.exploredTransitionPaths(getHistoryID()) = ASO.badTransitionPaths;
           pastPathsHistory.exploredIDPaths(getHistoryID()) = ASO.badIDPaths;
       end
    end
    
    bool = ASO.exit;
end

