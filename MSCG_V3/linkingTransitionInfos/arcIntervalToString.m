function [fstr] = arcIntervalToString(int)

    function str=printBound(bounds)
        str=[];
        if length(bounds)>1
            str='(';
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
    mustMax = length(int.inf)>1;
    mustMin = length(int.sup)>1;

    if mustMax
        maxStr ='max';
    else
        maxStr='';
    end

    if mustMin
        minStr='min';
    else
        minStr='';
    end
    fstr=[maxStr,printBound(int.inf) ' <= ',printBound(int.var),' <= ',minStr, printBound(int.sup)];
end

