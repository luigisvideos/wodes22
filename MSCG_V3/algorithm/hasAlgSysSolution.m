function [bool,xSol,xSym,AineqTot,BineqTot] = hasAlgSysSolution(ineqs,eqs,deltasToMax,deltasToMin,isInteger,AineqInit,BineqInit,xSymInit,newDeltas)
    % if newDeltas is provided, it means that new ineqs and eqs differ from
    % initial matrices and variables by this array of new deltas. ATTENTION
    % for performance, it is not checked whether or not variables in
    % newdeltas are already in xSymInit
   
    if exist('AineqInit','var') && exist('BineqInit','var')
       assert(isnumeric( AineqInit) && isnumeric(BineqInit));
    else
        AineqInit = [];
        BineqInit = [];
        xSymInit = [];
    end
    assert((exist('deltasToMax','var') && exist('deltasToMin','var')) ||...
        not(exist('deltasToMax','var')) && not(exist('deltasToMin','var')));
    
    if not(exist('isInteger','var'))
        isInteger=false;
    end

    
     xSol=[];
     bool=false;
     
     if not(exist('newDeltas','var'))
         totXSymFromNew=[];
         if not(isempty(ineqs)) || not(isempty(eqs))
            totXSymFromNew = symvar([ineqs,eqs]);
         end
         if not(isempty(totXSymFromNew))
             newXSym = totXSymFromNew(not(ismember(totXSymFromNew,xSymInit)));
         else
             newXSym = [];
         end
     else
         newXSym = newDeltas;
     end
     
     xSym = [xSymInit,newXSym];
     
     if ~isempty(newXSym)
         AineqInitTemp = zeros(size(AineqInit,1),size(AineqInit,2)+length(newXSym));
         AineqInitTemp(:,1:size(AineqInit,2)) = AineqInit;
         AineqInit = AineqInitTemp;
     end
     
     if not(isempty(ineqs))
        [Aineq,Bineq]=equationsToMatrix(sym(ineqs),xSym);
     else
         Aineq = [];
         Bineq = [];
     end
     if not(isempty(eqs))
        [Aeq,Beq]=equationsToMatrix(sym(eqs),xSym);
     else
         Aeq=[];
         Beq=[];
     end
     
     if isempty(xSym)
         xSym=[];
     end
     
     if isempty(Beq)
         Beq=[];
         Aeq=[];
     end
     if (isempty(Aineq) && not(isempty(Bineq)))
         Aineq = zeros(size(Bineq));
     end

     indPositiveInfConstr = ismember(Bineq,Inf);
     indNegativeInfConstr = isinf(Bineq);
     if any(indNegativeInfConstr)
         if Bineq(indNegativeInfConstr)<0
            return;
         end
     end
     if any(indPositiveInfConstr)
         if all(Aineq(indPositiveInfConstr)>=0)
             Aineq(indPositiveInfConstr,:)=[];
             Bineq(indPositiveInfConstr)=[];
         else
             return;
         end
     end
     
     f=zeros(size(xSym));
     if isempty(xSym)
         f=0;
     end
    if exist('deltasToMax','var')
%         assert(isempty( intersect(deltasToMax,deltasToMin)),'Deltas can not be both minimized and maximized; choose minimization or maximization of a delta, not both');
        if ~isempty(deltasToMax)
            maxDeltasIdcs=ismember(xSym,deltasToMax);
%             assert(length(deltasToMax) == length(maxDeltasIdcs),'Deltas to maximize include not encountered deltas');
            f(maxDeltasIdcs) = -1;
        end
        if ~isempty(deltasToMin)
            minDeltasIdcs=ismember(xSym,deltasToMin);
%             assert(length(deltasToMin) == length(minDeltasIdcs),'Deltas to minimize include not encountered deltas');
            f(minDeltasIdcs) = 1;
        end
    end
    
    AineqTot=[AineqInit;
        double(Aineq)];
    BineqTot=[BineqInit;
        double(Bineq)];
    
    if not(isInteger)
         options = optimoptions('linprog','Display','none');
         [xSol,FVAL,EXITFLAG] =  linprog(f,AineqTot,BineqTot,double(Aeq),double(Beq),zeros(size(xSym)),double(intmax)*ones(size(xSym)),options);
%        [xSol,FVAL,EXITFLAG] =  cplexlp(f,AineqTot,BineqTot,double(Aeq),double(Beq),zeros(size(xSym)),double(intmax)*ones(size(xSym)));
    else
        [xSol,FVAL,EXITFLAG] =  intlinprog(f,1:length(xSym),double(AineqTot),double(BineqTot),double(Aeq),double(Beq),zeros(size(xSym)),double(intmax)*ones(size(xSym)));
    end
    %   opts = optimset('linprog');
%   opts = optimset(opts,'Display','off');
% 	[xSol,FVAL,EXITFLAG]=linprog(f,double(Aineq),double(Bineq),double(Aeq),double(Beq),zeros(size(xSym)),double(intmax)*ones(size(xSym)),[],opts);
    
xSol(xSol == double(intmax)) = Inf;
    if EXITFLAG==1
        bool=true;
    end
end