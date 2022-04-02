function displaySeqInfo(timedTrSeqs,selSeq,startingL,endingL,firingsOnly,IOData,colored)
    if not(exist('colored','var')) || not(colored)
        colorString='text';
    else
        colorString='*blue';
    end
    seqs = getIOSeqs(IOData);
    seq=seqs{selSeq};
    stamps=getIODiffStamps(IOData);
    stamp=stamps{selSeq};
    trSeqs=getInterlacedSeqs(timedTrSeqs);
    trSeq=trSeqs{selSeq};
    mappings=getTrIdxToIOSeqIdxMapping(timedTrSeqs);
    mapping = mappings{selSeq};
    if not(exist('startingL','var'))
        startingL=1;
    else
        if startingL<=1
            startingL=1;
        end
    end
    if not(exist('endingL','var'))
        endingL=size(seq,2);
    else
        if endingL>size(seq,2)
            endingL=size(seq,2);
        end
    end
    for l=startingL:endingL
          [IEIDs,OEIDs] = getIOIDsFromCol(selSeq,l,true,IOData,0);
          if not(firingsOnly) || (firingsOnly && not(isempty(getFiresFromInterlacedSeqAt(trSeq,find(mapping==l)))))
              cprintf(colorString,['s=',num2str(selSeq),', l=',num2str(l), ', tr fired: ',numArrayToString(getFiresFromInterlacedSeqAt(trSeq,find(mapping==l))),', idxFire: ',num2str(find(mapping==l)),newline]);
              events = [IEIDs,OEIDs];
              if not(isempty(events)) cprintf(colorString,  [getSignalNameAndInfoFromID(events{1},IOData),newline]);  end
              for j=2:length(events)
                  if not(isempty(events{j})) cprintf(colorString,  [getSignalNameAndInfoFromID(events{j},IOData),newline]); end
              end
              if l>1    cprintf(colorString,  [strcat(9,['TIME: ',num2str(sum(stamp(1:l-1))/1000),' s']),newline]); end
          end
    end
end

