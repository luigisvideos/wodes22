function [str] = constraintsInfoToString(constraintsInfo)
    
    constraintInfoTr = keys(constraintsInfo);
    constraintInfoIntervals = values(constraintsInfo);
    str = [];
    for k=1:length(constraintInfoTr)
        tr = constraintInfoTr{k};
        int = constraintInfoIntervals{k};
        
        str{end+1}=intervalToString(int,tr);
    end
end