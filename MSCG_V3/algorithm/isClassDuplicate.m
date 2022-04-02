function bool = isClassDuplicate(class)
   infos = getNodeInfos(class);
   tag=getInfoFromInfos(getTagInfoID(),infos);
   bool=isequal(tag,duplicateTag());
end