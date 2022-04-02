function [tree] = modifyArcTimeAndSuccessorInequalities(tree,classID,arcTransitionID,constantTime)
    % ATTENZIONE: il tree deve essere stato creato con
    % computeExplicitTree=true. in questo modo non c'è ambiguità su classID
    % questa funzione opera distruttivamente, effettuare una copia del tree
    % nel chiamante se si vuole conservare la copia del tree: copy(tree)
       
    function thisIntervalInfo = updateInterval(thisIntervalInfo)
        thisIntervalInfo.inf = max(double(subs(thisIntervalInfo.inf,constantTime)));
        thisIntervalInfo.sup = double(subs(thisIntervalInfo.sup,constantTime));
        thisIntervalInfo.orderedSubtractors = [];
    end
    
    % aggiornamento arco
    infos = getInfosOfLinkingTransition(tree(classID),arcTransitionID);
    intervalInfo = getInfoFromInfos(getIntervalInfoID(),infos);
    intervalInfo.inf = constantTime;
    intervalInfo.sup = constantTime;
    intervalInfo.orderedSubtractors = [];
    tree(classID) = setInfosOfLinkingTransition(tree(classID),arcTransitionID,setInfoToInfos(intervalInfo,getIntervalInfoID(),infos));
    
    % aggiornamento nodo successivo
    succ = getSuccessorNode(tree,tree(classID),arcTransitionID);
    succConstraintsInfos = getInfoFromInfos(getConstraintsInfoID(),getNodeInfos(succ));
    
    intervalInfos = values(succConstraintsInfos);
    % ATTENZIONE: è presupposto che negli intervalli del succ compaia una
    % sola delta, motivo per cui nella subs non è specificato quale delta
    % in particolare è sostituita
    for i=1:length(intervalInfos)
        thisIntervalInfo = intervalInfos{i};
        intervalInfos{i} = updateInterval(thisIntervalInfo);
    end
    newInfos = setInfoToInfos(containers.Map(keys(succConstraintsInfos), intervalInfos),getConstraintsInfoID(),getNodeInfos(succ));
    tree(getNodeID(succ)) = setNodeInfos(tree(getNodeID(succ)),newInfos);
    
    % update anche delle disequazioni extra
    nodeInfos = getNodeInfos(tree(getNodeID(succ)));
    multiInfo = getInfoFromInfos(getMultiEnablingConstraintsInfoID(),nodeInfos);
    for t=1:length(multiInfo)
       if not(isempty(multiInfo{t}))
           array= multiInfo{t};
           for i=1:length(array)
               thisIntervalInfo = array(i);
               array(i) = updateInterval(thisIntervalInfo);
           end
           multiInfo{t} = array;
       end
    end
    newInfos = setInfoToInfos(multiInfo,getMultiEnablingConstraintsInfoID(),nodeInfos);
    tree(getNodeID(succ)) = setNodeInfos(tree(getNodeID(succ)),newInfos);

    
    % assicurarsi che il nodo successivo non abbia successori
    assert(isempty(getSuccessorNodes(tree,getNodeID(succ))));
end

