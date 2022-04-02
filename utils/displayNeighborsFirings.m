function displayNeighborsFirings(timedTrSeqs,t,obsIPN,firingsOnly,IOData,delta)
frag=getFragmentByElem('src',t,obsIPN);
s_l_couples = getSourceTrFiresIOSeqs(frag);
cprintf('*blue',[newline,'============  SHOWING NEIGHBORS of t',num2str(t),' =============']);
    for o=1:size(s_l_couples,1)
        s=s_l_couples{o,1};
        l=s_l_couples{o,2};
        disp([newline,'s:',num2str(s),', l:',num2str(l)]);
        displaySeqInfo(timedTrSeqs,s,l-delta,l-1,firingsOnly,IOData);
        displaySeqInfo(timedTrSeqs,s,l,l,firingsOnly,IOData,true);
        displaySeqInfo(timedTrSeqs,s,l+1,l+delta,firingsOnly,IOData);
        disp('======================================');
    end
end