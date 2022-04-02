function ASO = sequenceEnTrCallback(algoInfo,enTrCallbackASO,sequence)
    ASO.stop = false;
    
    if isempty(enTrCallbackASO)
        ASO.currentSequenceIndex = 1;
        ASO.firingOccurred = false;
        ASO.lastCk = getNodeID(algoInfo.Ck);
        enTrCallbackASO = ASO;
    end
    
    if not(enTrCallbackASO.firingOccurred)
        assert(isequal(enTrCallbackASO.lastCk,getNodeID(algoInfo.Ck)));
    end
    
    if isequal( algoInfo.t_i,sequence(enTrCallbackASO.currentSequenceIndex))
        ASO.fire = true;
        ASO.firingOccurred = true;
        ASO.currentSequenceIndex = enTrCallbackASO.currentSequenceIndex+1;
        %disp(['done ',num2str((ASO.currentSequenceIndex-1)*100/length(sequence)),'%']);
    else
        ASO.fire = false;
        ASO.firingOccurred=false;
        ASO.currentSequenceIndex = enTrCallbackASO.currentSequenceIndex;
    end
    
    ASO.lastCk = getNodeID(algoInfo.Ck);
    
    if isequal(ASO.currentSequenceIndex-1,length(sequence))
        ASO.stop = true;
    end
end