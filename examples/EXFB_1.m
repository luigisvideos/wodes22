% example of feature 3.1: Full MSCG computation
tic
init;
clc;
clear all
initConds = [];
TPN.m0 = [1 1 0].';
TPN.PRE=  [1 0 0;
           0 1 0;
           0 0 1];
TPN.POST=  [0 0 1;
           0 0 0;
           1 0 0];
TPN.intervals={[1,2],... %t1 %cell array associating to each transition its [inf,sup]
               [1,10],... %t2
               [1,2]};   %t3 
TPN.transitionsLabels={'a',...
                       'b',...
                       'c'};

[tree,rootNodeID,equivalenceMap,graph] = computeMSC(TPN,initConds);
toc
printMSC( tree,rootNodeID, 'myMSCTree');

printMSC( graph,rootNodeID, 'myMSCGraph');