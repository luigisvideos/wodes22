function [str] = multiEnablingConstraintsInfoToString(constraintsInfo)
    str = [];
    for tr=1:length(constraintsInfo)
        array = constraintsInfo{tr};
        for l=1:length(array)
            str{end+1}=intervalToString(array(l),tr,l);
        end
    end
end