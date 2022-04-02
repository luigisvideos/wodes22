function [res,isoEqs] = findIsomorphism(c1,c2)
    % res is true if an isomorphism exists, otherwise it is false; if
    % res=true then isoEqs contains a set of one-sided equalities on deltas
    
    map = containers.Map('KeyType','char','ValueType','any');
    
    function res = checkBoundTypeConsistency(bound1,bound2)
        res=true;
        if(not(isnumeric(bound1)) && isnumeric(bound2) || ...
               isnumeric(bound1) && not(isnumeric(bound2)))
           res=false;
       end
    end
    
    function res=checkBoundExpressionConsistency(bound1,bound2)
        res=true;
        if isnumeric(bound1) || (isinf(bound1) || isinf(bound2))
           if not(isequal(bound1,bound2))
               res=false; return;
           end
        else
          [coeffs1,molts1]=coeffs(bound1);
          [coeffs2,molts2]=coeffs(bound2);
          
          %first check same number of elements
          if not(isequal(length(coeffs1),length(coeffs2)))
              res=false; return;
          end
          
          %check for numerical addend equivalence
          numAddIdx1 = molts1==1;
          numAddIdx2 = molts2==1;
          if not(isequal(coeffs1(numAddIdx1), coeffs2(numAddIdx2)))
              return;
          end
          % it is not necessary to
          %check equivalence on deltas' coefficients because each delta
          %appears at most 1 time; just assert this to be sure:
          deltaCoeffsIdxs1 = molts1~=1;
          deltaCoeffsIdxs2 = molts2~=1;
          assert(isequal(coeffs1(deltaCoeffsIdxs1),coeffs2(deltaCoeffsIdxs2))); %they must be equal 
          assert(isequal(coeffs1(deltaCoeffsIdxs1),sym(-ones(1,length(coeffs1(deltaCoeffsIdxs1))))));%they must be all -1
        end
    end
    
    function res=checkTypeConsistency(interval1,interval2) %inf/sup of the two intervals
                                                       %must be of the same type (num or sym) 
       res=checkBoundTypeConsistency(interval1.inf(end),interval2.inf(end));
       if not(res) return; end
       res=checkBoundTypeConsistency(interval1.sup,interval2.sup);
    end
    
    function res=checkExpressionConsistency(interval1,interval2)% if inf/sup of 
                                                           % the two intervals
                                                           % is numerical
                                                           % (or inf) they
                                                           % must be equal;
                                                           % otherwise they
                                                           % must contain
                                                           % the same
                                                           % number of
                                                           % coeffs and
                                                           % deltas
       res=checkBoundExpressionConsistency(interval1.inf(end),interval2.inf(end));
       if not(res) return; end
       res=checkBoundExpressionConsistency(interval1.sup,interval2.sup);
       if not(res) return; end
       res = isequal(length(interval1.orderedSubtractors),length(interval2.orderedSubtractors));
    end
   res = false;
   isoEqs = [];
   
   infos1=getNodeInfos(c1); 
   infos2=getNodeInfos(c2);
   constr1 = getInfoFromInfos(getConstraintsInfoID(),infos1);
   constr2 = getInfoFromInfos(getConstraintsInfoID(),infos2);
   
   thetas1 = keys(constr1);
   thetas2 = keys(constr2);
   
   
   if not(isequal(thetas1,thetas2))
       return;
   end
   
   %check multienabled transitions are equal
   multiCons1= getInfoFromInfos(getMultiEnablingConstraintsInfoID(),getNodeInfos(c1));
   multiCons2= getInfoFromInfos(getMultiEnablingConstraintsInfoID(),getNodeInfos(c2));
   multiEn1=getMultiEnablingConstrainedTransitions(multiCons1);
   multiEn2=getMultiEnablingConstrainedTransitions(multiCons2);
   if not(isequal(multiEn1,...
           multiEn2))
    return;
   end
   
   intervals1 = values(constr1);
   intervals2 = values(constr2);
   
   % add multienabling intervals
   for trIdx=1:length(multiEn1)
      tr=multiEn1(trIdx);
      array1 = multiCons1{tr};
      array2 = multiCons2{tr};
      if not(isequal(length(array1),length(array2)))
          return;
      end
      for j=1:length(array1)
          intervals1=[intervals1,{array1(j)}];
          intervals2=[intervals2,{array2(j)}];
      end
   end
   
   eqs=[]; 
   
   for intervalIdx=1:length(intervals1) %for each theta, we first check consistency,
                               %then check final isomorphism
       interval1 = intervals1{intervalIdx};
       interval2 = intervals2{intervalIdx};
       
       res=checkTypeConsistency(interval1,interval2);
       if not(res) return; end
       res=checkExpressionConsistency(interval1,interval2);
       if not(res) return; end
       % create equalities
       orderedVars1 = interval1.orderedSubtractors;
       orderedVars2 = interval2.orderedSubtractors;
       
       assert(isequal(length(orderedVars1),length(orderedVars2)));
       
       for i=1:length(orderedVars1)
           if not(isequal(orderedVars1(i),orderedVars2(i)))
               if not(isKey(map,sym2str(orderedVars1(i))))
                   map(sym2str(orderedVars1(i))) = orderedVars2(i);
                   eqs=[eqs,orderedVars1(i)-orderedVars2(i)];
               else
                   if not(isequal(map(sym2str(orderedVars1(i))),orderedVars2(i)))
                       return;
                   end
               end
           end
       end
   end

   isoEqs = unique(eqs);
   res = true;
end

