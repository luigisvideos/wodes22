function printArc(class,outTr)

infos = getInfosOfLinkingTransition(class,outTr);

disp(['Transition: ', num2str(outTr)]);
if not(isempty(getInfoFromInfos(getLabelInfoID(),infos)))
    disp(['Label: ', getInfoFromInfos(getLabelInfoID(),infos)]);
end
disp('Bounds:')
int=getInfoFromInfos(getIntervalInfoID(),infos);
disp([char(9),arcIntervalToString(int)]);

isomorphs=getInfoFromInfos(getIsomorphismInfoID(),infos);
[fstr] = isomorphismInfoToString(isomorphs);    
for j=1:size(isomorphs,1)
    str=[];
    if j==1
     disp(['Isomorphisms: ']);
    end
    str=[str,fstr{j}];
    
    disp([char(9),str]);
end

%print distance
info = getInfoFromInfos(getDistanceInfoID(),infos);
if not(isempty(info))
   disp(['Minimal distance from C0: ',num2str(info)]); 
end
end