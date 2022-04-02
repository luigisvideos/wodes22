% example of the following features:
%   - 3.1: Full MSCG computation, with specification of a
%     set of infinite-server transitions. Be patient, it requires some time to compute...
%   - 3.4 Mathematical representation: showing how to access all instances of
%     infinite-server transitions
%   - 3.5 Partial MSCG computation, specifing a set of transitions that,
%     once fired during the constructiong of the MSCG, stop the exploration
%     along their path (back-tracking of the algorithm)

tic;
init;
clc;
clear all
initConds = [];
TPN.m0 = [1 2 0].';
TPN.PRE=  [1 1 0 1 1;
           0 2 1 1 1
           0 0 0 2 2];
TPN.POST=  [1 0 0 0 0;
           1 2 0 0 1
           1 0 0 0 0];
TPN.intervals={[2,3],... %t1 %cell array associating to each transition its [inf,sup]
               [1,2],... 
               [1,3],...
               [0.5,0.5],...
               [0.5,0.5]};   

%% - 3.1: Full MSCG computation, with specification of t3 as transition 
% with infinite server semantic; other transitions are single server

infiniteServerLogicalArray = [0 0 1 0 0]; %t3 only
[tree,rootNodeID,equivalenceMap,graph] = computeMSC(TPN,initConds,[],[],[],infiniteServerLogicalArray);
toc;
printMSC( tree,rootNodeID, 'myMSCTree');

printMSC( graph,rootNodeID, 'myMSCGraph');

%% - 3.4 Mathematical representation: accessing multiple instances of a transition

% get indices of multi-enabled transitions in C10
array = getInfoFromInfos(getMultiEnablingConstraintsInfoID(),getNodeInfos(graph('10')));
indices = find(cellfun(@(x) isempty(x),array)==0);
% variable indices contains only 3, thus t3 only is multi enabled in C10.

% get the number n_e of current instances of t3 in C10:
n_e = length(array{indices}) + 1;
% 'array' contains the n_e-1 most recent instances of t3
% here n_e=3

% get bounds of the oldest instance of t3 in C10 (regular instance)
tr = 3;
transitionsMap = getInfoFromInfos(getConstraintsInfoID(),getNodeInfos(graph('10')));
inf = transitionsMap(tr).inf;
sup = transitionsMap(tr).sup;

% remaining newest instances of t3 in C10 (2 instances) are contained in
% structs, which is an array of length 2; each element is a struct
% representing an instance
structs = array{indices};
% the field 'age' in an instance represents the time allocation of the
% instance: the greater the 'age' value, the youngest the instance
% for example structs(1).age yields 1, while structs(2).age yields 2, thus
% instance represented in structs(2) is the youngest.
% here their bounds:
inf_middle_age = structs(1).inf;
sup_middle_age = structs(1).sup;
inf_younger_age = structs(2).inf;
sup_younger_age = structs(2).sup;

%% - 3.5 Partial MSCG computation: stop the computation along a path as transition t1 is encountered
stopConditionTransitionSet = [1];
[tree2,rootNodeID2,equivalenceMap,graph2] = computeMSC(TPN,initConds,[],[],stopConditionTransitionSet,infiniteServerLogicalArray);

printMSC( graph2,rootNodeID2, 'myMSCGraph2');
