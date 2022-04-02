function [str] = intervalToString(int,tr,ped)
    
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
    
    thetaString = ['theta_',num2str(tr)];
    if exist('ped','var')
        theChar = char("'");
        thetaString= [thetaString,repmat(theChar,[1,ped])];
    end
    
    str=[printBound(int.inf) ' <= ', thetaString ,' <= ' printBound(int.sup)];
end