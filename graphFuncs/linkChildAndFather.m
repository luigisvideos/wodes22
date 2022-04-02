function [ newChild,newFather ] = linkChildAndFather( newChild,newFather,linkingTransition, transitionInfos )
    if not(exist('ignore','var'))
        ignore=false;
    end
    assert(length(linkingTransition)==1);
    
    assert(isempty(find(newFather.outTransitions==linkingTransition, 1)),['State with ID ',getNodeID(newFather),' already has output transition ',num2str(linkingTransition)]);
%     newChild = copy(child);
%     newFather = copy(father);
    
    if(isKey(newChild.in,newFather.winID))
        newChild.in(newFather.winID) = union(newChild.in(newFather.winID),linkingTransition);
    else
        newChild.in(newFather.winID) = linkingTransition;
    end
    if(isKey(newFather.out,newChild.winID))
        newFather.out(newChild.winID) =union(newFather.out(newChild.winID),linkingTransition);
    else
        newFather.out(newChild.winID) =linkingTransition;
    end
    newChild.inTransitions = union(newChild.inTransitions,linkingTransition);
    newFather.outTransitions=union(newFather.outTransitions,linkingTransition);
    
    if(exist('transitionInfos','var'))
        newFather.outTransitionsInfos(linkingTransition) = transitionInfos;
    else
        newFather.outTransitionsInfos(linkingTransition) = createEmptyInfos();
    end

    if(isequal(newChild.winID,newFather.winID))
        [newChild, newFather] = makeSameNodesConsistent(newChild,newFather);
    end
end

