% example of feature 3.1: Full MSCG computation

init;
clc;
clear all
initConds = [];
TPN.m0 = [1 0 1 0].';
TPN.PRE=  [1 0 0 0;
           0 1 0 0;
           0 0 1 0;
           0 0 0 1];
TPN.POST=  [0 1 0 0;
           1 0 0 0;
           0 0 0 1;
           0 0 1 0];
TPN.intervals={[0,2],... %t1 %cell array associating to each transition its [inf,sup]
               [1,2],... %t2
               [0,2],... %t3            
               [1,2]};   %t4 
TPN.transitionsLabels={'a',...
                       'b',...
                       'c',...
                       'd'};
tic;
[tree,rootNodeID,equivalenceMap,graph] = computeMSC(TPN,initConds,[],[],false,false);
toc;
printMSC( tree,rootNodeID, 'myMSCTree');

printMSC( graph,rootNodeID, 'myMSCGraph');