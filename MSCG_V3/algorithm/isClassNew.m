function bool = isClassNew(class)
   infos = getNodeInfos(class);
   tag=getInfoFromInfos(getTagInfoID(),infos);
   bool=isequal(tag,newTag());
end