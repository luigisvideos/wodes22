function bool = isClassUntagged(class)
   infos = getNodeInfos(class);
   tag=getInfoFromInfos(getTagInfoID(),infos);
   bool=isequal(tag,untaggedTag());
end