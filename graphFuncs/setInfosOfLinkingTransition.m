function [node] = setInfosOfLinkingTransition(node,transition,infos)
    %replaces old infos
    node.outTransitionsInfos(transition) = infos;
end

