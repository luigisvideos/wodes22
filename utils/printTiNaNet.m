function [] = printTiNaNet( IPN, fileName, defineTransitionsByAliases,sourceTrOnlyFlag )
% transitionsTimeMap is an optional variable; it is a map associating 
% to each transition id an array
% whose first element is the lower bound while the second is the upper
% bound
Ms=getMs(IPN);
PRE=getPRE(IPN);
POST=getPOST(IPN);

if(not(exist('sourceTrOnlyFlag','var')))
   sourceTrOnlyFlag=false; 
end


transitionsTimeMap=getTransitionsDelayMap(IPN);
function string=getTrTime(t)
    if not(exist('transitionsTimeMap','var'))
        string ='[0,w[';
    else
        assert(isKey(transitionsTimeMap,t),'No timing info on given transition');
        assert(length(transitionsTimeMap(t))<=2 && length(transitionsTimeMap(t))>=1,'The timing info must contain at most two values lower and upper bounds or only one value for delays');
        bounds = transitionsTimeMap(t);
        if ( length(bounds) == 1) 
            bounds=[bounds,bounds];
        end
        assert(bounds(1) <= bounds(2),'The lower bound must be not greater than the upper bound');
        if(isinf(bounds(2)))
            warning('An upper bound is not finite');
            string = ['[',num2str(bounds(1)),',w['];
        else
            string = ['[',num2str(bounds(1)),',',num2str(bounds(2)),']'];
        end
    end
end
if not(exist('defineTransitionsByAliases','var'))
    defineTransitionsByAliases=false;
end

newline=[sprintf('\r'),sprintf('\n')];
netCode='';

% tr printing
for t=1:size(PRE,2)
    if not(sourceTrOnlyFlag) || (sourceTrOnlyFlag && isempty(find(getEndTransitionIdxs(IPN)==t, 1)))
        if defineTransitionsByAliases
            tIdx = getTransitionAlias(t,IPN);
        else
            tIdx = t;
        end
        netCode=[netCode,'tr t',num2str(tIdx),' ',getTrTime(t),' '];
        for i=1:size(PRE,1)
           if(PRE(i,t)~=0)
               netCode=[netCode,'p',num2str(i),'*',num2str(PRE(i,t)),' '];
           end
        end
        netCode=[netCode,'-> '];
        for i=1:size(PRE,1)
           if(POST(i,t)~=0)
               netCode=[netCode,'p',num2str(i),'*',num2str(POST(i,t)),' '];
           end
        end
        netCode=[netCode,newline];
    end
end

%places printing
for i=1:size(PRE,1)
    netCode=[netCode,'pl p',num2str(i),' (',num2str(Ms(i)),')',newline];
end

%saving code to file
fileID = fopen([fileName,'.net'],'w');
fprintf(fileID,'%s',netCode);
fclose(fileID);

end

