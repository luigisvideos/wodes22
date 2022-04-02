function node = updateNodeInfoTo(node,infoID,infoVal)
    infos = getNodeInfos(node);
    newInfos = setInfoToInfos(infoVal,infoID,infos);
    node = setNodeInfos(node,newInfos);
end