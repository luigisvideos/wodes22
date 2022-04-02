function [str] = constraintsInfoToString(constraintsInfo)
    
    function str=printBound(bounds)
        str=[];
        if length(bounds)>1
            str='max(';
        end
        for i=1:length(bounds)
            bound = bounds(i);
            if i>1
                str=[str,', '];
            end
            if isnumeric(bound)
                str=[str,num2str(bound)];
            else
                str=[str,sym2str(bound)];
            end
        end
        if length(bounds)>1
            str=[str,')'];
        end
    end
    
    constraintInfoTr = keys(constraintsInfo);
    constraintInfoIntervals = values(constraintsInfo);
    str = [];
    for k=1:length(constraintInfoTr)
        tr = constraintInfoTr{k};
        int = constraintInfoIntervals{k};
        str{end+1}=[printBound(int.inf) ' <= ', 'theta_',num2str(tr),' <= ' printBound(int.sup)];
    end
end