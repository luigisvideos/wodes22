function [tree,rootNodeID,equivalenceMap,initConds,graph] = expandFromClass(TPN,tree,rootNodeID,equivalenceMap,enTrCallback,transitionsSetStop,computeExplicitTree,initConds,disp)
    %multiEn must be a field of TPN!!
    if not(exist('disp','var'))
        disp =false;
    end
    if not(exist('enTrCallback','var'))
        enTrCallback = [];
    end
    if not(exist('transitionsSetStop','var'))
        transitionsSetStop = [];
    end
    if not(exist('computeExplicitTree','var'))
        computeExplicitTree = false;
    end
    
    initConds.initRoot = [];
    initConds.initTree = tree;
    initConds.initRootID = rootNodeID;
    initConds.initEquivalenceMap=equivalenceMap;
    initConds.initGraph = tree;
    
    if not(isfield(TPN,'multiEnabling'))
        multiEn = zeros(1,size(TPN.PRE,2));
    else
        multiEn = TPN.multiEnabling;
        assert(length(multiEn)==size(TPN.PRE,2));
    end
    
    [tree,rootNodeID,equivalenceMap,graph,~,initConds] = computeMSC(TPN,initConds,enTrCallback,transitionsSetStop,computeExplicitTree,disp,true,multiEn);

end