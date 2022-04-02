function [str] = infoToString(info,infoID)
    if isequal(infoID,getConstraintsInfoID())
        str = constraintsInfoToString(info);
        return;
    end
    if isequal(infoID,getMarkingInfoID())
        str = markingInfoToString(info);
        return;
    end
    if isequal(infoID,getTagInfoID())
        str = info;
        return;
    end
    if isequal(infoID,getTimePassedInfoID())
        str = ['time: ',timePassedInfoToString(info)];
        return;
    end
    if isequal(infoID,getObservationIndexInfoID())
        str = ['obs n.: ',observationIndexInfoToString(info)];
        return;
    end
    if isequal(infoID,getMultiEnablingConstraintsInfoID())
        str = multiEnablingConstraintsInfoToString(info);
        return;
    end
    
    warning('InfoID not found');
    str='';
    
end

