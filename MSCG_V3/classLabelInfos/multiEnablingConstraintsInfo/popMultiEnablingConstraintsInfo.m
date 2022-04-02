function [interval,info] = popMultiEnablingConstraintsInfo(tr,info)
    info = info;
    interval = [];
    if not(isempty(info{tr}))
        theArray = info{tr};
        interval = theArray(1);
        info{tr} = theArray(2:end);
    end
end