% example of the article (Fig 6.) exhibiting features:
% - 3.3 Graphical representation and 3.5 Partial MSCG computation, via specification of a set of ignored
%   transitions (i.e. their firing is not contemplated in the graph building)
% - 3.2 Interactive computation guided by the user
% - 3.4 Mathematical representation

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
%% - 3.5 Partial MSCG computation, 

% give an initial state
currClassNum = 0; %set the numerical id of the given class: 0, since we start from a blank graph
M0=[0 0 1 0 0 1].'; %set the initial marking of the given class
% set transitions constraints of the class
constraintsInfos = createEmptyConstraintsInfo();
% set transition inequalities for t3: 
inf = 0; sup = 1;
tr = 3;
[trsiTheta] = getTransitionTheta(tr,[],size(TPN.PRE,2));
constraintsInfos(tr) = createIntervalInfo(inf,sup,trsiTheta);
% set transition inequalities for t6:
inf = 0; sup = 4;
tr = 6;
[trsiTheta] = getTransitionTheta(tr,[],size(TPN.PRE,2));
constraintsInfos(tr) = createIntervalInfo(inf,sup,trsiTheta);
%create the class 
node = createNodeByID(num2str(currClassNum),num2str(currClassNum),createInfos({...
    getMarkingInfoID(),createMarkingInfo(M0),...
    getTagInfoID(),createTagInfo(newTag()),...
    getConstraintsInfoID(),createConstraintsInfo(constraintsInfos),...
            getMultiEnablingConstraintsInfoID(), createEmptyMultiEnablingConstraintsInfo(size(TPN.PRE,2))}));
% set as initial class of the graph
initConds.initRoot = node;
% set t5 as ignored transition
ignoredTransitionsSet = [5];
                   
[tree,rootNodeID,equivalenceMap,graph] = computeMSC(TPN,initConds,[],ignoredTransitionsSet);

%% - 3.3 Graphical representation
printMSC( tree,rootNodeID, 'myMSCTree');

printMSC( graph,rootNodeID, 'myMSCGraph');

%% - 3.2 Interactive computation guided by the user

[tree2,rootNodeID2,equivalenceMap1,graph2,rflag] = computeMSC(TPN,initConds,@(x,y)consolEnTrCallback(x,y));

printMSC( tree2,rootNodeID2, 'myMSCTree2');

printMSC( graph2,rootNodeID2, 'myMSCGraph2');


%% - 3.4 Mathematical representation

printArc(tree('0'),3)  % print infos of arc exiting class C0 in the tree and associated to the firing of t3

printClass(tree('2')); % print infos of class C2 in the tree

printClassAndNeighborhood(graph('1'),graph); % print infos of class C1 in the graph, including predecessor classes

% get marking of class C1
marking = getInfoFromInfos(getMarkingInfoID(),getNodeInfos(graph('1')));
% all infos associated to a class are implemented in the folder \MSCG_V3\classLabelInfos

% get transitions enabled in class C1 of the graph (cell array is yielded)
enabledTransitions = keys(getInfoFromInfos(getConstraintsInfoID(),getNodeInfos(graph('1'))));

% get bounds of transition t6 in class C1 of the graph
tr = 6;
transitionsMap = getInfoFromInfos(getConstraintsInfoID(),getNodeInfos(graph('1')));
inf = transitionsMap(tr).inf;
sup = transitionsMap(tr).sup;

% get bounds of arc associated to t4 exiting from class C8 in the graph
struct = getInfoFromInfos(getIntervalInfoID(),getInfosOfLinkingTransition(graph('8'),4));
inf_arc = struct.inf; %it is an array containing the components of the max function
sup_arc = struct.sup;
% all infos associated to an arc are implemented in the folder \MSCG_V3\linkingTransitionInfos

% get successors of a class C1 in the graph
successors = getSuccessorNodes(graph,'1');
% get ID of the first successor in the list
firstSuccessorID = getNodeID(successors(1));

% get transitions fired from class C1 in the graph
firedTransitions = getOutTransitions(graph('1'));
% firedTransitions(2) contains t6 (represented as 6)

% reach successor class from current class (C1) by following the arc associated to
% fired transition t6
successorNode = getSuccessorNode(graph,graph('1'),firedTransitions(2));
% successorNode is C4