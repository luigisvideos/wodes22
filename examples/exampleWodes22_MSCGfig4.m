% example of the article (Fig 4.) exhibiting feature 3.1: Full MSCG computation

clc;
clear all
initConds = [];

TPN.m0 = [1 0 0 1].';
TPN.PRE= [[1;0;0;0] [1;0;0;1] [0;0;1;0] [0;1;0;0]  [0;0;0;1]];
TPN.POST=[[0;1;0;0] [0;0;1;1] [0;1;0;0] [0;0;0;0]  [0;0;0;0]];
TPN.intervals={[0,1],... %t1 %cell array associating to each transition its [inf,sup]
               [0,1],... %t2
               [0,2],... %t3
               [0,1],... %t4
               [3,4]};   %t5
TPN.transitionsLabels={'a',...
                       'eps',...
                       'a',...
                       'b',...
                       'b'};
                   
[tree,rootNodeID,equivalenceMap,graph] = computeMSC(TPN,initConds);

printMSC( tree,rootNodeID, 'myMSCTree');

printMSC( graph,rootNodeID, 'myMSCGraph');