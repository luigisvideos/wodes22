function [tree,rootNodeID,equivalenceMap,graph,rflag,initConds,inverseEquivalenceMap] = computeMSC(TPN,initConds,enTrCallback,ignoredTransitionsSet, transitionsSetStop, multiEnabling, dispFlag)
    % initConds is a mandatory argument specifying the initial conditions
    % of the algorithm. it can be an empty element ( [] ) or a struct whose
    % fields are:
    % - initTree
    % - initRoot
    % - initRootID
    % - initEquivalenceMap
    % - initGraph
    % initRoot can be set alone: it means that a new MSCG must be computed 
    % from scratch starting from the given root node contained in initRoot;
    % if at least one among initTree, initEquivalenceMap or initGraph is
    % given, all these three fields must be given: it
    % means that computation is built starting from the given graph; in
    % addition either must be given, i.e. a new root node, not present in the
    % given graph, from which computation starts, or initRootID is given, i.e.
    % one of the nodes of the given tree is selected.
    % 
    % enTrCallback is an optional user function called whenever a transition could 
    % fire in class Ck. This user function can be used to implement a custom 
    % stop condition or a debugging/logging function; 
    % it must receive as input two arguments: 1) algoInfo and 2) enTrCallbackASO.
    % The first argument, algoInfo, is a struct made of the following
    % fields
    % - tree
    % - root
    % - equivalenceMap
    % - graph
    % - currentClass
    % - currentTransition
    % The second argument, enTrCallbackASO, is a struct containing any 
    % state data needed by the function enTrCallback itself;
    % this struct must be initially given as empty argument to the function; once
    % executed, enTrCallback must yield an updated version of enTrCallbackASO, which is
    % automatically fed-back at the next call by the algorithm computing the MSCG; 
    % two fields of this struct are used by the algorithm computing the MSCG:
    % 'fire' which is the boolean value used for triggering the exploration
    % of the currentTransition, and 'stop' which stops the exploration of
    % any other branch of the tree other than the current one.
    % the enTrCallback can be used to modulate the order of exploration
    % of the MSCG classes: at currentClass, the transition currentTransition  
    % could be fired by the custom function, by setting to true the 'fire' variable in the
    % enTrCallbackASO variable; then, the next class visited by the algorithm
    % computing the MSCG is the class reached by firing currentTransition from currentClass,
    % and the exploration continues from such class, even if it is a duplicate of a previously
    % computed class; another transition of the aforementioned currentClass can be explored only by returning
    % to that class through an appropriate cyclic sequence
    %
    % ignoredTransitionsSet is an optional argument: it must be a set of transition indices.
    % These transitions are ignored during the computation of the MSCG, in the
    % sense that they are filtered out from the state-enabled transitions
    % of any net marking; consequently, they will not be fired, and their
    % timing information is not computed
    %
    % transitionsSetStop is an optional argument: it must be a set of transition indices.
    % During the exploration of the MSCG, if an arc associated to one of the contained
    % transitions is encountered, the search along that path is stopped,
    % and the exploration continued by back-tracking to the next path to
    % explore.
    % 
    % multiEnabling is an optional argument: it must be an array of size |T|; 
    % the i-th element is 1 if t_i has multiple degrees of enablingness, it is 0 otherwise.
    %
    % dispFlag is a flag that enables the printing on the console of the
    % MSCG computation
    %
    % the implementation follows the pseudo-algorithm presented in 
    % He, Z., Li, Z., Giua, A., Basile, F., and Seatzu, C. (2019).
    % Some remarks on ”State Estimation and Fault Diagnosis
    % of Labeled Time Petri Net Systems with Unobservable
    % Transitions”. IEEE Transactions on Automatic Control,
    % 64(12), 5253–5259.
    %
    % developed by Luigi Ferrara, PhD student of the Automatic Control Group
    % of UNISA. contacts: luigiferrara.info@gmail.com
    
    function [bound,isSymbolic,boundNum] = clearBound(origBound,func)
        isSymbolic = false;
        % apply min on components of supBound that are numerical
       [doubleVals,filteredOut]=filterOutSymVarsFromArray(origBound);
       boundNum=func(doubleVals);
       % as for symbolic components, still try to compute min
       % first map to each component index their sym vars
       symComps = origBound(filteredOut);
       if length(symComps)>1
           compsSymVars = containers.Map( 'KeyType','double', 'ValueType','any'); 
           for k=1:length(symComps)
               compsSymVars(k) = symvar(symComps(k));
           end
           compsToDelete = [];
           for j=1:length(symComps)
               if isempty(find(compsToDelete==j, 1))
                   symbolicVars = compsSymVars(j);
                   for k=1:length(symComps)
                       if not(isequal(j,k)) && isempty(find(compsToDelete==k,1))
                           if isequal(symbolicVars,compsSymVars(k))
                               [~,indcs] = func(subs([symComps(j),symComps(k)],symbolicVars,ones(1,length(symbolicVars))));
                               if indcs==1
                                   compsToDelete = [compsToDelete,k];
                               elseif indcs==2
                                   compsToDelete = [compsToDelete,j];
                               end
                           end
                       end
                   end
               end
           end
           symComps(compsToDelete) = [];
       end
       bound = [boundNum,symComps];
       if ~isempty(symComps)
           isSymbolic=true;
       end
       if isempty(symComps)
          bound=double(bound);
       end
    end
    
	if(not(exist('dispFlag','var')))
		dispFlag = false;
    end
    
    if not(exist('multiEnabling','var')) || isempty(multiEnabling)
        multiEnabling=zeros(1,size(TPN.PRE,2));
    end
    
	
    if(exist('enTrCallback','var') && isempty(enTrCallback))
        clear enTrCallback;
    end
    if(not(exist('computeExplicitTree','var')))
        computeExplicitTree=false;
    end
    
    rflag=0;    
    if not(exist('transitionsSetStop','var'))
        transitionsSetStop = [];
    end
    if not(exist('ignoredTransitionsSet','var'))
        ignoredTransitionsSet = [];
    end

    if not(isfield(TPN,'transitionsLabels'))
        TPN.transitionsLabels = cell(1,size(TPN.PRE,2));
    end
    
    enTrCallbackASO = [];
   
    copyfunc = @(x) copy(x);
    
    
    if isfield(initConds,'classDeltaState')
        classDeltaState = initConds.classDeltaState;
    else
        classDeltaState = [];
    end
    
    if isfield(initConds,'trThetaState')
        trThetaState = initConds.trThetaState;
    else
        trThetaState = [];
    end
    
    function map = appendValueToListInMap(map,key,value)
        if not(isKey(map,key))
            map(key) = {value};
        else
            if not(isSmallerArrayContainedInBigger({value},map(key)))
                map(key) = [map(key),...
                    {value}];
            end
        end
    end
    
    function initializeInverseEquivalenceMap()
        if not(isempty(equivalenceMap))
            %create the inverse equivalence map from given equivalence map
            remainingNodes = keys(equivalenceMap);
            toMergeNodes = values(equivalenceMap);
            for iii=1:length(remainingNodes)
                mergingNodes = toMergeNodes{iii};
                for j=1:length(mergingNodes)
                    thisID = mergingNodes{j};
                    toWhichIsEquivalent = remainingNodes(iii);
                    if isKey(inverseEquivalenceMap,thisID)
                        inverseEquivalenceMap(thisID) = [inverseEquivalenceMap(thisID),toWhichIsEquivalent];
                    else
                        inverseEquivalenceMap(thisID) = toWhichIsEquivalent;
                    end
                end
            end
        end
    end
    
    function newIntervalInfo= createInterval(newInstance,tr,trkInterval,infBound,supBound,ckDelta,trTheta,CkAliasGraphID)
       %trkInterval is not empty only if newInstance is false
       if not(newInstance)

          if isnumeric(infBound) && isnumeric(supBound) && infBound==supBound
              thisInfBound = trkInterval.inf - infBound;
              thisUppBound = trkInterval.sup - infBound;
          else
              thisInfBound = trkInterval.inf - ckDelta;
              thisUppBound = trkInterval.sup - ckDelta;
          end


          if(isequal(thisUppBound,sym(0)))
              thisUppBound = 0;
          end

          newIntervalInfo=createIntervalInfo(thisInfBound,...
              thisUppBound,...
              trTheta,...
              trkInterval,ckDelta);
      else
          baseInterval = TPNintervals{tr};
          newIntervalInfo=createIntervalInfo(baseInterval(1),baseInterval(2),trTheta);
      end

      if isnumeric(newIntervalInfo.inf)
          newIntervalInfo.inf = max(0,newIntervalInfo.inf);
      else
          if not(isequal(newIntervalInfo.inf(1),sym(0)))
             newIntervalInfo.inf = [0,newIntervalInfo.inf];
          end
          toDelete = [];
          for jjj=1:length(newIntervalInfo.inf)
              if isequal(sign(newIntervalInfo.inf(jjj)),sym(-1))
                 toDelete=[toDelete,jjj];
              end
          end
          newIntervalInfo.inf(toDelete) = [];
      end

      if(isequal(newIntervalInfo.inf,sym(0)))
              newIntervalInfo.inf = 0;
      end
      if(isequal(newIntervalInfo.sup,sym(Inf)))
              newIntervalInfo.sup = Inf;
      end
      
      initialInterval = newIntervalInfo;
      changed=false;
      
       %check for this theta if the lower bound is ever > 0 ; if not,
       %substitute it with 0
       if not(isnumeric(newIntervalInfo.inf)) && length(newIntervalInfo.inf)>1

            deltaVarsToEncounter = symvar(newIntervalInfo.inf);
            if not(isempty(deltaVarsToEncounter))
                deltaVarsToEncounter=setdiff(deltaVarsToEncounter,ckDelta); 
            end

           [~,~,ASO] = getAllPathsFromNode(CkAliasGraphID,graph,true,true,...
                        initExtraVarsPathDeltasEncountered(deltaVarsToEncounter,...
                        [ EPSILONCONST-newIntervalInfo.inf(end),...
                          infBound-ckDelta,...
                          ckDelta-supBound]),...
                        @canInsertNodeToPathDeltasEncountered,...
                        @newNodeAddedToPathActionDeltasEncountered,...
                        @canDiscoverChildrenDeltasEncountered,...
                        @newPathAddedActionDeltasEncountered,...
                        @canStoreBranchToPathsDeltasEncountered,...
                        @newBranchActionDeltasEncountered,...
                        @canExitDeltasEncountered);

          % if it can never be > 0, then substitute
          % it with 0 value
          if not(ASO.exit)
              newIntervalInfo.inf =0;
          end
          
          %check if it can ever be less than 0
          [~,~,ASO] = getAllPathsFromNode(CkAliasGraphID,graph,true,true,...
                        initExtraVarsPathDeltasEncountered(deltaVarsToEncounter,...
                        [ -EPSILONCONST+newIntervalInfo.inf(end),...
                          infBound-ckDelta,...
                          ckDelta-supBound]),...
                        @canInsertNodeToPathDeltasEncountered,...
                        @newNodeAddedToPathActionDeltasEncountered,...
                        @canDiscoverChildrenDeltasEncountered,...
                        @newPathAddedActionDeltasEncountered,...
                        @canStoreBranchToPathsDeltasEncountered,...
                        @newBranchActionDeltasEncountered,...
                        @canExitDeltasEncountered);
          % if it can never be < 0, then remove 0 value
          if not(ASO.exit)
              newIntervalInfo.inf =newIntervalInfo.inf(2:end);
          end
       end

     if isequal(newIntervalInfo.inf,0) && not(isnumeric(newIntervalInfo.sup)) && not(isequal(newIntervalInfo.sup,Inf))

      % check if upper bound is ever greater than 0,
      % otherwise substitute with 0
         deltaVarsToEncounter = symvar(newIntervalInfo.sup);
        if not(isempty(deltaVarsToEncounter))
            deltaVarsToEncounter=setdiff(deltaVarsToEncounter,ckDelta);
        end

           [~,~,ASO] = getAllPathsFromNode(CkAliasGraphID,graph,true,true,...
                        initExtraVarsPathDeltasEncountered(deltaVarsToEncounter,...
                        [ EPSILONCONST-newIntervalInfo.sup,...
                          infBound-ckDelta,...
                          ckDelta-supBound]),...
                        @canInsertNodeToPathDeltasEncountered,...
                        @newNodeAddedToPathActionDeltasEncountered,...
                        @canDiscoverChildrenDeltasEncountered,...
                        @newPathAddedActionDeltasEncountered,...
                        @canStoreBranchToPathsDeltasEncountered,...
                        @newBranchActionDeltasEncountered,...
                        @canExitDeltasEncountered);
            if not(ASO.exit)
                newIntervalInfo.sup =0;
            end
     end
          
     % update ordered subtractors
     remainedDeltas = symvar(newIntervalInfo.sup);
     if not(isempty(remainedDeltas)) && not(isempty(symvar(newIntervalInfo.inf)))
        remainedDeltas = union(remainedDeltas,symvar(newIntervalInfo.inf));
     end
     if not(isequal(length(remainedDeltas),length(newIntervalInfo.orderedSubtractors)))
         if isempty(remainedDeltas) && not(isempty(newIntervalInfo.orderedSubtractors))
             newIntervalInfo.orderedSubtractors= [];
         else
             newIntervalInfo.orderedSubtractors = newIntervalInfo.orderedSubtractors(...
                 find(newIntervalInfo.orderedSubtractors==remainedDeltas));
         end
     end
    end
    
    nMaxDelta = 150;
    
    function ID = getGraphEquivalentNodeID(nodeID)
       fusedNodes = values(equivalenceMap);
       finalNodes = keys(equivalenceMap);
       found = false;
       
       for lll=1:length(fusedNodes)
           if isSmallerArrayContainedInBigger( {nodeID},fusedNodes{lll} )
               ID = finalNodes{lll};
               return;
           end
       end
       
       ID=nodeID;
    end
    function coupleID = getCoupleID(Ck,Cq)
       kid = getNodeID(Ck);
       qid = getNodeID(Cq);
       sorted = sort({kid,qid});
       coupleID = [sorted{1},'_',sorted{2}];
    end
    
    function check = checkExternalFirability(t_i)
        if exist('enTrCallback','var')
            algoInfo.tree=tree;
            algoInfo.rootNode=rootNode;
            algoInfo.equivalenceMap = equivalenceMap;
            algoInfo.graph =graph;
            algoInfo.Ck = Ck;
            algoInfo.t_i = t_i;
            enTrCallbackASO = enTrCallback(algoInfo,enTrCallbackASO);
            check = enTrCallbackASO.fire;
        else
            check = true;
        end
    end
    
    function check = checkStop()
        if exist('enTrCallback','var') && not(isempty(enTrCallbackASO))
            check = enTrCallbackASO.stop;
        else
            check = false;
        end
    end
    
    function check = onlyInitRootGiven()
        theseFields = fieldnames(initConds);
        
        
        if length(theseFields)==1
            assert(isfield(initConds,'initRoot'));
            check=true;
        else
            assert(isfield(initConds,'initTree'));
            assert(isfield(initConds,'initEquivalenceMap'));
            assert(isfield(initConds,'initGraph'));
            assert(isfield(initConds,'initRootID'));
            check = (isempty(initConds.initTree) &&...
                      isempty(initConds.initEquivalenceMap) && ...
                      isempty(initConds.initGraph) && ...
                      isempty(initConds.initRootID));
        end
    end
    
    EPSILONCONST = getEpsilon();
    Tks = containers.Map( 'KeyType','double', 'ValueType','any'); %initializing map
    pastPathsHistory = [];
    isomoOfCouples = containers.Map( 'KeyType','char', 'ValueType','any'); %initializing map
    
    atLeastOneEnabledTransitionEncountered = false;
    
    function algorithm2(Duplicate)
        CkAliasGraphID = getGraphEquivalentNodeID(getNodeID(Ck));
        originalTk = getStateEnabledTransitions(getInfoFromInfos(getMarkingInfoID(),getNodeInfos(Ck)),PRE,ignoredTransitionsSet);
        transitionsToVisit = createEmptyStack();
        for ll = length(Tk):-1:1
            transitionsToVisit = stackElement(Tk(ll),transitionsToVisit);
        end
        [t_i,transitionsToVisit] = popElement(transitionsToVisit);
        
        while(not(isempty(t_i)))
            if isempty(find(Ck.outTransitions==t_i, 1))
                
               if checkStop()
                   break;
               end
               
               externalFirab = checkExternalFirability(t_i);
                
               if externalFirab
                   [isFirable, pastPathsHistory ]= isMSCGTransitionFirable(graph,t_i, originalTk,Ck,pastPathsHistory); 
               end
               
               if externalFirab && isFirable
                   atLeastOneEnabledTransitionEncountered = true;
                   CkID = getNodeID(Ck);
                   CkAliasGraphID = CkID;
                   
                   if not(isequal(CkID,getGraphEquivalentNodeID(getNodeID(Ck))))
                       error('error: inconsistency between IDs');
                       % in case of error try to change the previous line code with:  CkAliasGraphID = getGraphEquivalentNodeID(getNodeID(Ck));
                   end
                   
                   Tk = setdiff(Tk,t_i);
                   Mq = Mk + C(:,t_i);
                   Tq = getStateEnabledTransitions(Mq,PRE,ignoredTransitionsSet);
                   CkConstraintsInfos = getInfoFromInfos(getConstraintsInfoID(),getNodeInfos(tree(CkID)));
                    
                   
                   constraintsInfos = createEmptyConstraintsInfo();

                   % first compute edge bounds 
                   % to add an edge from Ck to Cq
                   % first, compute sup of the edge
                   supBound=[];
                   infos = getNodeInfos(Ck); intervalsMap=getInfoFromInfos(getConstraintsInfoID(),infos);
                   for k=1:length(originalTk)
                       t_j = originalTk(k);
                       interval = intervalsMap(t_j);
                       supBound=[supBound,interval.sup];
                   end
                   origSupBound = unique(supBound);
                   [supBound,isSupSym,supNumComponent] = clearBound(origSupBound,@min);
                   if isSupSym
                       infIdcs=find(supBound==sym(Inf));
                       if not(length(infIdcs) == length(supBound))
                          supBound=supBound(setdiff(1:length(supBound),infIdcs));
                       end
                   end
                   
                   % then compute inf of the edge
                   origInfBound = unique([0,CkConstraintsInfos(t_i).inf]);
                   infBound = clearBound(origInfBound,@max);

                    
                   %the following optimizations, signaled by %% '*'... %%,
                   %allow to clean arcs bounds, by minimizing the number of
                   %delta variables they contain; this allow to potentially
                   %speed-up backwards search and make the MSCG more
                   %succint
                   
                  %% * check if lower bound of the edge can ever be less than 0
                  if not(isnumeric(infBound))
                      [~,~,ASO] = getAllPathsFromNode(CkAliasGraphID,graph,true,true,...
                                    initExtraVarsPathDeltasEncountered(symvar(infBound(2:end)),...
                                    -EPSILONCONST+infBound(2:end)),...
                                    @canInsertNodeToPathDeltasEncountered,...
                                    @newNodeAddedToPathActionDeltasEncountered,...
                                    @canDiscoverChildrenDeltasEncountered,...
                                    @newPathAddedActionDeltasEncountered,...
                                    @canStoreBranchToPathsDeltasEncountered,...
                                    @newBranchActionDeltasEncountered,...
                                    @canExitDeltasEncountered);
                      % if it can never be < 0, then remove 0 value
                      if not(ASO.exit)
                          infBound =infBound(2:end);
                      end
                  end
                  
                  if not(isempty(supNumComponent))
                      if not(isnumeric(supBound))
                          toDelete = [];
                          for j=length(supBound):-1:1
                              for k=1:j-1
                                  % * check if the j component of supBound can ever be less than
                                  % the k component of supBound
                                  idcs = zeros(1,length(supBound));
                                  idcs(j) = 1; idcs(k) = 1;
                                  idcs = logical(idcs);
                                  [~,~,ASO] = getAllPathsFromNode(CkAliasGraphID,graph,true,true,...
                                                initExtraVarsPathDeltasEncountered(symvar(supBound(idcs)),...
                                                -supBound(k)+EPSILONCONST+supBound(j)),...
                                                @canInsertNodeToPathDeltasEncountered,...
                                                @newNodeAddedToPathActionDeltasEncountered,...
                                                @canDiscoverChildrenDeltasEncountered,...
                                                @newPathAddedActionDeltasEncountered,...
                                                @canStoreBranchToPathsDeltasEncountered,...
                                                @newBranchActionDeltasEncountered,...
                                                @canExitDeltasEncountered);
                                  % if it can never, then remove the j
                                  % component
                                  if not(ASO.exit)
                                      toDelete =[toDelete,j];
                                  end
                              end
                          end
                          supBound(toDelete) = [];
                          if length(supBound)==1 && isempty(symvar(supBound))
                              supBound = double(supBound);
                          end
                      end
                  end
                   assert(not(isempty(supBound)));
                   
                  %%
                   
                   
                   [ckDelta, classDeltaState] = getClassDelta(CkID,classDeltaState,nMaxDelta);
                   
                   cqMultiEnInfo = createEmptyMultiEnablingConstraintsInfo(size(PRE,2)); % create multi enabling info, initially void
                   ckMultiEnInfo = getInfoFromInfos(getMultiEnablingConstraintsInfoID(),getNodeInfos(tree(CkID)));
                   
                   %set bounds for transitions of future state Cq
                   for jj=1:length(Tq)
                      tr = Tq(jj);
                      [trTheta,trThetaState] = getTransitionTheta(tr,trThetaState,size(PRE,2));
                      
                      % compute enabling degree of tr
                      if multiEnabling(tr)
                         % 1) compute the number of times this transition 
                         % can fire consecutively
                         trDegree = computeTransitionDegree(Mq,PRE,POST,tr);
                         
                         % get the set of intervals related to tr
                         intervalsArray = getMultiEnablingConstraintsInfo(tr,ckMultiEnInfo);
                         % add also the last main one, if any
                         if isKey(CkConstraintsInfos,tr)
                             trkInterval = CkConstraintsInfos(tr);
                             trkInterval.age = 0;
                             intervalsArray=[trkInterval,intervalsArray];
                         end
                         
                         % 2) remove exceeding instances from
                         % ckMultiEnInfoTemp (if any)
                         previousInstances = length(intervalsArray);
                         toDeleteInstances = previousInstances-trDegree;
                         intervalsArray(1:toDeleteInstances) = [];
                      end
                      
                      % compute theta conditions for tr

                      if multiEnabling(tr)
                          % implementation of the infinite server semantic
                          % with the following policies:
                          % - firing choice policy: First Enabled First Fired
                          % - disabling choice policy: First Enabled First Disabled
                          % - memory policy: intermediate semantic.

                          % 3) find how many of the remaining instances in the array are disabled by the
                          % intermediate marking
                          intermediateTrDegree = computeTransitionDegree(Mk - PRE(:,t_i),PRE,POST,tr);
                          toDeleteInstances = length(intervalsArray) - intermediateTrDegree;
                          intervalsArray(1:toDeleteInstances) = [];
                          
                          % 4) handle instances
                          first = true;
                          
                          for currentDegree = 1: trDegree
                              newInterval = isempty(intervalsArray);
                              if not(newInterval)
                                  oldInterval = intervalsArray(1);
                                  intervalsArray(1) = [];
                                  currentInterval = createInterval(false,tr,oldInterval,infBound,supBound,ckDelta,trTheta,CkAliasGraphID);
                              else
                                  currentInterval = createInterval(true,tr,[],infBound,supBound,ckDelta,trTheta,CkAliasGraphID);
                              end
                              
                              if first
                                  mainIntervalInfo = currentInterval;
                                  first=false;
                              else
                                  cqMultiEnInfo=addMultiEnablingConstraintsInfo(currentInterval,tr,cqMultiEnInfo);
                              end
                          end
                      else
                         % implementation of SINGLE-Server semantic with
                         % intermediate policy as memory policy
                         intermediateMainReset = false;
                         intermediateMainReset = isempty(find(...
                             getStateEnabledTransitions(Mk - PRE(:,t_i),PRE,ignoredTransitionsSet)==tr, 1)); %intermediate semantics: two step firing. A transition
                                                                                       %disabled by the intermediate firing is reset
                         newInstance = intermediateMainReset || ...
                             isempty(find(originalTk==tr, 1)) ... %if transition is newly enabled, timing must be reset
                              || t_i==tr; %intermediate semantic: if the fired transition enables again itself, it is considered as newly enabled
                         
                         if isKey(CkConstraintsInfos,tr)
                             trkInterval = CkConstraintsInfos(tr);
                         else
                             trkInterval=[];
                         end
                         mainIntervalInfo = createInterval(newInstance,tr,trkInterval,infBound,supBound,ckDelta,trTheta,CkAliasGraphID);
                      end
                      
                      constraintsInfos(tr) = mainIntervalInfo;
                   end


                   Cq = createNodeByID(num2str(currClassNum),num2str(currClassNum),createInfos({...
                   getMarkingInfoID(),createMarkingInfo(Mq),...
                   getTagInfoID(),createTagInfo(untaggedTag()),...
                   getConstraintsInfoID(),createConstraintsInfo(constraintsInfos),...
                   getMultiEnablingConstraintsInfoID(),cqMultiEnInfo}));

                   graph=addNodesToGraph(copy(Cq),graph);
                   
                   % compute edge distance
                   [predecessorNodes,transitions] = getPredecessorNodes(tree,getNodeID(Ck));
                   assert(isequal(getNodeID(Ck),'0') || length(predecessorNodes)==1);
                   if isequal(getNodeID(Ck),'0')
                       distance = 1;
                   else
                       trInfos = getInfosOfLinkingTransition(predecessorNodes(1),transitions{1});
                       fatherDistanceInfo = getInfoFromInfos(getDistanceInfoID(),trInfos);
                       if isempty(fatherDistanceInfo)
                           % compute it
                           [IDpaths] = getAllPathsFromNodeSimple(getNodeID(Ck),tree, true, true);
                           assert(length(IDpaths)==1);
                           fatherDistanceInfo = length(IDpaths{1});
                           % save it on the tree
                           newTrInfos = setInfoToInfos(trInfos,getDistanceInfoID(),fatherDistanceInfo);
                           predecessorNodes{1} = setInfosOfLinkingTransition(predecessorNodes{1},transitions{1},newTrInfos);
                           tree(getNodeID(Ck)) = predecessorNodes{1};
                           % save it on the graph
                           graphTrInfo = getInfosOfLinkingTransition(graph(getNodeID(predecessorNodes(1))),transitions{1});
                           newGraphTrInfo = setInfoToInfos(graphTrInfo,getDistanceInfoID(),fatherDistanceInfo);
                           graph(getNodeID(predecessorNodes{1})) = setInfosOfLinkingTransition(graph(getNodeID(predecessorNodes{1})),transitions{1},newGraphTrInfo);
                       end
                       distance = fatherDistanceInfo+1;
                   end
                       
                   % now link classes on the tree
                   [tree(getNodeID(Cq)),tree(getNodeID(Ck))] = linkChildAndFather(copy(Cq),copy(Ck),t_i,createInfos({...
                       getIntervalInfoID(),createIntervalInfo(...
                           infBound ,...
                           supBound ,...
                           ckDelta),...
                       getTagInfoID(),createTagInfo(untaggedTag()),...
                       getConstraintsInfoID(),createConstraintsInfo(constraintsInfos),...
                       getDistanceInfoID(),distance,...
                       getLabelInfoID(),TPN.transitionsLabels{t_i}}));
                   % do the same on the graph
                   reachedNode=getReachedNodeByTransition(graph,CkAliasGraphID,t_i);
                   
                   if not(computeExplicitTree)
                       if isempty(reachedNode)
                           [ckAliasDelta, classDeltaState] = getClassDelta(CkAliasGraphID,classDeltaState,nMaxDelta);
                           [graph(getNodeID(Cq)),graph(CkAliasGraphID)] = linkChildAndFather(graph(getNodeID(Cq)),graph(CkAliasGraphID),t_i,createInfos({...
                               getIntervalInfoID(),createIntervalInfo(...
                                   infBound ,...
                                   supBound ,...
                                   ckAliasDelta),...
                               getTagInfoID(),createTagInfo(untaggedTag()),...
                               getConstraintsInfoID(),createConstraintsInfo(constraintsInfos),...
                               getDistanceInfoID(),distance,...
                               getLabelInfoID(),TPN.transitionsLabels{t_i}}));
                       else
                           if not(isequal(getNodeID(reachedNode),getNodeID(Cq)))
                               [bool,isoEqs] =  areTwoClassesEquivalent(reachedNode,Cq); %find equivalence between Ce and Cq; if it exist, 
                                % isoEqs contains equivalences Delta^(e) := Delta^(q) in the ordered equation form: Delta^(e)-Delta^(q) = 0
                                isomoOfCouples(getCoupleID(Cq,reachedNode)) = isoEqs;
                                if bool
                                    % equivalence map handling
                                    assert(not(any(getLogicalKeyIndecesFromValue( equivalenceMap,getNodeID(reachedNode)))));
                                    equivalenceMap = appendValueToListInMap(equivalenceMap,getNodeID(reachedNode),getNodeID(Cq));
                                    % inverse equivalence map handling
                                    inverseEquivalenceMap = appendValueToListInMap(inverseEquivalenceMap,getNodeID(Cq),getNodeID(reachedNode));                                
                                end
                           end
                       end
                   end
                   
                   Cq = tree(getNodeID(Cq)); Ck = tree(getNodeID(Ck));
                   currClassNum=currClassNum+1;

                   if not(computeExplicitTree)

                       Ce = [];
                       % filling equivalence map for Cq              
                       classes = keys(tree);
                       for c=1:length(classes)
                           classID = classes{c};
                           if not(isequal(classID,getNodeID(Cq))) && not(isClassDuplicate(tree(classID)))
                               if not(isKey(equivalenceMap, classID )) || isempty(findStringInCellArray( getNodeID(Cq) , equivalenceMap(classID)))
                                  [bool,isoEqs] =  areTwoClassesEquivalent(tree(classID),Cq); %find equivalence between Ce and Cq; if it exist, 
                                  % isoEqs contains equivalences Delta^(e) := Delta^(q) in the ordered equation form: Delta^(e)-Delta^(q) = 0
                                  isomoOfCouples(getCoupleID(Cq,tree(classID))) = isoEqs;
                                  if bool
                                       % equivalence map handling
                                      assert(not(any(getLogicalKeyIndecesFromValue( equivalenceMap,classID))));
                                      equivalenceMap = appendValueToListInMap(equivalenceMap,classID,getNodeID(Cq));
                                      % inverse equivalence map handling
                                      inverseEquivalenceMap = appendValueToListInMap(inverseEquivalenceMap,getNodeID(Cq),classID);        
                                  end
                               end
                           end
                       end


                       % if there already exist a set of nodes equivalent to...
                       if isKey(inverseEquivalenceMap,getNodeID(Cq))
                           equivalentNodeIDs = inverseEquivalenceMap(getNodeID(Cq));
                       else
                           equivalentNodeIDs = [];
                       end
                       
                   end
                   if not(computeExplicitTree) && not(isempty(equivalentNodeIDs))
                        Cq = tree(getNodeID(Cq));
                        tree(getNodeID(Cq)) = setNodeInfos( tree(getNodeID(Cq)) ,...
                            setInfoToInfos(duplicateTag(),getTagInfoID(),getNodeInfos(Cq))); %set Cq as duplicate
                        graph(getNodeID(Cq)) = setNodeInfos( graph(getNodeID(Cq)) ,...
                            setInfoToInfos(duplicateTag(),getTagInfoID(),getNodeInfos(graph(getNodeID(Cq))))); %set Cq as duplicate


                        equivClasses = '';
                        for qq=1:length(equivalentNodeIDs)
                           equivClasses = [equivClasses,equivalentNodeIDs{qq}];
                           if qq<length(equivalentNodeIDs)
                               equivClasses = [equivClasses,', '];
                           end
                        end
						
						if dispFlag
							disp(['> THE FOLLOWING CLASS IS EQUIVALENT OF CLASS(ES) ',equivClasses,': ']);
							printClass(tree(getNodeID(Cq)));
						end

                        for k=1:length(equivalentNodeIDs)
                            equivalentNodeID = equivalentNodeIDs{k};
                            Ce = tree(equivalentNodeID);
                            if not(isClassDuplicate(Ce)) % if Ce is not duplicate
                                % add isomorphism entry
                                isoEqs = isomoOfCouples(getCoupleID(Ce,Cq));

                                [tree(getNodeID(Ck))] = setInfosOfLinkingTransition(tree(getNodeID(Ck)),t_i,...
                                    setInfoToInfos(...
                                    createIsomorphismInfo(isoEqs),getIsomorphismInfoID(),...
                                    getInfosOfLinkingTransition(tree(getNodeID(Ck)),t_i)));

                                 [graph(CkAliasGraphID)] = setInfosOfLinkingTransition(graph(CkAliasGraphID),t_i,...
                                    setInfoToInfos(...
                                    createIsomorphismInfo(isoEqs),getIsomorphismInfoID(),...
                                    getInfosOfLinkingTransition(graph(CkAliasGraphID),t_i)));

                                % fuse nodes in the graph
                                graph=fuseNodes(graph,graph(getGraphEquivalentNodeID(getNodeID(Ce))),graph(getNodeID(Cq)),true);
                                if k==length(equivalentNodeIDs)
                                    remove(graph,getNodeID(Cq));
                                end

                            end
                            for kk=1:length(defIDs)
                               defID = defIDs{kk};
                               if isKey(L_Map,defID)
                                   L_Map(defID) = [L_Map(defID),{getNodeID(Cq)}];
                               else
                                   L_Map(defID) = {getNodeID(Cq)};
                               end
                            end

                            if isempty(findStringInCellArray(getNodeID(Cq),dupIDs))
                                dupIDs = [dupIDs, {getNodeID(Cq)}];
                            end
                        end
                   else
                       if isempty(find(transitionsSetStop==t_i, 1))
                           theTag = newTag();
                       else
                           theTag = stoppedTag();
                       end
                        
                       if not(exist('enTrCallback','var'))
                           tree(getNodeID(Cq)) = setNodeInfos(Cq,setInfoToInfos(theTag,getTagInfoID(),getNodeInfos(Cq))); %set Cq as new
                           graph(getNodeID(Cq)) = setNodeInfos(graph(getNodeID(Cq)),setInfoToInfos(theTag,getTagInfoID(),getNodeInfos(graph(getNodeID(Cq))))); %set Cq as new
                       end
                       Cq = tree(getNodeID(Cq));
                   end

                   
                   if exist('enTrCallback','var')
                       if not(isempty(Ce)) 
                           nextClassIDToExplore = getNodeID(Ce);
                       else
                           nextClassIDToExplore = getNodeID(Cq);
                       end
                       break;
                   end
               end

            else
                if checkExternalFirability(t_i)
                    nextClassIDToExplore = getNodeID(getReachedNodeByTransition( graph, getNodeID(Ck), t_i ));
                    theTag = newTag();
%                     if not(isempty(find(transitionsSetStop==t_i, 1)))
%                         theTag = stoppedTag();
%                     end
                    if not(exist('enTrCallback','var')) && not(isSmallerArrayContainedInBigger({nextClassIDToExplore},exploredClassesIDs))
                        tree(nextClassIDToExplore)  = updateNodeInfoTo(tree(nextClassIDToExplore),getTagInfoID(),theTag); %set as new
                        graph(nextClassIDToExplore) = updateNodeInfoTo(graph(nextClassIDToExplore),getTagInfoID(),theTag); %set as new
                    end
                    Tks(str2double(getNodeID(Ck))) = setdiff(Tk,Ck.outTransitions);
                    if exist('enTrCallback','var')
                        break;
                    end
                end
            end
            [t_i,transitionsToVisit] = popElement(transitionsToVisit); %select t_i \in Tk %WHILE HAS BEEN REPLACED WITH SUCCESSIVE POPS FROM A STACK
            Tks(str2num(getNodeID(Ck))) = Tk;
        end
        
        CkIndexInDefIDs = findStringInCellArray(getNodeID(Ck),defIDs);
        
        if not(exist('enTrCallback','var')) && not(isempty(Tk)) && isempty(CkIndexInDefIDs)
			if dispFlag && not(isSmallerArrayContainedInBigger({getNodeID(Ck)},classesInTheInitialTree))
				disp(['> CLASS ',getNodeID(Ck),' IS SET DEFICIENT']);
            end
			defIDs = [defIDs, {getNodeID(Ck)}];
            tree(getNodeID(Ck)) = setNodeInfos(Ck,setInfoToInfos(deficientTag(),getTagInfoID(),getNodeInfos(Ck)));
            graph(CkAliasGraphID) = setNodeInfos(graph(CkAliasGraphID),setInfoToInfos(deficientTag(),getTagInfoID(),getNodeInfos(graph(CkAliasGraphID))));
            Ck = tree(getNodeID(Ck));
        end
        
        if not(exist('enTrCallback','var')) && isempty(Tk) && not(isempty(CkIndexInDefIDs))
			if dispFlag && not(isSmallerArrayContainedInBigger({getNodeID(Ck)},classesInTheInitialTree))
				disp(['> CLASS ',getNodeID(Ck),' IS NOT DEFICIENT ANYMORE']);
            end
			defIDs(CkIndexInDefIDs) = [];
            tree(getNodeID(Ck)) = setNodeInfos(Ck,setInfoToInfos(untaggedTag(),getTagInfoID(),getNodeInfos(Ck)));
            graph(CkAliasGraphID) = setNodeInfos(graph(CkAliasGraphID),setInfoToInfos(untaggedTag(),getTagInfoID(),getNodeInfos(graph(CkAliasGraphID))));
            Ck = tree(getNodeID(Ck));
        end
        
        CkIndexInDefIDs = findStringInCellArray(getNodeID(Ck),defIDs);
        
        if not(isempty(CkIndexInDefIDs))
           L_Map(getNodeID(Ck)) = [];
        end
    end
    
    
    M0 = TPN.m0;
    PRE= TPN.PRE;
    POST=TPN.POST;
    C=POST-PRE;
    TPNintervals=TPN.intervals; %cell array associating to each transition an interval [inf,sup]
           
    tree = createEmptyGraph();
    graph = createEmptyGraph();
        
    %initialize algorithm
    defIDs = []; % cell array of strings
    dupIDs = []; % cell array of strings
    equivalenceMap = containers.Map( 'KeyType','char', 'ValueType','any'); % associates to each class ID the IDs of the equivalent (duplicate) nodes
    inverseEquivalenceMap = containers.Map( 'KeyType','char', 'ValueType','any'); % takes a nodeID and returns a cell-array of nodeIDs it is duplicate of.
    L_Map = containers.Map( 'KeyType','char', 'ValueType','any'); % associates to each deficient class Ck ID the duplicate nodes' IDs ... 
    %                                                               definition
    %                                                               of Lk
    addInitNodeToTree = false;
    if not(isempty(initConds))
       assert(isfield(initConds,'initRoot')) ;
       % case where only initRoot is given
       if onlyInitRootGiven()
            rootNode = copyfunc(initConds.initRoot);
            rootID = getNodeID(rootNode);
            addInitNodeToTree = true;
       else
            tree = copyfunc(initConds.initTree);
            graph = copyfunc(initConds.initGraph);
            equivalenceMap = copyfunc(initConds.initEquivalenceMap);
            if isempty(initConds.initRootID)
                rootID = getNodeID(initConds.initRoot);
                rootNode = copyfunc(initConds.initRoot);
                addInitNodeToTree = true;
            else
                if isempty(initConds.initRoot)
                    rootID = initConds.initRootID;
                    rootNode = tree(rootID);
                end
            end
       end
       
    else
        
        currClassNum = 0;
        trs=getStateEnabledTransitions(M0,PRE,ignoredTransitionsSet);
        constraintsInfos = createEmptyConstraintsInfo();
        for i=1:length(trs)
            [interval]=TPNintervals{trs(i)}; inferior = interval(1); superior = interval(2);
            [trsiTheta,trThetaState] = getTransitionTheta(trs(i),trThetaState,size(PRE,2));
            constraintsInfos(trs(i)) = createIntervalInfo(inferior,superior,trsiTheta);
        end
        %creating class 0
        node = createNodeByID(num2str(currClassNum),num2str(currClassNum),createInfos({...
            getMarkingInfoID(),createMarkingInfo(M0),...
            getTagInfoID(),createTagInfo(newTag()),...
            getConstraintsInfoID(),createConstraintsInfo(constraintsInfos),...
            getMultiEnablingConstraintsInfoID(), createEmptyMultiEnablingConstraintsInfo(size(PRE,2))}));
        rootNode = node;
        rootID = getNodeID(rootNode);
        addInitNodeToTree =true;
    end
       
    if addInitNodeToTree
       tree(getNodeID(rootNode))=rootNode;
       graph(getNodeID(rootNode)) = copyfunc(rootNode);
    end
    currClassNum=max(cellfun(@(x) str2double(x),keys(tree)))+1;
    
    classesInTheInitialTree = keys(tree);
    
    newClassesIDs = {rootID};
    
    % set inverseEquivalenceMap
    initializeInverseEquivalenceMap();
    
    exploredClassesIDs = cell(0);

    while(not(isempty(newClassesIDs)))
        Ck = tree(newClassesIDs{1});
        infos = getNodeInfos(Ck); Mk=getInfoFromInfos(getMarkingInfoID(),infos);
        Tk = getStateEnabledTransitions(Mk,PRE,ignoredTransitionsSet);
        nextClassIDToExplore = [];
        
        %apply function Look for new nodes on Ck, dupIDs (ALG.2)
        algorithm2(dupIDs);
        
		if dispFlag && not(isSmallerArrayContainedInBigger({getNodeID(Ck)},classesInTheInitialTree))
			disp('> COMPLETED THE COMPUTATION OF THE NEW CLASS: ')
			printClass(tree(getNodeID(Ck)));
			outNodes = getOutNodesMap(Ck);
			outNodesTransitions = values(outNodes);
			outNodesNodes = keys(outNodes);
			for i=1:length(outNodesTransitions)
				disp('> IT IS LINKED TO CLASS ')
				printClass(tree(outNodesNodes{i}));
				disp('> THROUGH ARC');
				printArc(Ck,outNodesTransitions{i});
			end
		end
		
        if not(exist('enTrCallback','var'))
            tree(getNodeID(Ck)) = setNodeInfos(Ck,setInfoToInfos(untaggedTag(),getTagInfoID(),getNodeInfos(Ck))); % untag ck
            graph(getGraphEquivalentNodeID(getNodeID(Ck))) = setNodeInfos(graph(getGraphEquivalentNodeID(getNodeID(Ck))),setInfoToInfos(untaggedTag(),getTagInfoID(),getNodeInfos(Ck))); % untag ck
        end
        
        Ck = tree(getNodeID(Ck));
        
        exploredClassesIDs=[exploredClassesIDs,getNodeID(Ck)];
    
        newClassesIDs = getNewClasses(tree);
        if isempty(newClassesIDs) && dispFlag
            disp('> NO CLASS TAGGED NEW EXISTS');
        end
        
        if checkStop()
            break;
        else
            if exist('enTrCallback','var') && isempty(nextClassIDToExplore)
               warning('Computation stopped because no successor is explored');
               rflag=1;
               break;
            end
        end
        if exist('enTrCallback','var')
            newClassesIDs={nextClassIDToExplore};
        end
        atLeastOneEnabledTransitionEncounteredInWhile = [];
        while(isempty(newClassesIDs))
            processedOne = false;
            defIDsToExplore=defIDs;
            if isequal(atLeastOneEnabledTransitionEncounteredInWhile,false)
                break;
            end
            atLeastOneEnabledTransitionEncounteredInWhile = false;
            while(not(isempty(defIDsToExplore)))
                thisDefID = defIDsToExplore{1};
                if isKey(L_Map, thisDefID) && not(isempty(L_Map(thisDefID)))
                    Ck = tree(thisDefID);        
                    infos = getNodeInfos(Ck); Mk=getInfoFromInfos(getMarkingInfoID(),infos);
                    Tk = Tks(str2double(getNodeID(Ck)));
                    algorithm2(L_Map(thisDefID));
                    processedOne = true;
                    if atLeastOneEnabledTransitionEncountered
                        atLeastOneEnabledTransitionEncounteredInWhile=true;
                        atLeastOneEnabledTransitionEncountered = false; % reset of the variable once algorithm is executed and data is used
                    end
                end
                
                newClassesIDs = getNewClasses(tree);
                if not(isempty(newClassesIDs))
                    break;
                end
                defIDsToExplore(1)=[];
            end
            if (not(exist('enTrCallback','var')) && not(processedOne)) ||...
                    (exist('enTrCallback','var') && not(isempty(enTrCallbackASO)) && enTrCallbackASO.stop)
                break;
            end
            
        end
		if dispFlag && not(isSmallerArrayContainedInBigger({getNodeID(Ck)},classesInTheInitialTree))
         disp('==========================================================');
		 end
    end

    rootNodeID = rootID;
    
    initConds.classDeltaState = classDeltaState;
    initConds.trThetaState = trThetaState;
end

