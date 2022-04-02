function printClass(class)

infos = getNodeInfos(class);

disp(['Class: ' getNodeID(class)]);
disp(['Marking: ', markingInfoToString(getInfoFromInfos(getMarkingInfoID(),infos))]);
disp(['Enab: ' num2str(getOutTransitions(class))]);
disp('Bounds:')
str = constraintsInfoToString(getInfoFromInfos(getConstraintsInfoID(),infos));
for k=1:length(str)
   disp([char(9), str{k}]);
end
disp(['Tag: ',getInfoFromInfos(getTagInfoID(),infos)])
end