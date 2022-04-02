function [bool,isoEqs] = areTwoClassesEquivalent(c1,c2)
   infos1=getNodeInfos(c1); 
   infos2=getNodeInfos(c2);
   
   bool=false; 
   isoEqs=[];
   if not(isequal(getInfoFromInfos(getMarkingInfoID(),infos1),...
                  getInfoFromInfos(getMarkingInfoID(),infos2)))
      return;
   end
   
   [res,isoEqs] = findIsomorphism(c1,c2);
   if not(res)
      return;
    end
   
   bool = true;
end