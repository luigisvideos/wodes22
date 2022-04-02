function [fstr] = isomorphismInfoToString(isomorphs)
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
    fstr=[];
    for j=1:size(isomorphs,1)
       isomorph = isomorphs(j,:);
       fstr{end+1}=[printBound(isomorph(1)),' := ',printBound(isomorph(2))];
    end
end

