function [info] = addMultiEnablingConstraintsInfo(intervalInfo,tr,info)
    if isempty(info{tr})
        intervalInfo.age = 1;
        info{tr} = intervalInfo;
    else
        intervalInfo.age = length(info{tr})+1;
        info{tr} = [info{tr},intervalInfo];
    end
end