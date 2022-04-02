% example of the article
clc;
clear all
initConds = [];

TPN.m0 = [0 0 0 0 1 1].';
TPN.PRE= [[1;0;0;0;0;0] [0;1;0;0;0;0] [0;0;1;0;0;0] [0;0;0;1;0;0] [0;0;0;0;1;0] [0;0;0;0;0;1]];
TPN.POST=[[0;0;0;0;1;0] [0;0;0;0;0;1] [1;0;0;0;0;0] [0;1;0;0;0;0] [0;0;1;0;0;0] [0;0;0;1;0;0]];
TPN.intervals={[0,1],... %t1 %cell array associating to each transition its [inf,sup]
               [2,4],... %t2
               [0,1],... %t3
               [2,4],... %t4
               [0,9],... %t5 
               [0,9]};   %t6
TPN.transitionsLabels={'',...
                       '',...
                       '',...
                       '',...
		               '',...
                       ''};

                   
[tree,rootNodeID,equivalenceMap1,graph,rflag] = computeMSC(TPN,initConds,@(x,y)sequenceEnTrCallback(x,y,[5 3 1 6 4 2]));

printMSC( tree,rootNodeID, 'myMSCTree');

printMSC( graph,rootNodeID, 'myMSCGraph');
