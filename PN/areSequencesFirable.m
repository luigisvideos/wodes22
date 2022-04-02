function [bool,notFirableIdxs] = areSequencesFirable(net, sequences )
    Ms=net.Ms;
    PRE=net.PRE;
    POST=net.POST;
    silentTransitions=net.silentTransitions;
    
    nPObR = length(Ms);
    depth=ceil(getMaximumSequencesLength(sequences)*(1+0.1)) ;
    [graphNet,rootnodeNet] = createTruncatedReachabilityGraph( net,depth);
%     [graphNet,rootnodeNet] = createCoverabilityGraph( Ms,PRE,POST,nPObR,1:size(PRE,2) );
    notFirableIdxs=[];
    bool=true;
    for s=1:length(sequences)
        seq=sequences{s};
        [ nL,cyclicWords ]= getTransitionWordsFromNode(length(seq),graphNet,rootnodeNet,1,silentTransitions);
        bool = false;
        for i=1:length(nL)
           if (isequal(nL{i}(1:length(seq)), seq))
              bool=true;
              break;               
           end
        end
        if(not(bool))
            notFirableIdxs=union(notFirableIdxs,s);
        end
    end
end

