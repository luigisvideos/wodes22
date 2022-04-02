function [info] = createIntervalInfo(inferior,superior,var,prevClassIntervalInfo,subtractor)
    info.inf = inferior;
    info.sup = superior;
    info.var = var;
    if(exist('prevClassIntervalInfo','var'))
        if not(isequal(subtractor,-superior+prevClassIntervalInfo.sup))
            subtractor=[];
        end
        newlySubtractedDelta = subtractor;
%         assert(not(isempty(newlySubtractedDelta)));
        if isfield(prevClassIntervalInfo,'orderedSubtractors')
            info.orderedSubtractors = [prevClassIntervalInfo.orderedSubtractors,...
                newlySubtractedDelta];
        else
            info.orderedSubtractors = newlySubtractedDelta;
        end
    else
        info.orderedSubtractors=[];
    end
end

