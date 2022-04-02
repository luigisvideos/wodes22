function [info] = getOutInfo(node,transition)
    infos=node.outTransitionsInfo;
    if isKey(infos,transition)
        info = infos(transition);
    else
        info = [];
    end
end

