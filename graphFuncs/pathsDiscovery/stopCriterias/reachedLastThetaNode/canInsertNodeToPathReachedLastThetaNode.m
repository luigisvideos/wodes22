function [bool,ASO] = canInsertNodeToPathReachedLastThetaNode(ASO)
    
    if ASO.stop 
        bool=false;
        return;
    end

    bool = true;

    % case where this class is a leaf
    if isempty(ASO.thisNodeTransition)
        bool = false;
    end
    
    if bool

        %check if transition interval is correct
        infos = getInfosOfLinkingTransition(ASO.graph(ASO.currentIDPath{end}),ASO.thisNodeTransition);
        interval = getInfoFromInfos(getIntervalInfoID(),infos);
        bool = isequal(interval.inf,interval.sup);

        if bool
           % l'istanza è stata rimossa

            past = getTransitionInstancesInClass(ASO.graph(ASO.currentIDPath{end}),ASO.transition);
            current = getTransitionInstancesInClass(ASO.graph(ASO.thisNodeID),ASO.transition);

            if current-past<0
                consumedInstances = past-current;
            else
                consumedInstances = 0;
            end
            ASO.consumedInstances= ASO.consumedInstances + consumedInstances;

            if ASO.consumedInstances==ASO.initInstances && not(isequal(ASO.thisNodeTransition,ASO.transition))
               bool = false;
           end
        end
    end
    
    ASO.error=not(bool);
end