function [IDpaths,transitionPaths,ASO] = getAllPathsFromNode(startNodeID,graph, goBackwards, skipCycles, initExtraVars, canInsertNodeToPath, newNodeAddedToPathAction, canDiscoverChildren, newPathAddedAction, canStoreBranchToPaths, newBranchAction, canExit,getNextNodes,isNext)
    % getAllPathsFromNode implements a DFS algorithm on a deterministic automaton
    % without any limitation on the paths explored on the graph; at each
    % fork, the algorithm adds the node of each branch to a queue and then 
    % pops the last inserted, which is explored; the search deeply continues 
    % until the next popped node is not a successor of the current node
    % (i.e. the popped node is the first node of an alternative branch of
    % the last fork); the algorithm can either proceed forwards or 
    % backwards from the starting node. The search does not embed any stop
    % criteria: for cyclic graphs it can run forever. Specific user
    % functions, like canInsertNodeToPath, canDiscoverChildren are useful to
    % define stop conditions: they take an algorithm state object (ASO) and
    % return a bool output that modulates the evolution of the search; 
    % other user functions like newNodeAddedToPathAction, newPathAddedAction, 
    % newBranchAction are used to externally react to important events during the search;
    % usually, these functions can modify custom fields of the ASO object
    % when it is used as state object also for external computation;
    % the ASO object is a structure having the following fields:
    % - thisNodeID
    % - thisNodeTransition
    % - currentIDPath;
    % - currentTransitionPath;
    % - IDpaths;
    % - transitionPaths;
    %  the user function newBranchAction, in addition to the ASO struct, also takes three more parameters:
    % - lastVisitedID (ID of the first node of the current branch explored from the last fork) 
    % - lastVisitedTransition (transition that leads to the first node of the current branch explored from the last fork) 
    % - lastBranchIndex (index of currentIDPath representing the node from which a fork originates) 
    % these fields must be intended as read-only be user functions; the ASO
    % object can be modified by the user functions on custom fields;
    % the user function newPathAddedAction, in addition to the ASO struct,
    % also takes: IDpaths,transitionPaths which can be modified by the
    % function (they must be returned as output)
    
    function updateAlgorithmStateObject()
        ASO.graph=graph;
        ASO.startNodeID=startNodeID;
        ASO.thisNodeID=thisNodeID;
        ASO.thisNodeTransition=thisNodeTransition;
        ASO.currentIDPath=currentIDPath;
        ASO.currentTransitionPath=currentTransitionPath;
        ASO.IDpaths=IDpaths;
        ASO.transitionPaths=transitionPaths;
    end 

    IDpaths=[];
    transitionPaths=[];
    lastVisitedID=[];
    lastVisitedTransition=[];
    currentTransitionPath = [];
    firstIteration = true;
    agglo=[];
    ASO=initExtraVars();
    lastNodeDepth = -1;
    thisNodeDepth = 0;
    
    stack = createEmptyStack(); %stack containing the node IDs to explore in a FIFO order during DFS
    stack = stackElement({[],[],startNodeID,0},stack);
    currentIDPath = {startNodeID};
    currentIDPathBranchesIndices=createEmptyStack();
    
    assert(exist('getNextNodes','var')==exist('isNext','var'),'Functions getNextNodes and isNext must be BOTH provided or not. parameter "goBackwards" has no meaning if they are provided');
    
    if not(exist('getNextNodes','var'))
        if goBackwards
            isNext = @isPredecessor;
            getNextNodes = @getPredecessorNodes;
        else
            isNext = @isSuccessor;
            getNextNodes = @getSuccessorNodes;
        end
    end
    
    newBranch = false;
    extractNewNode = true;
    
    while firstIteration || not(isempty(agglo)) || not(isStackEmpty(stack))
        if (canExit(ASO))
            return;
        end
        %we do not extract a new node if and only if the last extracted
        %was not on the path
        if extractNewNode
            [agglo, stack]= popElement(stack); 
            if(not(isempty(agglo)))
                preNodeID = agglo{1}; thisNodeTransition = agglo{2}; thisNodeID = agglo{3}; thisNodeDepth = agglo{4}; 
            end
        end
        
        updateAlgorithmStateObject();

        if not(firstIteration) 
            % if the popped element is on the path, add to current path; if
            % it isn't, it means that it is the first node of an alternative branch of
            % the last fork
            isNextBool = isequal(currentIDPath{end},preNodeID) && isNext(thisNodeID,currentIDPath{end},thisNodeTransition, graph);
            if not(newBranch)
                preliminaryCheck = lastNodeDepth==thisNodeDepth-1;
            else
                preliminaryCheck = true;
            end
            
            [canInsert, ASO] = canInsertNodeToPath(ASO);
            
            if (preliminaryCheck && ...
                    isNextBool && ...
                        canInsert)
                
            	currentIDPath = [currentIDPath, {thisNodeID}];
                currentTransitionPath = [currentTransitionPath,thisNodeTransition];
                updateAlgorithmStateObject();
                ASO = newNodeAddedToPathAction(ASO);
                newBranch = false;
                extractNewNode = true;
            else  % otherwise store the current path, and initialize the next path with the right prefix
                
                newBranch = true;
                
                if lastNodeDepth~=thisNodeDepth-1 || not(isNextBool)
                    extractNewNode=false;
                end
                
                [canStoreBranch, ASO] = canStoreBranchToPaths(ASO);
                
                if canStoreBranch
                    store = true;
                    for j=1:length(IDpaths) % do not store a path if it has already been stored
                        if isequal(transitionPaths{j},currentTransitionPath) && isequal(IDpaths{j},currentIDPath)
                            store = false;
                            break;
                        end
                    end

                    if(store)
                        IDpaths{end+1} = currentIDPath; 
                        transitionPaths{end+1} = currentTransitionPath;
                        [ASO,IDpaths,transitionPaths] = newPathAddedAction(ASO,IDpaths,transitionPaths);
                        updateAlgorithmStateObject();
                    end
                end
                
                % consider the last branch that has been taken
                [lastBranchIndex, currentIDPathBranchesIndices] = popElement(currentIDPathBranchesIndices);
                
                if not(isempty(lastBranchIndex))
                    if length(currentIDPath)>lastBranchIndex %the first node of the last branch could have not been visited (canInsertNode gives false)
                        lastVisitedID = currentIDPath{lastBranchIndex+1}; %store the last explored ID after the branch
                        lastVisitedTransition = currentTransitionPath(lastBranchIndex); %and also the transition, so as to not explore it again
                    else
                        lastVisitedID=[]; 
                        lastVisitedTransition=[];
                    end
                    currentIDPath = currentIDPath(1:lastBranchIndex); %take the right prefix
                    currentTransitionPath = currentTransitionPath(1:lastBranchIndex-1);
                    
                    updateAlgorithmStateObject();
                    ASO = newBranchAction(ASO,lastVisitedID,lastVisitedTransition, lastBranchIndex);

                end
            end
        end
        
        updateAlgorithmStateObject();
        [canDiscChild,ASO] = canDiscoverChildren(ASO);
        if canDiscChild && not(newBranch) 
            [nextClasses,transitions] = getNextNodes(graph,thisNodeID);
            
            %if we are going backwards,
            %order transitions so that the first has the lowest
            %priority and the last has the highest priority
            %at the same, the "distance" info, stored on each edge,
            %is used, if exists, so as to explore first transitions
            %that are less distant from 'C0' if exists
            if goBackwards && isKey(graph,'0')
                distances = zeros(1,length(transitions));
                for l = 1: length(transitions)
                   trs_i = transitions{l};
                   assert(length(trs_i)==1);
                   info = getInfoFromInfos(getDistanceInfoID(),getInfosOfLinkingTransition(nextClasses(l),trs_i(1)));
                   if isempty(info)
                       distances(l) = inf;
                   else
                       distances(l) = info;
                   end
                end
                [~,indcs] = sort(distances,'desc');
                transitions = transitions(indcs);
                nextClasses = nextClasses(indcs);
            end

            nBranches=0;
            for i=1:length(nextClasses)
                % explore only branches that have not been already explored 
                 if (not(skipCycles) || isempty(findStringInCellArray(getNodeID(nextClasses(i)),currentIDPath)))
                    trs_i = transitions{i};
                    
                    for l = 1: length(trs_i) % in general a node can be reached by multiple arcs from the same father
                        tr = trs_i(l);
                        stack = stackElement({thisNodeID,tr,getNodeID(nextClasses(i)),thisNodeDepth+1},stack);
                        nBranches = nBranches + 1;
                    end
                end
            end
            for i=1:nBranches-1 %if we have more than one next nodes, we must store that other branches exist, so as to explore them; 
                currentIDPathBranchesIndices = stackElement(length(currentIDPath),currentIDPathBranchesIndices);
            end
            lastNodeDepth = thisNodeDepth;
        end
        
        firstIteration=false;
        lastVisitedID=[];
        store = true;
    end 
end